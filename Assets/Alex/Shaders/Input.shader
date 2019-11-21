// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Alex/Input"
{
	Properties
	{
		_NormalMap("Normal Map", 2D) = "white" {}
		[HDR]_BaseColor("Base Color", Color) = (0,0,0,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HDR]_GlowColor("Glow Color", Color) = (0.5490196,0,0,0)
		[Toggle]_Reverse("Reverse", Float) = 1
		_Slice("Slice", Range( 0 , 1)) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0.5
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_SizeMax("Size Max", Float) = 15
		_SizeMin("Size Min", Float) = -20
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float4 _BaseColor;
		uniform float4 _GlowColor;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _SizeMin;
		uniform float _SizeMax;
		uniform float _Slice;
		uniform float _Reverse;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float4 Normal131 = tex2D( _NormalMap, uv_NormalMap );
			o.Normal = Normal131.rgb;
			o.Albedo = _BaseColor.rgb;
			float mulTime144 = _Time.y * 4.0;
			float Pulse147 = ( ( sin( mulTime144 ) + 3.0 ) / 2.0 );
			float4 Emission54 = ( _GlowColor * Pulse147 );
			o.Emission = Emission54.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 transform29 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float Slice135 = _Slice;
			float lerpResult125 = lerp( _SizeMin , _SizeMax , Slice135);
			float Y_Gradient27 = saturate( ( ( transform29.z + lerpResult125 ) / lerp(10.0,-10.0,_Reverse) ) );
			float temp_output_170_0 = ( 2.0 * Y_Gradient27 );
			float Dissolve174 = ( ( Y_Gradient27 - temp_output_170_0 ) + ( 1.0 - temp_output_170_0 ) );
			clip( Dissolve174 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16700
4234.667;18;751;1317;3310.658;735.5462;1.313775;True;False
Node;AmplifyShaderEditor.CommentaryNode;143;-2463.319,-1498.185;Float;False;635.9204;277.9871;Comment;2;26;135;Slice;1,0.04245281,0.9740348,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2413.319,-1448.185;Float;False;Property;_Slice;Slice;5;0;Create;True;0;0;False;0;0;0.101;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;32;-2972.905,-472.6543;Float;False;1715.657;815.0305;Comment;13;27;57;30;77;25;31;78;29;24;125;126;127;136;Y-Gradient;0.9339623,0.9260758,0.3568441,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;-2076.066,-1335.198;Float;False;Slice;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-2813.156,-20.38197;Float;False;Property;_SizeMax;Size Max;8;0;Create;True;0;0;False;0;15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-2808.156,-150.382;Float;False;Property;_SizeMin;Size Min;9;0;Create;True;0;0;False;0;-20;-3.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;-2870.024,74.5643;Float;False;135;Slice;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;24;-2950.932,-405.0423;Float;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;31;-2577.315,129.0213;Float;False;Constant;_Positive;Positive;7;0;Create;True;0;0;False;0;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2577.199,232.7712;Float;False;Constant;_Negative;Negative;8;0;Create;True;0;0;False;0;-10;-10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;125;-2528.156,-135.6199;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;29;-2636.728,-384.1058;Float;True;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;148;-2954.092,-898.8572;Float;False;1288.211;306.8732;Comment;5;144;142;145;146;147;Pulse;1,0.8741453,0,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-2239.875,-379.1084;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;77;-2275.091,-23.46641;Float;False;Property;_Reverse;Reverse;4;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;144;-2904.092,-800.4452;Float;False;1;0;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;30;-1975.465,-371.2256;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;142;-2667.842,-844.9841;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;57;-1720.358,-399.8277;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;145;-2472.257,-848.8572;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;167;-2435.118,562.1164;Float;False;1528.026;670.3469;Comment;8;171;172;170;176;168;174;173;177;Opacity Mask;0.4607956,0.8962264,0.4949994,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-1483.294,-414.2666;Float;True;Y_Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;146;-2251.496,-844.9842;Float;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-2360.351,982.9948;Float;False;27;Y_Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-2330.341,770.6957;Float;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;147;-1914.55,-722.9858;Float;False;Pulse;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-2056.296,851.5782;Float;True;2;2;0;FLOAT;1.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1423.042,-1470.803;Float;False;802.2236;460.475;Comment;4;149;55;54;141;Glow;0.4877625,0.8651212,0.9150943,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;-2385.118,612.1166;Float;False;27;Y_Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;132;-429.7035,-1110.216;Float;False;701.4559;280;Comment;2;130;131;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;55;-1333.892,-1386.007;Float;False;Property;_GlowColor;Glow Color;3;1;[HDR];Create;True;0;0;False;0;0.5490196,0,0,0;0,1.498039,1.490196,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;171;-1709.171,977.0615;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-1300.042,-1157.27;Float;False;147;Pulse;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;172;-1722.164,655.5558;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-997.4427,-1263.547;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;173;-1371.29,810.2744;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;130;-379.7035,-1060.216;Float;True;Property;_NormalMap;Normal Map;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-1133.229,680.619;Float;False;Dissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;23.08586,-984.6932;Float;False;Normal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-846.2467,-1378.853;Float;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-120.2142,128.7864;Float;False;Property;_Metallic;Metallic;6;0;Create;True;0;0;False;0;0.5;0.835;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;-118.8181,356.334;Float;False;174;Dissolve;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;-56.31012,-88.10005;Float;False;131;Normal;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;129;-94.23664,-347.9952;Float;False;Property;_BaseColor;Base Color;1;1;[HDR];Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;18;-39.06428,34.5355;Float;False;54;Emission;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-167.1273,220.7726;Float;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;False;0;0.5;0.826;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;325.6793,-19.07789;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Alex/Input;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;135;0;26;0
WireConnection;125;0;126;0
WireConnection;125;1;127;0
WireConnection;125;2;136;0
WireConnection;29;0;24;0
WireConnection;25;0;29;3
WireConnection;25;1;125;0
WireConnection;77;0;31;0
WireConnection;77;1;78;0
WireConnection;30;0;25;0
WireConnection;30;1;77;0
WireConnection;142;0;144;0
WireConnection;57;0;30;0
WireConnection;145;0;142;0
WireConnection;27;0;57;0
WireConnection;146;0;145;0
WireConnection;147;0;146;0
WireConnection;170;0;168;0
WireConnection;170;1;176;0
WireConnection;171;0;170;0
WireConnection;172;0;177;0
WireConnection;172;1;170;0
WireConnection;141;0;55;0
WireConnection;141;1;149;0
WireConnection;173;0;172;0
WireConnection;173;1;171;0
WireConnection;174;0;173;0
WireConnection;131;0;130;0
WireConnection;54;0;141;0
WireConnection;0;0;129;0
WireConnection;0;1;133;0
WireConnection;0;2;18;0
WireConnection;0;3;134;0
WireConnection;0;4;119;0
WireConnection;0;10;178;0
ASEEND*/
//CHKSM=F6B778B7407E2A1AFEB9B385BA23B627FB34A5F9