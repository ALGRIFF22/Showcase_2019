// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Alex/Token"
{
	Properties
	{
		[HDR]_AlbeddoColor("Albeddo Color", Color) = (0,0,0,0)
		[HDR]_AlbedoSecondaryColor("Albedo Secondary Color", Color) = (0,0.7498157,1,0)
		_BaseTexture("Base Texture", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalsSecondary("Normals Secondary", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0.5
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.5
		_Opacity("Opacity", Range( 0 , 1)) = 0.5
		[HDR]_GlowColor("Glow Color", Color) = (0.5490196,0,0,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_GlowSpeed("Glow Speed", Float) = 0
		_Slice("Slice", Range( 0 , 1)) = 1.57226
		_SizeMin("Size Min", Float) = 0
		_SizeMax("Size Max", Float) = 0
		_Strength("Strength", Float) = 0
		[Toggle]_Reverse("Reverse", Float) = 0
		_NoiseScale("NoiseScale", Vector) = (0,0,0,0)
		_ThicknessX("ThicknessX", Float) = 0
		_ThicknessY("ThicknessY", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _SizeMin;
		uniform float _SizeMax;
		uniform float _Slice;
		uniform float _Reverse;
		uniform float _Strength;
		uniform float _ThicknessY;
		uniform float2 _NoiseScale;
		uniform float _ThicknessX;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _NormalsSecondary;
		uniform float4 _NormalsSecondary_ST;
		uniform float _NormalScale;
		uniform float4 _AlbedoSecondaryColor;
		uniform sampler2D _BaseTexture;
		uniform float4 _BaseTexture_ST;
		uniform float4 _AlbeddoColor;
		uniform float _GlowSpeed;
		uniform float4 _GlowColor;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _Opacity;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 transform29 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float lerpResult166 = lerp( _SizeMin , _SizeMax , _Slice);
			float Slice169 = lerpResult166;
			float Y_Gradient27 = saturate( ( ( transform29.y + Slice169 ) / ( _Reverse )?( -10.0 ):( 10.0 ) ) );
			float2 panner111 = ( 1.0 * _Time.y * float2( -6,1 ) + float2( 0,0 ));
			float2 uv_TexCoord100 = v.texcoord.xy * _NoiseScale + panner111;
			float alternateNoise101 = ( step( _ThicknessY , frac( uv_TexCoord100.x ) ) + step( frac( uv_TexCoord100.y ) , _ThicknessX ) );
			float3 VertexOffset70 = ( ( ( ase_vertex3Pos * Y_Gradient27 ) * _Strength ) * alternateNoise101 );
			v.vertex.xyz += VertexOffset70;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float2 uv_NormalsSecondary = i.uv_texcoord * _NormalsSecondary_ST.xy + _NormalsSecondary_ST.zw;
			float3 Normals64 = ( UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) + ( UnpackNormal( tex2D( _NormalsSecondary, uv_NormalsSecondary ) ) * _NormalScale ) );
			o.Normal = Normals64;
			float2 uv_BaseTexture = i.uv_texcoord * _BaseTexture_ST.xy + _BaseTexture_ST.zw;
			float4 tex2DNode145 = tex2D( _BaseTexture, uv_BaseTexture );
			float mulTime140 = _Time.y * _GlowSpeed;
			float4 Albedo61 = ( ( ( _AlbedoSecondaryColor * tex2DNode145 ) + ( ( 1.0 - tex2DNode145 ) * _AlbeddoColor ) ) + ( _AlbeddoColor * ( ( ( sin( mulTime140 ) + 4.0 ) / 2.0 ) * ( step( 0.5 , frac( i.uv_texcoord.x ) ) / 2.0 ) ) ) );
			o.Albedo = Albedo61.rgb;
			float2 panner111 = ( 1.0 * _Time.y * float2( -6,1 ) + float2( 0,0 ));
			float2 uv_TexCoord100 = i.uv_texcoord * _NoiseScale + panner111;
			float alternateNoise101 = ( step( _ThicknessY , frac( uv_TexCoord100.x ) ) + step( frac( uv_TexCoord100.y ) , _ThicknessX ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 transform29 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float lerpResult166 = lerp( _SizeMin , _SizeMax , _Slice);
			float Slice169 = lerpResult166;
			float Y_Gradient27 = saturate( ( ( transform29.y + Slice169 ) / ( _Reverse )?( -10.0 ):( 10.0 ) ) );
			float4 Emission54 = ( _GlowColor * ( alternateNoise101 * Y_Gradient27 ) );
			o.Emission = Emission54.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = _Opacity;
			float temp_output_40_0 = ( 2.0 * Y_Gradient27 );
			float Dissolve36 = ( ( ( Y_Gradient27 * alternateNoise101 ) - temp_output_40_0 ) + ( 1.0 - temp_output_40_0 ) );
			clip( Dissolve36 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
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
				float3 worldPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
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
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
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
Version=17200
201;75;480;608;943.2424;2681.912;3.389891;False;False
Node;AmplifyShaderEditor.CommentaryNode;170;-4883.665,-382.7455;Inherit;False;949.3313;462.5497;Comment;5;26;166;167;168;169;Slice;0.5188679,0.09055714,0.09055714,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;167;-4720.531,-332.7455;Float;False;Property;_SizeMin;Size Min;13;0;Create;True;0;0;False;0;0;-20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-4833.665,-35.19579;Float;False;Property;_Slice;Slice;12;0;Create;True;0;0;False;0;1.57226;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;117;-4251.27,-2339.001;Inherit;False;2034.567;791.833;Comment;12;108;105;109;102;106;107;110;101;100;104;111;112;Grid;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-4731.59,-200.0223;Float;False;Property;_SizeMax;Size Max;14;0;Create;True;0;0;False;0;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;32;-3571.696,-448.981;Inherit;False;1655.697;661.3397;Comment;10;27;57;30;25;77;29;171;31;78;24;Y-Gradient;0.9339623,0.9260758,0.3568441,1;0;0
Node;AmplifyShaderEditor.LerpOp;166;-4419.689,-230.991;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;112;-4201.27,-1885.397;Float;False;Constant;_SpeedGrid;SpeedGrid;16;0;Create;True;0;0;False;0;-6,1;-2,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PosVertexDataNode;24;-3549.724,-381.369;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;104;-3971.094,-2098.537;Float;False;Property;_NoiseScale;NoiseScale;17;0;Create;True;0;0;False;0;0,0;20,20;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;111;-3957.557,-1885.689;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;169;-4183,-195.5981;Float;False;Slice;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;100;-3741.546,-2013.21;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;29;-3242.414,-377.6703;Inherit;True;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;31;-3146.802,-42.09378;Float;False;Constant;_Positive;Positive;6;0;Create;True;0;0;False;0;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-3146.686,61.65607;Float;False;Constant;_Negative;Negative;6;0;Create;True;0;0;False;0;-10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-3397.722,-91.63167;Inherit;False;169;Slice;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;77;-2903.982,-116.4172;Float;False;Property;_Reverse;Reverse;16;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;102;-3427.191,-1900.059;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-3423.81,-2289.001;Float;False;Property;_ThicknessY;ThicknessY;19;0;Create;True;0;0;False;0;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-2917.96,-357.1589;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-876.1856,-2175.842;Float;False;Property;_GlowSpeed;Glow Speed;11;0;Create;True;0;0;False;0;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;105;-3433.028,-2126.146;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-3402.302,-1662.166;Float;False;Property;_ThicknessX;ThicknessX;18;0;Create;True;0;0;False;0;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;140;-663.3404,-2061.506;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;107;-3122.684,-2198.355;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;106;-3118.075,-1952.538;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;155;-577.0621,-1546.149;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;30;-2653.552,-349.2761;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;57;-2398.445,-377.8782;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-2787.76,-2139.972;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;156;-251.6508,-1608.821;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;141;-372.3579,-2030.625;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-393.3199,-1755.851;Float;False;Constant;_Float0;Float 0;13;0;Create;True;0;0;False;0;0.5;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;157;0.6740289,-1760.483;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-2161.38,-392.3171;Float;True;Y_Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;47;-4180.558,-1320.591;Inherit;False;1532.852;721.0179;Comment;10;46;36;45;42;40;34;44;41;28;116;Opacity Mask;0.4607956,0.8962264,0.4949994,1;0;0
Node;AmplifyShaderEditor.SamplerNode;145;-790.8512,-2890.633;Inherit;True;Property;_BaseTexture;Base Texture;2;0;Create;True;0;0;False;0;-1;b2379fa189100bd41a34ac31f3d39c07;b2379fa189100bd41a34ac31f3d39c07;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-160.1749,-2064.184;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;76;-2868.755,569.7619;Inherit;False;1286.692;325.121;Comment;8;75;73;68;69;72;74;70;67;Vert Offset;1,0.495283,0.7404323,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-2473.606,-2184.853;Float;False;alternateNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;146;-313.9217,-3078.511;Float;False;Property;_AlbedoSecondaryColor;Albedo Secondary Color;1;1;[HDR];Create;True;0;0;False;0;0,0.7498157,1,0;4.237095,4.170544,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;67;-2810.358,619.7618;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;147;-311.5704,-2739.867;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;59;-469.3224,-2492.097;Float;False;Property;_AlbeddoColor;Albeddo Color;0;1;[HDR];Create;True;0;0;False;0;0,0,0,0;2.670157,2.524416,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;65;-1199.547,-603.6835;Inherit;False;804.8325;586.91;Comment;6;151;5;64;152;153;154;Normals;0.5588836,0.4097098,0.8773585,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;139;126.2225,-2077.107;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;-4130.558,-1270.591;Inherit;False;27;Y_Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-4004.45,-805.6083;Inherit;False;27;Y_Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;58;-1283.586,-1168.493;Inherit;False;1024.096;499.8789;Comment;6;52;55;53;56;54;115;Glow;0.4877625,0.8651212,0.9150943,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;162;233.3567,-1771.216;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-2790.156,787.3829;Inherit;False;27;Y_Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;-4011.14,-1088.217;Inherit;False;101;alternateNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-3967.201,-902.088;Float;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-1233.586,-783.6133;Inherit;False;27;Y_Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2483.105,763.1999;Float;False;Property;_Strength;Strength;15;0;Create;True;0;0;False;0;0;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-1245.65,-1003.073;Inherit;False;101;alternateNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;425.134,-2034.916;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;57.48943,-2898.505;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-3693.033,-1213.509;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;17.51021,-2621.218;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-2519.858,635.0235;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-3739.001,-852.572;Inherit;True;2;2;0;FLOAT;1.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-1053.005,-104.7685;Float;False;Property;_NormalScale;Normal Scale;5;0;Create;True;0;0;False;0;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;151;-1162.446,-318.8917;Inherit;True;Property;_NormalsSecondary;Normals Secondary;4;0;Create;True;0;0;False;0;-1;2b6288a68a8cf2941a59056af1ad295d;14afe250872801e4f8434561b70a3b6d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;-841.2609,-270.1192;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-945.4814,-868.3504;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;150;302.4722,-2597.002;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;545.0024,-2247.343;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;55;-960.5573,-1118.493;Float;False;Property;_GlowColor;Glow Color;9;1;[HDR];Create;True;0;0;False;0;0.5490196,0,0,0;23.96863,2.363421,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-2302.56,639.0919;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;45;-3391.876,-746.3926;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-2242.807,788.9832;Inherit;False;101;alternateNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1149.547,-553.6835;Inherit;True;Property;_NormalMap;Normal Map;3;0;Create;True;0;0;False;0;-1;14afe250872801e4f8434561b70a3b6d;2b6288a68a8cf2941a59056af1ad295d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;42;-3400.043,-1048.596;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-3116.731,-1072.433;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-2065.94,657.2717;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-716.3555,-398.5932;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-704.8173,-958.9534;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;161;763.0732,-2466.219;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-2878.671,-1202.089;Float;False;Dissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;1187.489,-2321.771;Float;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-1837.231,669.7258;Float;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-599.3644,-527.8395;Float;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-508.1562,-908.0692;Float;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-126.6283,131.086;Float;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;False;0;0.5;0.9;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-46.21561,-141.7145;Inherit;False;54;Emission;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;46.41216,408.4938;Inherit;False;36;Dissolve;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-150.7474,270.606;Float;False;Property;_Opacity;Opacity;8;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-59.0218,-259.6525;Inherit;False;64;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-161.5521,-1.232239;Float;False;Property;_Metallic;Metallic;6;0;Create;True;0;0;False;0;0.5;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-55.04531,-351.2188;Inherit;False;61;Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;84.68947,542.957;Inherit;False;70;VertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;325.6793,-19.07789;Float;False;True;2;ASEMaterialInspector;0;0;Standard;Alex/Token;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;10;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;166;0;167;0
WireConnection;166;1;168;0
WireConnection;166;2;26;0
WireConnection;111;2;112;0
WireConnection;169;0;166;0
WireConnection;100;0;104;0
WireConnection;100;1;111;0
WireConnection;29;0;24;0
WireConnection;77;0;31;0
WireConnection;77;1;78;0
WireConnection;102;0;100;2
WireConnection;25;0;29;2
WireConnection;25;1;171;0
WireConnection;105;0;100;1
WireConnection;140;0;144;0
WireConnection;107;0;109;0
WireConnection;107;1;105;0
WireConnection;106;0;102;0
WireConnection;106;1;108;0
WireConnection;30;0;25;0
WireConnection;30;1;77;0
WireConnection;57;0;30;0
WireConnection;110;0;107;0
WireConnection;110;1;106;0
WireConnection;156;0;155;1
WireConnection;141;0;140;0
WireConnection;157;0;158;0
WireConnection;157;1;156;0
WireConnection;27;0;57;0
WireConnection;142;0;141;0
WireConnection;101;0;110;0
WireConnection;147;0;145;0
WireConnection;139;0;142;0
WireConnection;162;0;157;0
WireConnection;160;0;139;0
WireConnection;160;1;162;0
WireConnection;149;0;146;0
WireConnection;149;1;145;0
WireConnection;34;0;28;0
WireConnection;34;1;116;0
WireConnection;148;0;147;0
WireConnection;148;1;59;0
WireConnection;69;0;67;0
WireConnection;69;1;68;0
WireConnection;40;0;44;0
WireConnection;40;1;41;0
WireConnection;154;0;151;0
WireConnection;154;1;153;0
WireConnection;53;0;115;0
WireConnection;53;1;52;0
WireConnection;150;0;149;0
WireConnection;150;1;148;0
WireConnection;163;0;59;0
WireConnection;163;1;160;0
WireConnection;72;0;69;0
WireConnection;72;1;73;0
WireConnection;45;0;40;0
WireConnection;42;0;34;0
WireConnection;42;1;40;0
WireConnection;46;0;42;0
WireConnection;46;1;45;0
WireConnection;74;0;72;0
WireConnection;74;1;75;0
WireConnection;152;0;5;0
WireConnection;152;1;154;0
WireConnection;56;0;55;0
WireConnection;56;1;53;0
WireConnection;161;0;150;0
WireConnection;161;1;163;0
WireConnection;36;0;46;0
WireConnection;61;0;161;0
WireConnection;70;0;74;0
WireConnection;64;0;152;0
WireConnection;54;0;56;0
WireConnection;0;0;62;0
WireConnection;0;1;66;0
WireConnection;0;2;18;0
WireConnection;0;3;138;0
WireConnection;0;4;119;0
WireConnection;0;9;118;0
WireConnection;0;10;37;0
WireConnection;0;11;71;0
ASEEND*/
//CHKSM=A8485DB5D334CB99F7EE8CB3F705BEE1CDBAD571