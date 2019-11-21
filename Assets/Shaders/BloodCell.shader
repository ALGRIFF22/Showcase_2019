// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JRW/BloodCell"
{
	Properties
	{
		_Tint("Tint", Color) = (0,0,0,0)
		_Albedo("Albedo", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_FresnelColor("FresnelColor", Color) = (0,0,0,0)
		_FresnelPower("FresnelPower", Float) = 5
		_FresnelScale("FresnelScale", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha noshadow exclude_path:deferred 
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
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _Tint;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _FresnelColor;
		uniform float _Metallic;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 _normalMap22 = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalScale );
			o.Normal = _normalMap22;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 _albedo5 = ( tex2D( _Albedo, uv_Albedo ) * _Tint );
			o.Albedo = _albedo5.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV9 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode9 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV9, _FresnelPower ) );
			float4 _fresnel13 = ( fresnelNode9 * _FresnelColor );
			o.Emission = _fresnel13.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
732;116;1906;801;1821.598;361.5586;2.134054;True;False
Node;AmplifyShaderEditor.CommentaryNode;19;-1219.138,556.0172;Float;False;1030.84;397.814;;3;22;21;20;Normal Map;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1139.51,676.4881;Float;False;Property;_NormalScale;Normal Scale;3;0;Create;True;0;0;False;0;0;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;12;-1223.675,20.30987;Float;False;1058.738;426.508;;7;18;17;13;9;11;10;24;Fresnel;1,0,0.4762125,1;0;0
Node;AmplifyShaderEditor.SamplerNode;21;-862.0356,672.2522;Float;True;Property;_NormalMap;NormalMap;2;0;Create;True;0;0;False;0;None;57dd4a38129302a4cabd42bf70a09602;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-1171.671,308.1107;Float;False;Property;_FresnelPower;FresnelPower;7;0;Create;True;0;0;False;0;5;1.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1168.163,214.6881;Float;False;Property;_FresnelScale;FresnelScale;8;0;Create;True;0;0;False;0;1;1.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1175.301,84.27611;Float;False;22;_normalMap;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-479.0894,700.2682;Float;False;_normalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;6;-1218.981,-541.2883;Float;False;870;451;;4;2;4;3;5;Albedo;0,0.1364682,1,1;0;0
Node;AmplifyShaderEditor.FresnelNode;9;-902.9352,70.30984;Float;False;Standard;TangentNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-873.5186,256.153;Float;False;Property;_FresnelColor;FresnelColor;6;0;Create;True;0;0;False;0;0,0,0,0;0.8867924,0.246796,0.2567959,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1168.98,-491.2886;Float;True;Property;_Albedo;Albedo;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;4;-1079.979,-297.2893;Float;False;Property;_Tint;Tint;0;0;Create;True;0;0;False;0;0,0,0,0;1,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-779.9794,-368.2893;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-612.5186,190.153;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;7;-28.16019,-75.20541;Float;False;5;_albedo;0;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-49.01294,20.61218;Float;False;22;_normalMap;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-104.8621,205.3248;Float;False;Property;_Metallic;Metallic;4;0;Create;True;0;0;False;0;0;0.46;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-420.6734,194.8178;Float;False;_fresnel;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;5;-591.9796,-358.2893;Float;False;_albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-15.86206,109.3248;Float;False;13;_fresnel;0;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-102.8621,300.3248;Float;False;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;299,-87;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;JRW/BloodCell;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;1;Opaque;0.5;True;False;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;5;False;-1;10;False;-1;0;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;0;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;21;5;20;0
WireConnection;22;0;21;0
WireConnection;9;0;24;0
WireConnection;9;2;10;0
WireConnection;9;3;11;0
WireConnection;3;0;2;0
WireConnection;3;1;4;0
WireConnection;18;0;9;0
WireConnection;18;1;17;0
WireConnection;13;0;18;0
WireConnection;5;0;3;0
WireConnection;0;0;7;0
WireConnection;0;1;23;0
WireConnection;0;2;14;0
WireConnection;0;3;16;0
WireConnection;0;4;15;0
ASEEND*/
//CHKSM=9249E0FB4863AD28585871A3BAD9CE2173817393