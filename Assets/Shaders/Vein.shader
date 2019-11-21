// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JRW/Vein"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0
		_Tint("Tint", Color) = (0,0,0,0)
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelPower("FresnelPower", Float) = 0
		_FresnelScale("FresnelScale", Float) = 0
		_StartDithering("Start Dithering", Float) = 0
		_EndDithering("End Dithering", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			INTERNAL_DATA
			float3 worldNormal;
			float eyeDepth;
			float4 screenPosition;
		};

		uniform float _NormalScale;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _Tint;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _FresnelColor;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _StartDithering;
		uniform float _EndDithering;
		uniform float _Cutoff = 0;


		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 _normalMap49 = UnpackScaleNormal( tex2D( _Normal, uv_Normal ), _NormalScale );
			o.Normal = _normalMap49;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 _albedo34 = ( tex2D( _Albedo, uv_Albedo ) * _Tint );
			o.Albedo = _albedo34.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV36 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode36 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV36, _FresnelPower ) );
			float4 _fresnel40 = ( fresnelNode36 * _FresnelColor );
			o.Emission = _fresnel40.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
			float temp_output_86_0 = ( _StartDithering + _ProjectionParams.y );
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen95 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither95 = Dither8x8Bayer( fmod(clipScreen95.x, 8), fmod(clipScreen95.y, 8) );
			float _dithering100 = ( ( ( i.eyeDepth + -temp_output_86_0 ) / ( _EndDithering - temp_output_86_0 ) ) - dither95 );
			clip( _dithering100 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 customPack1 : TEXCOORD1;
				float4 customPack2 : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.z = customInputData.eyeDepth;
				o.customPack2.xyzw = customInputData.screenPosition;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.eyeDepth = IN.customPack1.z;
				surfIN.screenPosition = IN.customPack2.xyzw;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
35;145;1906;795;2797.268;-107.9877;1.121727;False;False
Node;AmplifyShaderEditor.CommentaryNode;83;306.0613,-1519.25;Float;False;1879.538;593.2301;;12;100;95;99;89;87;86;84;85;88;96;90;92;DITHERING;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;84;345.0376,-1236.555;Float;False;Property;_StartDithering;Start Dithering;14;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ProjectionParams;85;361.9529,-1125.835;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;56;-1912.738,-1778.388;Float;False;1030.84;397.814;;3;49;60;61;Normal Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1833.11,-1657.918;Float;False;Property;_NormalScale;Normal Scale;4;0;Create;True;0;0;False;0;0;0.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;625.5294,-1180.023;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;817.5009,-1251.551;Float;False;Property;_EndDithering;End Dithering;15;0;Create;True;0;0;False;0;1;0.67;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;87;810.916,-1334.904;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode;88;684.6192,-1440.138;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;43;-1927.888,-570.3601;Float;False;1119.399;537.8823;;8;37;38;36;39;42;41;40;80;Fresnel;1,0,0,1;0;0
Node;AmplifyShaderEditor.SamplerNode;61;-1555.636,-1662.154;Float;True;Property;_Normal;Normal;3;0;Create;True;0;0;False;0;None;77c6ce1a3121cf044ae250429f5da41f;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;92;1035.301,-1221.651;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;1046.001,-1405.45;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1869.489,-242.6771;Float;False;Property;_FresnelScale;FresnelScale;9;0;Create;True;0;0;False;0;0;1.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-1172.69,-1634.138;Float;False;_normalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1872.889,-152.2776;Float;False;Property;_FresnelPower;FresnelPower;8;0;Create;True;0;0;False;0;0;4.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-1879.922,-501.0315;Float;False;49;_normalMap;0;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;33;-1934.568,-1189.576;Float;False;1021.435;491.408;;4;32;1;31;34;Albedo;0,0.6879039,1,1;0;0
Node;AmplifyShaderEditor.FresnelNode;36;-1557.908,-419.7232;Float;False;Standard;TangentNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;95;1353.895,-1128.124;Float;False;1;False;3;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;-1788.737,-918.8434;Float;False;Property;_Tint;Tint;1;0;Create;True;0;0;False;0;0,0,0,0;1,0,0.06321781,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;41;-1554.489,-239.4776;Float;False;Property;_FresnelColor;FresnelColor;7;0;Create;True;0;0;False;0;0,0,0,0;0.8773585,0.2781589,0.1200158,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;96;1242.801,-1337.951;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1884.568,-1139.576;Float;True;Property;_Albedo;Albedo;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;78;-2423.032,289.3655;Float;False;1705.12;605.8961;;11;76;68;73;72;75;70;77;71;69;74;79;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-1469.625,-978.1069;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;99;1635.636,-1315.309;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;28;-202.1515,395.3678;Float;False;1847.699;467.0638;;13;29;4;2;26;24;20;3;19;21;22;18;27;66;Extrusion;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-1249.489,-393.4774;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;26;855.8486,605.3679;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;66;-172.2245,637.9952;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;1111.849,461.3678;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;103.8485,605.3679;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-333.9637,-662.3719;Float;False;34;_albedo;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;1350.346,476.2026;Float;False;_vertexExtrusion;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;2;530.8481,442.3678;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;19;327.8486,605.3679;Float;False;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;327.8486,701.3678;Float;False;Property;_ExtrusionAmount;Extrusion Amount;11;0;Create;True;0;0;False;0;0.5;53.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;37;-1881.088,-392.3595;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-1173.307,-962.1517;Float;False;_albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-376.3876,-360.1122;Float;False;Property;_Metallic;Metallic;5;0;Create;True;0;0;False;0;0;0.85;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;20;503.8482,605.3679;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-366.7463,-250.937;Float;False;Property;_Smoothness;Smoothness;6;0;Create;True;0;0;False;0;0;0.63;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;24;695.8484,605.3679;Float;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-1051.489,-399.4774;Float;False;_fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;1933.707,-1239.59;Float;False;_dithering;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-344.2803,-132.9589;Float;False;100;_dithering;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;18;-160.1515,475.3678;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;50;-343.9741,-557.4005;Float;False;49;_normalMap;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;27;-142.3805,788.0343;Float;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;103.8485,701.3678;Float;False;Property;_ExtrusionPoint;ExtrusionPoint;10;0;Create;True;0;0;False;0;0;-274.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-335.6628,-454.1988;Float;False;40;_fresnel;0;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1128.186,436.0454;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;73;-1532.844,432.5142;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1651.065,542.8722;Float;False;Property;_RimPower;RimPower;12;0;Create;True;0;0;False;0;0;0.8;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;76;-1342.066,420.8716;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;69;-2144.352,504.3442;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;-940.4632,481.4821;Float;False;_rimLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;70;-1938.096,405.3647;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;77;-1315.066,661.8723;Float;False;Property;_RimColor;RimColor;13;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;72;-1760.097,429.2799;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-2373.032,339.3655;Float;False;49;_normalMap;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;68;-2373.032,526.0037;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;120.5242,-527.3078;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;JRW/Vein;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0;True;True;0;False;TransparentCutout;;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;10.2;10.83;27.73;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;86;0;84;0
WireConnection;86;1;85;2
WireConnection;87;0;86;0
WireConnection;61;5;60;0
WireConnection;92;0;89;0
WireConnection;92;1;86;0
WireConnection;90;0;88;0
WireConnection;90;1;87;0
WireConnection;49;0;61;0
WireConnection;36;0;80;0
WireConnection;36;2;39;0
WireConnection;36;3;38;0
WireConnection;96;0;90;0
WireConnection;96;1;92;0
WireConnection;32;0;1;0
WireConnection;32;1;31;0
WireConnection;99;0;96;0
WireConnection;99;1;95;0
WireConnection;42;0;36;0
WireConnection;42;1;41;0
WireConnection;26;0;24;0
WireConnection;4;0;2;0
WireConnection;4;1;26;0
WireConnection;22;0;18;2
WireConnection;22;1;27;0
WireConnection;29;0;4;0
WireConnection;19;0;22;0
WireConnection;19;1;21;0
WireConnection;34;0;32;0
WireConnection;20;0;19;0
WireConnection;24;0;20;0
WireConnection;24;1;3;0
WireConnection;40;0;42;0
WireConnection;100;0;99;0
WireConnection;71;0;76;0
WireConnection;71;1;77;0
WireConnection;73;0;72;0
WireConnection;76;0;73;0
WireConnection;76;1;75;0
WireConnection;69;0;68;0
WireConnection;79;0;71;0
WireConnection;70;0;74;0
WireConnection;70;1;69;0
WireConnection;72;0;70;0
WireConnection;0;0;35;0
WireConnection;0;1;50;0
WireConnection;0;2;44;0
WireConnection;0;3;52;0
WireConnection;0;4;51;0
WireConnection;0;10;30;0
ASEEND*/
//CHKSM=95E2539C825716656C84A4CFA6C3077A72F78A6B