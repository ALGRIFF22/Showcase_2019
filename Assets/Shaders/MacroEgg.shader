// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JRW/MacroEgg"
{
	Properties
	{
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 0
		_GlowStrength("GlowStrength", Float) = 0
		_GlowPower("GlowPower", Float) = 0
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelPower("FresnelPower", Float) = 2.48
		_FresnelScale("FresnelScale", Float) = 1.38
		_FresnelBias("FresnelBias", Float) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[Header(Refraction)]
		_Distortion("Distortion", Range( 0 , 1)) = 0
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZTest LEqual
		GrabPass{ }
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
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
			float4 screenPos;
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
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform float _Distortion;

		inline float4 Refraction( Input i, SurfaceOutputStandard o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( ( ( ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) ) * ( 1.0 / ( screenPos.z + 1.0 ) ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) ) );
			float2 cameraRefraction = float2( refractionOffset.x, -( refractionOffset.y * _ProjectionParams.x ) );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutputStandard o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			float _refraction22 = _Distortion;
			color.rgb = color.rgb + Refraction( i, o, _refraction22, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 _normalMap20 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			o.Normal = _normalMap20;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV36 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode36 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV36, _FresnelPower ) );
			float4 temp_cast_0 = (_GlowPower).xxxx;
			float4 _emission38 = pow( ( ( fresnelNode36 * _FresnelColor ) * _GlowStrength ) , temp_cast_0 );
			float4 temp_output_30_0 = _emission38;
			o.Emission = temp_output_30_0.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = temp_output_30_0.r;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha finalcolor:RefractionF fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
				float4 screenPos : TEXCOORD2;
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
				o.screenPos = ComputeScreenPos( o.pos );
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
				surfIN.screenPos = IN.screenPos;
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
38;14;1801;997;2155.019;1245.262;2.134275;True;False
Node;AmplifyShaderEditor.CommentaryNode;33;-1014.461,-986.7614;Float;False;2070.641;833.2419;;11;45;38;49;46;47;36;48;35;34;51;52;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-951.5959,-864.1829;Float;False;Property;_FresnelBias;FresnelBias;7;0;Create;True;0;0;False;0;0;0.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-955.8879,-774.3427;Float;False;Property;_FresnelScale;FresnelScale;6;0;Create;True;0;0;False;0;1.38;20.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-956.2092,-684.9929;Float;False;Property;_FresnelPower;FresnelPower;5;0;Create;True;0;0;False;0;2.48;1.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;45;-379.9446,-634.5839;Float;False;Property;_FresnelColor;FresnelColor;4;0;Create;True;0;0;False;0;0,0,0,0;0.2601889,0,0.764151,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;36;-714.9909,-936.7614;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-69.21546,-687.3038;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;17;-1433.799,-401.6861;Float;False;1030.84;397.814;;3;20;19;18;Normal Map;0,0.4219825,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-93.39841,-471.185;Float;False;Property;_GlowStrength;GlowStrength;2;0;Create;True;0;0;False;0;0;1.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;199.8529,-596.2817;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1354.171,-281.2151;Float;False;Property;_NormalScale;Normal Scale;1;0;Create;True;0;0;False;0;0;0.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;21;-1399.062,110.4515;Float;False;979.7655;282.132;;2;15;22;Refraction w/ Distortion;1,0,0.8579731,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;52;173.4749,-404.3574;Float;False;Property;_GlowPower;GlowPower;3;0;Create;True;0;0;False;0;0;0.85;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;51;427.4536,-540.951;Float;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1349.062,217.6902;Float;False;Property;_Distortion;Distortion;11;0;Create;True;0;0;False;0;0;0.94;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;19;-1076.697,-285.4511;Float;True;Property;_NormalMap;NormalMap;0;0;Create;True;0;0;False;0;None;233518d21026a2e4397650a59649e438;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;679.9175,-746.1091;Float;True;_emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-701.9732,235.4156;Float;False;_refraction;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-0.01847839,328.4164;Float;False;Property;_Smoothness;Smoothness;9;0;Create;True;0;0;False;0;0;0.833;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;1.534275,-40.14989;Float;False;20;_normalMap;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;96.31207,426.3425;Float;False;22;_refraction;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-4.801447,248.3105;Float;False;Property;_Metallic;Metallic;8;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;15.38287,70.59953;Float;False;38;_emission;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-693.7509,-257.4351;Float;False;_normalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;448,-62;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;JRW/MacroEgg;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;7;Custom;0.5;True;True;0;True;Opaque;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;12;-1;10;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;36;1;48;0
WireConnection;36;2;35;0
WireConnection;36;3;34;0
WireConnection;46;0;36;0
WireConnection;46;1;45;0
WireConnection;49;0;46;0
WireConnection;49;1;47;0
WireConnection;51;0;49;0
WireConnection;51;1;52;0
WireConnection;19;5;18;0
WireConnection;38;0;51;0
WireConnection;22;0;15;0
WireConnection;20;0;19;0
WireConnection;0;1;24;0
WireConnection;0;2;30;0
WireConnection;0;3;31;0
WireConnection;0;4;32;0
WireConnection;0;8;23;0
WireConnection;0;9;30;0
ASEEND*/
//CHKSM=88280739B234976BFF677D3CFBBC6BA7EDDA9BD6