// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Alex/Northern_Lights"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
		_WaveTiling("Wave Tiling", Vector) = (1,1,0,0)
		_WaveDirection("Wave Direction", Vector) = (1,0,0,0)
		_WaveSpeed("Wave Speed", Float) = 1
		_VODirection("VO Direction", Vector) = (0,1,0,0)
		_SecondaryTiling("Secondary Tiling", Vector) = (1,1,0,0)
		_SecondaryWaveDirection("Secondary Wave Direction", Vector) = (1,0,0,0)
		_SecondaryWaveSpeed("Secondary Wave Speed", Float) = 1
		_AlphaChannel("Alpha Channel", 2D) = "white" {}
		_AlphaTiling("Alpha Tiling", Vector) = (1,1,0,0)
		_AlphaWaveDirection("Alpha Wave Direction", Vector) = (1,0,0,0)
		_AlphaWaveSpeed("Alpha Wave Speed", Float) = 1
		_BeamIntensity("Beam Intensity", Float) = 0.5
		_WispVisibility("Wisp Visibility", Float) = 0
		_Color1("Color 1", Color) = (0,0,0,0)
		_Color2("Color 2", Color) = (0,0,0,0)
		_ColorSlider("Color Slider", Range( 0 , 2)) = 1
		_EmissionStrength("Emission Strength", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Off
		Blend One One , One One
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha noshadow nofog vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTexture;
		uniform float2 _WaveTiling;
		uniform float _WaveSpeed;
		uniform float2 _WaveDirection;
		uniform float3 _VODirection;
		uniform float4 _Color1;
		uniform float4 _Color2;
		uniform float _ColorSlider;
		uniform sampler2D _AlphaChannel;
		uniform float2 _AlphaTiling;
		uniform float _AlphaWaveSpeed;
		uniform float2 _AlphaWaveDirection;
		uniform float _WispVisibility;
		uniform float4 _MainTexture_ST;
		uniform float2 _SecondaryTiling;
		uniform float _SecondaryWaveSpeed;
		uniform float2 _SecondaryWaveDirection;
		uniform float _BeamIntensity;
		uniform float _EmissionStrength;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float time97 = _Time.y;
			float2 panner46 = ( ( time97 * _WaveSpeed ) * _WaveDirection + float2( 0,0 ));
			float2 uv_TexCoord40 = v.texcoord.xy * _WaveTiling + panner46;
			float3 vertexOffset55 = ( tex2Dlod( _MainTexture, float4( uv_TexCoord40, 0, 0.0) ).r * _VODirection );
			v.vertex.xyz += vertexOffset55;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float time97 = _Time.y;
			float pulse121 = ( ( sin( ( time97 * 2.5 ) ) + 1.0 ) / 8.0 );
			float2 panner108 = ( ( time97 * _AlphaWaveSpeed ) * _AlphaWaveDirection + float2( 0,0 ));
			float2 uv_TexCoord109 = i.uv_texcoord * _AlphaTiling + panner108;
			float2 alphaPanner110 = uv_TexCoord109;
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float2 panner68 = ( ( time97 * _SecondaryWaveSpeed ) * _SecondaryWaveDirection + float2( 0,0 ));
			float2 uv_TexCoord69 = i.uv_texcoord * _SecondaryTiling + panner68;
			float2 secondaryPannerg89 = uv_TexCoord69;
			float temp_output_87_0 = ( ( _WispVisibility * tex2D( _MainTexture, uv_MainTexture ).g ) + ( tex2D( _MainTexture, secondaryPannerg89 ).b * _BeamIntensity ) );
			float4 lerpResult126 = lerp( _Color1 , _Color2 , ( _ColorSlider * ( ( ( pulse121 * 50.0 ) * tex2D( _AlphaChannel, alphaPanner110 ).r ) + temp_output_87_0 ) ));
			float4 albedo136 = ( ( lerpResult126 * temp_output_87_0 ) * _EmissionStrength );
			o.Albedo = albedo136.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16700
2747.333;64.66667;698;1329;2345.249;3262.464;3.043268;True;False
Node;AmplifyShaderEditor.CommentaryNode;99;-3901.55,-452.7368;Float;False;594.0005;176.2074;Comment;2;96;97;Time;0.3490566,0.3490566,0.3490566,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;96;-3851.55,-386.5293;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;97;-3556.217,-402.7368;Float;False;time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;120;-3901.552,-2620.542;Float;False;1775.865;458.3906;Comment;7;121;116;115;114;118;119;117;Pulse;0.2877358,0.9404312,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;91;-3922.022,-1139.848;Float;False;1394.724;541.0625;Comment;8;70;71;66;67;68;69;89;98;Secondary Panner;0.9528302,0.8489538,0.1033731,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-3847.948,-858.3428;Float;False;97;time;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-3873.629,-699.0801;Float;False;Property;_SecondaryWaveSpeed;Secondary Wave Speed;7;0;Create;True;0;0;False;0;1;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-3931.611,-1941.799;Float;False;1779.341;682.0886;Comment;8;110;109;108;107;105;106;103;104;Alpha Panner;0.9529412,0.6273344,0.1019608,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-3843.125,-2388.52;Float;False;Constant;_Float0;Float 0;15;0;Create;True;0;0;False;0;2.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-3851.552,-2570.542;Float;False;97;time;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-3581.89,-2494.7;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-3883.218,-1501.031;Float;False;Property;_AlphaWaveSpeed;Alpha Wave Speed;11;0;Create;True;0;0;False;0;1;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-3857.537,-1660.294;Float;False;97;time;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;66;-3644.483,-1044.029;Float;False;Property;_SecondaryWaveDirection;Secondary Wave Direction;6;0;Create;True;0;0;False;0;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-3556.982,-745.4265;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;68;-3335.488,-873.3674;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;67;-3333.285,-1089.848;Float;False;Property;_SecondaryTiling;Secondary Tiling;5;0;Create;True;0;0;False;0;1,1;3.68,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SinOpNode;114;-3381.138,-2546.02;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;60;-3242.972,-464.8556;Float;False;651.5101;280;Comment;2;50;52;Texture;0.119927,0.5188679,0.3930377,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-3566.571,-1547.377;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;106;-3654.072,-1845.98;Float;False;Property;_AlphaWaveDirection;Alpha Wave Direction;10;0;Create;True;0;0;False;0;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;69;-3106.09,-994.423;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-3147.431,-2534.753;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;50;-3192.972,-414.8556;Float;True;Property;_MainTexture;Main Texture;0;0;Create;True;0;0;False;0;10f3bb562324c774f935011e9c729bca;10f3bb562324c774f935011e9c729bca;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;108;-3334.393,-1579.164;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;107;-3280.907,-1891.799;Float;False;Property;_AlphaTiling;Alpha Tiling;9;0;Create;True;0;0;False;0;1,1;2.82,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;138;-1849.662,-2794.737;Float;False;3189.543;1639.994;Comment;25;64;90;111;58;133;122;63;76;79;132;77;88;92;87;112;93;129;128;130;127;126;135;131;134;136;Albedo;0.9528302,0.4898986,0.6329277,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-2840.128,-364.6717;Float;False;texture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;116;-2723.354,-2548.049;Float;True;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;109;-2848.584,-1687.399;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-2797.298,-1010.058;Float;False;secondaryPannerg;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-2486.374,-1728.675;Float;False;alphaPanner;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-2388.768,-2545.06;Float;False;pulse;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-1799.662,-1747.241;Float;False;52;texture;1;0;OBJECT;0;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-1787.885,-1441.971;Float;False;89;secondaryPannerg;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;63;-1482.66,-1545.956;Float;True;Property;_TextureSample2;Texture Sample 2;7;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;122;-1080.303,-2585.508;Float;False;121;pulse;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-1352.971,-2273.033;Float;False;110;alphaPanner;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;58;-1475.536,-1856.739;Float;True;Property;_TextureSample1;Texture Sample 1;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;79;-1416.401,-1996.708;Float;False;Property;_WispVisibility;Wisp Visibility;13;0;Create;True;0;0;False;0;0;3.47;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-1086.145,-2424.837;Float;False;Constant;_Float1;Float 1;17;0;Create;True;0;0;False;0;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1394.258,-1269.744;Float;False;Property;_BeamIntensity;Beam Intensity;12;0;Create;True;0;0;False;0;0.5;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1015.658,-1499.674;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;92;-1052.27,-2190.993;Float;True;Property;_AlphaChannel;Alpha Channel;8;0;Create;True;0;0;False;0;None;4e0e7b4ce0a923d44ac20f567592239e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;59;-3855.771,-89.53507;Float;False;1874.912;589.517;Comment;12;49;41;48;39;46;54;40;45;57;43;55;100;Vertex Control;0.1582921,0.8113208,0.1186365,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;-887.4267,-2424.836;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-1041.417,-1815.403;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-3811.734,398.6224;Float;False;Property;_WaveSpeed;Wave Speed;3;0;Create;True;0;0;False;0;1;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-638.0536,-2146.331;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-662.9442,-1782.811;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-3817.334,254.5603;Float;False;97;time;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;41;-3606.448,183.5876;Float;False;Property;_WaveDirection;Wave Direction;2;0;Create;True;0;0;False;0;1,0;1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-409.6951,-1991.1;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-588.9313,-2355.472;Float;False;Property;_ColorSlider;Color Slider;16;0;Create;True;0;0;False;0;1;0.22;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-3603.589,366.9818;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;39;-3379.892,22.55989;Float;False;Property;_WaveTiling;Wave Tiling;1;0;Create;True;0;0;False;0;1,1;2,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;46;-3382.095,239.0409;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;128;-187.2719,-2536.738;Float;False;Property;_Color2;Color 2;15;0;Create;True;0;0;False;0;0,0,0,0;0,1,0.09169245,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-150.2474,-2264.58;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;127;-187.2719,-2744.737;Float;False;Property;_Color1;Color 1;14;0;Create;True;0;0;False;0;0,0,0,0;0.03137255,0.5606288,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;54;-3080.146,-39.53508;Float;False;52;texture;1;0;OBJECT;0;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-3123.136,123.8976;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;126;185.2237,-2435.521;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;514.2838,-1856.459;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;135;554.8878,-1563.722;Float;False;Property;_EmissionStrength;Emission Strength;17;0;Create;True;0;0;False;0;0;1.87;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;57;-2832.429,20.57268;Float;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;45;-2762.212,257.2057;Float;False;Property;_VODirection;VO Direction;4;0;Create;True;0;0;False;0;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-2468.25,107.1685;Float;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;828.3926,-1728.253;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-2229.525,33.32291;Float;False;vertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;136;1091.214,-1741.074;Float;False;albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;-158.5767,-340.4027;Float;False;136;albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-158.222,-54.25099;Float;False;55;vertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;159,-340;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Alex/Northern_Lights;False;False;False;False;False;False;False;False;False;True;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;True;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;4;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;97;0;96;0
WireConnection;118;0;117;0
WireConnection;118;1;119;0
WireConnection;71;0;98;0
WireConnection;71;1;70;0
WireConnection;68;2;66;0
WireConnection;68;1;71;0
WireConnection;114;0;118;0
WireConnection;105;0;103;0
WireConnection;105;1;104;0
WireConnection;69;0;67;0
WireConnection;69;1;68;0
WireConnection;115;0;114;0
WireConnection;108;2;106;0
WireConnection;108;1;105;0
WireConnection;52;0;50;0
WireConnection;116;0;115;0
WireConnection;109;0;107;0
WireConnection;109;1;108;0
WireConnection;89;0;69;0
WireConnection;110;0;109;0
WireConnection;121;0;116;0
WireConnection;63;0;64;0
WireConnection;63;1;90;0
WireConnection;58;0;64;0
WireConnection;77;0;63;3
WireConnection;77;1;76;0
WireConnection;92;1;111;0
WireConnection;132;0;122;0
WireConnection;132;1;133;0
WireConnection;88;0;79;0
WireConnection;88;1;58;2
WireConnection;112;0;132;0
WireConnection;112;1;92;1
WireConnection;87;0;88;0
WireConnection;87;1;77;0
WireConnection;93;0;112;0
WireConnection;93;1;87;0
WireConnection;48;0;100;0
WireConnection;48;1;49;0
WireConnection;46;2;41;0
WireConnection;46;1;48;0
WireConnection;130;0;129;0
WireConnection;130;1;93;0
WireConnection;40;0;39;0
WireConnection;40;1;46;0
WireConnection;126;0;127;0
WireConnection;126;1;128;0
WireConnection;126;2;130;0
WireConnection;131;0;126;0
WireConnection;131;1;87;0
WireConnection;57;0;54;0
WireConnection;57;1;40;0
WireConnection;43;0;57;1
WireConnection;43;1;45;0
WireConnection;134;0;131;0
WireConnection;134;1;135;0
WireConnection;55;0;43;0
WireConnection;136;0;134;0
WireConnection;0;0;137;0
WireConnection;0;11;56;0
ASEEND*/
//CHKSM=697EE3A08EDC4A09285BA6BF6FC0F096F2818A1D