// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JRW/HumanBody"
{
	Properties
	{
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 0
		_GlowStrength("GlowStrength", Float) = 0
		_GlowPower("GlowPower", Float) = 1
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelPower("FresnelPower", Float) = 2.48
		_FresnelScale("FresnelScale", Float) = 1.38
		_FresnelBias("FresnelBias", Float) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Alpha("Alpha", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZTest Always
			ZWrite On
		}

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite On
		ZTest LEqual
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
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
		};

		uniform float _NormalScale;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _FresnelColor;
		uniform float _GlowStrength;
		uniform float _GlowPower;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _Alpha;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 _normalMap20 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			o.Normal = _normalMap20;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV36 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode36 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV36, _FresnelPower ) );
			float4 temp_cast_0 = (_GlowPower).xxxx;
			float4 _fresnel38 = pow( ( ( fresnelNode36 * _FresnelColor ) * _GlowStrength ) , temp_cast_0 );
			o.Emission = _fresnel38.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = _Alpha;
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
			sampler3D _DitherMaskLOD;
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
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
808;44;1793;965;1770.409;132.7971;1.044827;True;True
Node;AmplifyShaderEditor.CommentaryNode;17;-1433.799,-401.6861;Float;False;1030.84;397.814;;3;20;19;18;Normal Map;0,0.4219825,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1354.171,-281.2151;Float;False;Property;_NormalScale;Normal Scale;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;-1076.697,-285.4511;Float;True;Property;_NormalMap;NormalMap;0;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;33;-992.3961,-1159.544;Float;False;2041.159;637.0902;;12;38;53;47;46;45;36;35;52;34;51;54;55;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-964.0012,-941.7484;Float;False;Property;_FresnelBias;FresnelBias;7;0;Create;True;0;0;False;0;0;0.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-957.1118,-813.7519;Float;False;Property;_FresnelScale;FresnelScale;6;0;Create;True;0;0;False;0;1.38;9.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-953.796,-718.0506;Float;False;Property;_FresnelPower;FresnelPower;5;0;Create;True;0;0;False;0;2.48;1.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-693.7509,-257.4351;Float;False;_normalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-952.5991,-1082.349;Float;False;20;_normalMap;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;45;-593.663,-855.5811;Float;False;Property;_FresnelColor;FresnelColor;4;0;Create;True;0;0;False;0;0,0,0,0;0,0.5929484,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;36;-689.9259,-1088.544;Float;True;Standard;TangentNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.82;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-223.2941,-788.0857;Float;False;Property;_GlowStrength;GlowStrength;2;0;Create;True;0;0;False;0;0;0.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-211.7832,-944.7543;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;120.8991,-884.7485;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;55;200.6992,-716.5986;Float;False;Property;_GlowPower;GlowPower;3;0;Create;True;0;0;False;0;1;1.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;54;409.6991,-841.9988;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-52.688,47.58714;Float;False;38;_fresnel;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;703.2595,-955.9769;Float;True;_fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-22.41841,462.7545;Float;False;Property;_Alpha;Alpha;10;0;Create;True;0;0;False;0;0;0.134;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-82.0682,-43.99533;Float;False;20;_normalMap;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-60.9487,252.2537;Float;False;Property;_Smoothness;Smoothness;9;0;Create;True;0;0;False;0;0;0.839;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-43.3906,174.1787;Float;False;Property;_Metallic;Metallic;8;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;448,-62;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;JRW/HumanBody;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;1;False;-1;3;False;-1;False;0;False;-1;0;False;-1;True;7;Custom;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;11;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;19;5;18;0
WireConnection;20;0;19;0
WireConnection;36;0;51;0
WireConnection;36;1;52;0
WireConnection;36;2;35;0
WireConnection;36;3;34;0
WireConnection;46;0;36;0
WireConnection;46;1;45;0
WireConnection;53;0;46;0
WireConnection;53;1;47;0
WireConnection;54;0;53;0
WireConnection;54;1;55;0
WireConnection;38;0;54;0
WireConnection;0;1;24;0
WireConnection;0;2;30;0
WireConnection;0;3;31;0
WireConnection;0;4;32;0
WireConnection;0;9;56;0
ASEEND*/
//CHKSM=5A1107749641C48414A21F437EFDE734F88CA7D8