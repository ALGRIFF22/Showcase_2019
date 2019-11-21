// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JRW/ScavyCore"
{
	Properties
	{
		_Color("Color", Color) = (0,0,0,0)
		_Metallic("Metallic", Float) = 0
		_Smoothness("Smoothness", Float) = 0
		_FresnelColor("FresnelColor", Color) = (1,0,0,0)
		_FresnelPower("FresnelPower", Float) = 2.48
		_FresnelScale("FresnelScale", Float) = 1.38
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

		uniform float4 _Color;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _FresnelColor;
		uniform float _Metallic;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 _albedo131 = _Color;
			o.Albedo = _albedo131.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV110 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode110 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV110, _FresnelPower ) );
			float4 _fresnel138 = ( fresnelNode110 * _FresnelColor );
			o.Emission = _fresnel138.rgb;
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
120;40;1793;971;817.5259;1141.907;1.09308;True;True
Node;AmplifyShaderEditor.CommentaryNode;139;-537.4617,-889.7266;Float;False;1157.536;516;;6;118;117;110;138;137;136;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-487.4618,-660.8078;Float;False;Property;_FresnelPower;FresnelPower;4;0;Create;True;0;0;False;0;2.48;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-485.0775,-758.4099;Float;False;Property;_FresnelScale;FresnelScale;5;0;Create;True;0;0;False;0;1.38;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;136;-146.926,-580.7266;Float;False;Property;_FresnelColor;FresnelColor;3;0;Create;True;0;0;False;0;1,0,0,0;1,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;110;-237.9918,-805.3018;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;130;-539.9148,-1552.517;Float;False;929.4397;537.0012;;2;131;133;Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;180.0745,-839.7266;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;133;-364.1324,-1440.077;Float;False;Property;_Color;Color;0;0;Create;True;0;0;False;0;0,0,0,0;1,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;132;1119.828,-1127.353;Float;False;138;_fresnel;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;125;1136.219,-1034.878;Float;False;Property;_Metallic;Metallic;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;1115.373,-1272.723;Float;False;131;_albedo;0;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-7.69109,-1453.003;Float;True;_albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;124;1137.108,-947.5413;Float;False;Property;_Smoothness;Smoothness;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;138;377.0744,-736.7266;Float;False;_fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1543.338,-1142.883;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;JRW/ScavyCore;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;7;Opaque;0;True;True;20;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0.14;1,0,0,0;VertexScale;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;110;2;118;0
WireConnection;110;3;117;0
WireConnection;137;0;110;0
WireConnection;137;1;136;0
WireConnection;131;0;133;0
WireConnection;138;0;137;0
WireConnection;0;0;140;0
WireConnection;0;2;132;0
WireConnection;0;3;125;0
WireConnection;0;4;124;0
ASEEND*/
//CHKSM=07299287A145CEECE86D6A7EB088E755C37ADE27