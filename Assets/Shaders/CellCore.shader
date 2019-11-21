// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JRW/CellCore"
{
	Properties
	{
		_RimColor("RimColor", Color) = (0,0,0,0)
		_RimPower("RimPower", Range( 0 , 10)) = 0
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelPower("FresnelPower", Float) = 2.48
		_FresnelScale("FresnelScale", Float) = 1.38
		_FresnelBias("FresnelBias", Float) = 0
		_Metallic("Metallic", Float) = 0
		_Smoothness("Smoothness", Float) = 0
		_NormalMap("NormalMap", 2D) = "bump" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+20" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 viewDir;
		};

		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _FresnelColor;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform float _Metallic;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV110 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode110 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV110, _FresnelPower ) );
			float4 _emission131 = ( fresnelNode110 * _FresnelColor );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 normalizeResult143 = normalize( i.viewDir );
			float dotResult145 = dot( UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) , normalizeResult143 );
			float4 _rimLight151 = ( pow( ( 1.0 - saturate( dotResult145 ) ) , _RimPower ) * _RimColor );
			float4 blendOpSrc154 = _emission131;
			float4 blendOpDest154 = _rimLight151;
			o.Emission = ( saturate( 2.0f*blendOpDest154*blendOpSrc154 + blendOpDest154*blendOpDest154*(1.0f - 2.0f*blendOpSrc154) )).rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

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
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
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
878;55;1263;1010;1245.335;2864.436;1.9;True;False
Node;AmplifyShaderEditor.CommentaryNode;141;-822.4709,-2422.478;Float;False;1739.191;584.2909;;10;151;150;149;148;147;146;145;143;142;152;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;142;-778.0624,-2087.767;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;143;-532.9996,-2178.468;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;152;-778.0261,-2373.092;Float;True;Property;_NormalMap;NormalMap;8;0;Create;True;0;0;False;0;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;145;-378.5759,-2331.42;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;130;-381.7054,-1335.385;Float;False;1321.436;567.6314;;7;131;134;133;110;118;137;117;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;146;-182.8753,-2290.686;Float;False;1;0;FLOAT;1.23;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-327.4315,-1176.138;Float;False;Property;_FresnelScale;FresnelScale;4;0;Create;True;0;0;False;0;1.38;4.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-110.4743,-2132.986;Float;False;Property;_RimPower;RimPower;1;0;Create;True;0;0;False;0;0;3.8;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-329.8158,-1080.425;Float;False;Property;_FresnelPower;FresnelPower;3;0;Create;True;0;0;False;0;2.48;1.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-325.4856,-1272.675;Float;False;Property;_FresnelBias;FresnelBias;5;0;Create;True;0;0;False;0;0;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;155;35.26453,-2302.036;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;148;172.7254,-2045.188;Float;False;Property;_RimColor;RimColor;0;0;Create;True;0;0;False;0;0,0,0,0;0.3788714,0.1177465,0.509434,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;133;13.35625,-1021.846;Float;False;Property;_FresnelColor;FresnelColor;2;0;Create;True;0;0;False;0;0,0,0,0;0.8089943,0,1,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;149;178.9249,-2224.986;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;110;-82.23495,-1285.385;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;421.3252,-2209.787;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;307.2539,-1117.981;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;1129.036,-1215.206;Float;False;131;_emission;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;631.5248,-1135.97;Float;True;_emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;1132.68,-1135.82;Float;False;151;_rimLight;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;151;673.7197,-2148.798;Float;False;_rimLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;125;1156.925,-1033.285;Float;False;Property;_Metallic;Metallic;6;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;154;1413.993,-1206.292;Float;False;SoftLight;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;124;1137.108,-947.5413;Float;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;False;0;0;0.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1731.085,-1163.625;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;JRW/CellCore;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;7;Opaque;0;True;True;20;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.14;0,0.9667992,1,0;VertexScale;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;143;0;142;0
WireConnection;145;0;152;0
WireConnection;145;1;143;0
WireConnection;146;0;145;0
WireConnection;155;0;146;0
WireConnection;149;0;155;0
WireConnection;149;1;147;0
WireConnection;110;1;137;0
WireConnection;110;2;118;0
WireConnection;110;3;117;0
WireConnection;150;0;149;0
WireConnection;150;1;148;0
WireConnection;134;0;110;0
WireConnection;134;1;133;0
WireConnection;131;0;134;0
WireConnection;151;0;150;0
WireConnection;154;0;153;0
WireConnection;154;1;132;0
WireConnection;0;2;154;0
WireConnection;0;3;125;0
WireConnection;0;4;124;0
ASEEND*/
//CHKSM=3A95D5E33D477F41B580BB4B1ADD5EB2CD46552A