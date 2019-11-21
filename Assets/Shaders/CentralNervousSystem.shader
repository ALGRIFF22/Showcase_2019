// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JRW/CentralNervousSystem"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_NormalMap("Normal Map", 2D) = "white" {}
		_NormalMapScale("Normal Map Scale", Float) = 0
		_MetallicAmount("MetallicAmount", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelPower("FresnelPower", Float) = 0
		_FresnelScale("FresnelScale", Float) = 0
		_FresnelBias("FresnelBias", Float) = 0
		_GlowStrength("GlowStrength", Float) = 1
		_GlowPower("GlowPower", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
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
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _NormalMapScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float4 _Color;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _FresnelColor;
		uniform float _GlowStrength;
		uniform float _GlowPower;
		uniform float _MetallicAmount;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 _normalMap25 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalMapScale );
			o.Normal = _normalMap25;
			float4 _albedo27 = _Color;
			o.Albedo = _albedo27.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV147 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode147 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV147, _FresnelPower ) );
			float4 temp_cast_1 = (_GlowPower).xxxx;
			float4 _fresnel43 = pow( ( ( fresnelNode147 * _FresnelColor ) * _GlowStrength ) , temp_cast_1 );
			o.Emission = _fresnel43.rgb;
			o.Metallic = _MetallicAmount;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows noinstancing 

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
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
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
7;7;1793;1004;1723.834;714.3459;1.6;True;True
Node;AmplifyShaderEditor.CommentaryNode;44;-1999.72,536.1254;Float;False;1662.567;718.3716;;11;154;153;146;145;43;40;149;150;152;147;148;Emission;1,0.9182097,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-1917.754,747.6958;Float;False;Property;_FresnelBias;FresnelBias;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-1916.616,844.7526;Float;False;Property;_FresnelScale;FresnelScale;7;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-1908.066,977.6031;Float;False;Property;_FresnelPower;FresnelPower;6;0;Create;True;0;0;False;0;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;147;-1625.286,686.8464;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;40;-1622.019,908.525;Float;False;Property;_FresnelColor;FresnelColor;5;0;Create;True;0;0;False;0;0,0,0,0;1,0.9304813,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;145;-1300.226,949.4876;Float;True;Property;_GlowStrength;GlowStrength;9;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;21;-1319.989,54.00468;Float;False;1007.687;302.1375;;3;25;4;6;Normal Map;0,0.618978,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-1330.903,779.7931;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-1060.846,1019.54;Float;True;Property;_GlowPower;GlowPower;10;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;20;-983.1946,-641.6166;Float;False;1556.702;566.9187;;2;27;2;Albedo;0,1,0.6719444,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1275.906,232.1294;Float;False;Property;_NormalMapScale;Normal Map Scale;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-1095.825,761.7874;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;153;-849.6465,902.7391;Float;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-980.8386,101.9047;Float;True;Property;_NormalMap;Normal Map;1;0;Create;True;0;0;False;0;None;None;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-622.1943,-435.8158;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;1,1,1,1;0.9716981,0.8834351,0.5362673,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;28;32.70702,58.96891;Float;False;27;_albedo;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;7.686874,169.1053;Float;False;25;_normalMap;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-67.3979,441.0758;Float;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-619.7267,857.7102;Float;True;_fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-541.5394,120.9445;Float;False;_normalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;23.69854,255.9593;Float;False;43;_fresnel;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-296.2157,-379.6507;Float;False;_albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-78.09354,338.2066;Float;False;Property;_MetallicAmount;MetallicAmount;3;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;516.6851,197.7187;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;JRW/CentralNervousSystem;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;True;True;True;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0.1;0.1823282,1,1,1;VertexScale;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;147;1;152;0
WireConnection;147;2;150;0
WireConnection;147;3;149;0
WireConnection;148;0;147;0
WireConnection;148;1;40;0
WireConnection;146;0;148;0
WireConnection;146;1;145;0
WireConnection;153;0;146;0
WireConnection;153;1;154;0
WireConnection;4;5;6;0
WireConnection;43;0;153;0
WireConnection;25;0;4;0
WireConnection;27;0;2;0
WireConnection;0;0;28;0
WireConnection;0;1;26;0
WireConnection;0;2;45;0
WireConnection;0;3;131;0
WireConnection;0;4;5;0
ASEEND*/
//CHKSM=B6DDF1B967C669C6BB26DD1FCD6AF6903787E283