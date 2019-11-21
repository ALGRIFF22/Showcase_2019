// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JRW/MacroEggCore"
{
	Properties
	{
		_GlowStrength("GlowStrength", Float) = 0
		_GlowPower("GlowPower", Float) = 1
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelPower("FresnelPower", Float) = 2.48
		_FresnelScale("FresnelScale", Float) = 1.38
		_FresnelBias("FresnelBias", Float) = 0
		_Metallic("Metallic", Float) = 0
		_Smoothness("Smoothness", Float) = 0
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
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _FresnelColor;
		uniform float _GlowStrength;
		uniform float _GlowPower;
		uniform float _Metallic;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV110 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode110 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV110, _FresnelPower ) );
			float4 temp_cast_0 = (_GlowPower).xxxx;
			float4 _emission131 = pow( ( ( fresnelNode110 * _FresnelColor ) * _GlowStrength ) , temp_cast_0 );
			o.Emission = _emission131.rgb;
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
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
85;33;1793;953;1542.951;2079.882;2.121792;True;True
Node;AmplifyShaderEditor.CommentaryNode;130;-744.6054,-1325.885;Float;False;1676.736;582.8315;;11;136;131;135;110;133;117;134;118;137;139;140;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-692.7157,-1070.925;Float;False;Property;_FresnelPower;FresnelPower;3;0;Create;True;0;0;False;0;2.48;0.59;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-690.3314,-1166.638;Float;False;Property;_FresnelScale;FresnelScale;4;0;Create;True;0;0;False;0;1.38;1.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-688.3855,-1263.175;Float;False;Property;_FresnelBias;FresnelBias;5;0;Create;True;0;0;False;0;0;0.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;133;-349.5436,-1012.346;Float;False;Property;_FresnelColor;FresnelColor;2;0;Create;True;0;0;False;0;0,0,0,0;0.4950261,0,1,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;110;-445.1349,-1275.885;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-45.36329,-899.1708;Float;False;Property;_GlowStrength;GlowStrength;0;0;Create;True;0;0;False;0;0;1.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-55.64598,-1108.481;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;173.2865,-1070.083;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;140;239.3541,-898.043;Float;False;Property;_GlowPower;GlowPower;1;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;139;440.9247,-1008.375;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;125;1136.219,-1034.878;Float;False;Property;_Metallic;Metallic;6;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;680.9247,-1099.87;Float;True;_emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;1102.417,-1180.418;Float;False;131;_emission;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;124;1137.108,-947.5413;Float;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1543.338,-1142.883;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;JRW/MacroEggCore;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;7;Opaque;0;True;True;20;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.14;0,0.9667992,1,0;VertexScale;True;False;Cylindrical;False;Relative;0;;-1;0;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;110;1;137;0
WireConnection;110;2;118;0
WireConnection;110;3;117;0
WireConnection;134;0;110;0
WireConnection;134;1;133;0
WireConnection;136;0;134;0
WireConnection;136;1;135;0
WireConnection;139;0;136;0
WireConnection;139;1;140;0
WireConnection;131;0;139;0
WireConnection;0;2;132;0
WireConnection;0;3;125;0
WireConnection;0;4;124;0
ASEEND*/
//CHKSM=E56B2FBD1000BF7A6371EBE7BE0389EA1E846B5A