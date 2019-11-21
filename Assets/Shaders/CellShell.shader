// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JRW/CellShell"
{
	Properties
	{
		_ASEOutlineWidth( "Outline Width", Float ) = 0
		[Header(Refraction)]
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelPower("FresnelPower", Float) = 2.48
		_FresnelScale("FresnelScale", Float) = 1.38
		_FresnelBias("FresnelBias", Float) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Distortion("Distortion", Range( 0 , 1)) = 0
		_Alpha("Alpha", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		uniform half _ASEOutlineWidth;
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += _ASEOutlineWidth;
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV36 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode36 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV36, _FresnelPower ) );
			float4 _emissio64 = ( fresnelNode36 * _FresnelColor );
			o.Emission = _emissio64.rgb;
			o.Normal = float3(0,0,-1);
		}
		ENDCG
		

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		GrabPass{ }
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			half ASEVFace : VFACE;
			float4 screenPos;
		};

		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _FresnelColor;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _Alpha;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform float _Distortion;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
		}

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
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV36 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode36 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV36, _FresnelPower ) );
			float4 _emissio64 = ( fresnelNode36 * _FresnelColor );
			float4 switchResult95 = (((i.ASEVFace>0)?(float4( 0,0,0,0 )):(_emissio64)));
			o.Emission = switchResult95.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = _Alpha;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha finalcolor:RefractionF fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

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
				float4 screenPos : TEXCOORD1;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
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
689;34;1263;1004;1035.452;1537.57;1.601371;True;False
Node;AmplifyShaderEditor.CommentaryNode;33;-328.1828,-859.0764;Float;False;1382.129;588.7571;;7;64;65;45;36;34;35;48;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-258.2732,-605.4702;Float;False;Property;_FresnelBias;FresnelBias;9;0;Create;True;0;0;False;0;0;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-261.1563,-514.2213;Float;False;Property;_FresnelScale;FresnelScale;8;0;Create;True;0;0;False;0;1.38;11.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-258.6598,-423.4615;Float;False;Property;_FresnelPower;FresnelPower;7;0;Create;True;0;0;False;0;2.48;-3.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;36;52.88027,-782.5146;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;45;50.28655,-526.2481;Float;False;Property;_FresnelColor;FresnelColor;6;0;Create;True;0;0;False;0;0,0,0,0;0.368627,0.6257393,0.8,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;463.8188,-642.7286;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;21;-1601.818,129.66;Float;False;1040.546;335.6187;;2;15;22;Refraction w/ Distortion;1,0,0.8579731,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-374.0132,379.2953;Float;False;64;_emissio;0;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;17;-1625.884,-401.6861;Float;False;1030.84;397.814;;3;20;19;18;Normal Map;0,0.4219825,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;716.0084,-617.7384;Float;False;_emissio;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1551.818,236.8987;Float;False;Property;_Distortion;Distortion;12;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;89;-537.0593,-1739.618;Float;False;1739.191;584.2909;;11;73;74;76;77;78;81;80;82;83;100;92;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;32;153.8266,356.4545;Float;False;Property;_Smoothness;Smoothness;11;0;Create;True;0;0;False;0;0;0.64;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-885.8359,-257.4351;Float;False;_normalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OutlineNode;99;166.1426,473.4814;Float;False;2;False;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;73;-502.1326,-1386.265;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-904.7296,254.6241;Float;False;_refraction;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;81;464.3366,-1542.127;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;74;-257.2156,-1437.035;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;31;122.2189,260.4215;Float;False;Property;_Metallic;Metallic;10;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;92;-493.6129,-1685.88;Float;True;Property;_Normals;Normals;14;0;Create;True;0;0;False;0;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;19;-1268.782,-285.4511;Float;True;Property;_NormalMap;NormalMap;0;0;Create;True;0;0;False;0;None;233518d21026a2e4397650a59649e438;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;78;174.9375,-1450.126;Float;False;Property;_RimPower;RimPower;5;0;Create;True;0;0;False;0;0;2.4;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;706.7368,-1526.927;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;100;274.4199,-1625.24;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;80;458.1372,-1362.328;Float;False;Property;_RimColor;RimColor;4;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;959.1313,-1465.938;Float;False;_rimLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;76;-72.66214,-1583.326;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;95;108.1872,91.34605;Float;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;57;182.3996,748.7805;Float;False;Property;_Alpha;Alpha;13;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1546.256,-281.2151;Float;False;Property;_NormalScale;Normal Scale;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;77;102.5367,-1607.826;Float;False;1;0;FLOAT;1.23;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;246.5069,654.6799;Float;False;22;_refraction;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;648.4878,50.34979;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;JRW/CellShell;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;7;Custom;0.5;True;True;0;True;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0.8641715,0,1,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;3;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;36;1;48;0
WireConnection;36;2;35;0
WireConnection;36;3;34;0
WireConnection;65;0;36;0
WireConnection;65;1;45;0
WireConnection;64;0;65;0
WireConnection;20;0;19;0
WireConnection;99;0;66;0
WireConnection;22;0;15;0
WireConnection;81;0;100;0
WireConnection;81;1;78;0
WireConnection;74;0;73;0
WireConnection;19;5;18;0
WireConnection;82;0;81;0
WireConnection;82;1;80;0
WireConnection;100;0;77;0
WireConnection;83;0;82;0
WireConnection;76;0;92;0
WireConnection;76;1;74;0
WireConnection;95;1;66;0
WireConnection;77;0;76;0
WireConnection;0;2;95;0
WireConnection;0;3;31;0
WireConnection;0;4;32;0
WireConnection;0;8;23;0
WireConnection;0;9;57;0
WireConnection;0;11;99;0
ASEEND*/
//CHKSM=36286DFB6D26D96F6EFFEA3056ED6D8BD590F367