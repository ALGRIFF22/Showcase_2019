// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Alex/HDRPToken"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HDR]_AlbeddoColor1("Albeddo Color", Color) = (0,0,0,0)
		[HDR]_AlbedoSecondaryColor1("Albedo Secondary Color", Color) = (0,0.7498157,1,0)
		_BaseTexture1("Base Texture", 2D) = "white" {}
		_NormalMap1("Normal Map", 2D) = "bump" {}
		_NormalsSecondary1("Normals Secondary", 2D) = "bump" {}
		_NormalScale1("Normal Scale", Float) = 0
		_Metallic1("Metallic", Range( 0 , 1)) = 0.5
		_Smoothness1("Smoothness", Range( 0 , 1)) = 0.5
		_Opacity1("Opacity", Range( 0 , 1)) = 0.5
		[HDR]_GlowColor1("Glow Color", Color) = (0.5490196,0,0,0)
		_GlowSpeed1("Glow Speed", Float) = 0
		_Slice1("Slice", Range( 0 , 1)) = 1.57226
		_SizeMin1("Size Min", Float) = 0
		_SizeMax1("Size Max", Float) = 0
		_Strength1("Strength", Float) = 0
		[Toggle]_Reverse1("Reverse", Float) = 0
		_NoiseScale1("NoiseScale", Vector) = (0,0,0,0)
		_ThicknessX1("ThicknessX", Float) = 0
		_ThicknessY1("ThicknessY", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
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

		uniform float _SizeMin1;
		uniform float _SizeMax1;
		uniform float _Slice1;
		uniform float _Reverse1;
		uniform float _Strength1;
		uniform float _ThicknessY1;
		uniform float2 _NoiseScale1;
		uniform float _ThicknessX1;
		uniform sampler2D _NormalMap1;
		uniform float4 _NormalMap1_ST;
		uniform sampler2D _NormalsSecondary1;
		uniform float4 _NormalsSecondary1_ST;
		uniform float _NormalScale1;
		uniform float4 _AlbedoSecondaryColor1;
		uniform sampler2D _BaseTexture1;
		uniform float4 _BaseTexture1_ST;
		uniform float4 _AlbeddoColor1;
		uniform float _GlowSpeed1;
		uniform float4 _GlowColor1;
		uniform float _Metallic1;
		uniform float _Smoothness1;
		uniform float _Opacity1;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 transform22 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float lerpResult15 = lerp( _SizeMin1 , _SizeMax1 , _Slice1);
			float Slice17 = lerpResult15;
			float Y_Gradient44 = saturate( ( ( transform22.y + Slice17 ) / ( _Reverse1 )?( -10.0 ):( 10.0 ) ) );
			float2 panner18 = ( 1.0 * _Time.y * float2( -6,1 ) + float2( 0,0 ));
			float2 uv_TexCoord21 = v.texcoord.xy * _NoiseScale1 + panner18;
			float alternateNoise49 = ( step( _ThicknessY1 , frac( uv_TexCoord21.x ) ) + step( frac( uv_TexCoord21.y ) , _ThicknessX1 ) );
			float3 VertexOffset91 = ( ( ( ase_vertex3Pos * Y_Gradient44 ) * _Strength1 ) * alternateNoise49 );
			v.vertex.xyz += VertexOffset91;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap1 = i.uv_texcoord * _NormalMap1_ST.xy + _NormalMap1_ST.zw;
			float2 uv_NormalsSecondary1 = i.uv_texcoord * _NormalsSecondary1_ST.xy + _NormalsSecondary1_ST.zw;
			float3 Normals92 = ( UnpackNormal( tex2D( _NormalMap1, uv_NormalMap1 ) ) + ( UnpackNormal( tex2D( _NormalsSecondary1, uv_NormalsSecondary1 ) ) * _NormalScale1 ) );
			o.Normal = Normals92;
			float2 uv_BaseTexture1 = i.uv_texcoord * _BaseTexture1_ST.xy + _BaseTexture1_ST.zw;
			float4 tex2DNode46 = tex2D( _BaseTexture1, uv_BaseTexture1 );
			float mulTime33 = _Time.y * _GlowSpeed1;
			float4 Albedo90 = ( ( ( _AlbedoSecondaryColor1 * tex2DNode46 ) + ( ( 1.0 - tex2DNode46 ) * _AlbeddoColor1 ) ) + ( _AlbeddoColor1 * ( ( ( sin( mulTime33 ) + 4.0 ) / 2.0 ) * ( step( 0.5 , frac( i.uv_texcoord.x ) ) / 2.0 ) ) ) );
			o.Albedo = Albedo90.rgb;
			float2 panner18 = ( 1.0 * _Time.y * float2( -6,1 ) + float2( 0,0 ));
			float2 uv_TexCoord21 = i.uv_texcoord * _NoiseScale1 + panner18;
			float alternateNoise49 = ( step( _ThicknessY1 , frac( uv_TexCoord21.x ) ) + step( frac( uv_TexCoord21.y ) , _ThicknessX1 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 transform22 = mul(unity_ObjectToWorld,float4( ase_vertex3Pos , 0.0 ));
			float lerpResult15 = lerp( _SizeMin1 , _SizeMax1 , _Slice1);
			float Slice17 = lerpResult15;
			float Y_Gradient44 = saturate( ( ( transform22.y + Slice17 ) / ( _Reverse1 )?( -10.0 ):( 10.0 ) ) );
			float4 Emission93 = ( _GlowColor1 * ( alternateNoise49 * Y_Gradient44 ) );
			o.Emission = Emission93.rgb;
			o.Metallic = _Metallic1;
			o.Smoothness = _Smoothness1;
			o.Alpha = _Opacity1;
			float temp_output_64_0 = ( 2.0 * Y_Gradient44 );
			float Dissolve89 = ( ( ( Y_Gradient44 * alternateNoise49 ) - temp_output_64_0 ) + ( 1.0 - temp_output_64_0 ) );
			clip( Dissolve89 - _Cutoff );
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
205;75;1132;523;306.3022;371.8155;3.657033;True;False
Node;AmplifyShaderEditor.CommentaryNode;9;-3127.581,506.2054;Inherit;False;949.3313;462.5497;Comment;5;17;15;13;11;10;Slice;0.5188679,0.09055714,0.09055714,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-2964.447,556.2054;Float;False;Property;_SizeMin1;Size Min;13;0;Create;True;0;0;False;0;0;-20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-3077.581,853.7551;Float;False;Property;_Slice1;Slice;12;0;Create;True;0;0;False;0;1.57226;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;12;-2495.186,-1450.05;Inherit;False;2034.567;791.833;Comment;12;49;40;35;34;30;29;28;26;21;19;18;16;Grid;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2975.506,688.9286;Float;False;Property;_SizeMax1;Size Max;14;0;Create;True;0;0;False;0;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;14;-1815.612,439.9699;Inherit;False;1655.697;661.3397;Comment;10;44;41;37;32;31;25;24;23;22;20;Y-Gradient;0.9339623,0.9260758,0.3568441,1;0;0
Node;AmplifyShaderEditor.LerpOp;15;-2663.605,657.96;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;16;-2445.186,-996.446;Float;False;Constant;_SpeedGrid1;SpeedGrid;16;0;Create;True;0;0;False;0;-6,1;-2,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-2426.916,693.3528;Float;False;Slice;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;20;-1793.64,507.5819;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;19;-2215.01,-1209.586;Float;False;Property;_NoiseScale1;NoiseScale;17;0;Create;True;0;0;False;0;0,0;20,20;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;18;-2201.473,-996.738;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-1641.638,797.3193;Inherit;False;17;Slice;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1390.602,950.607;Float;False;Constant;_Negative1;Negative;6;0;Create;True;0;0;False;0;-10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1390.718,846.8572;Float;False;Constant;_Positive1;Positive;6;0;Create;True;0;0;False;0;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;22;-1486.33,511.2806;Inherit;True;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-1985.462,-1124.259;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;26;-1676.944,-1237.195;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;879.8986,-1286.891;Float;False;Property;_GlowSpeed1;Glow Speed;11;0;Create;True;0;0;False;0;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1646.218,-773.2151;Float;False;Property;_ThicknessX1;ThicknessX;18;0;Create;True;0;0;False;0;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1667.726,-1400.05;Float;False;Property;_ThicknessY1;ThicknessY;19;0;Create;True;0;0;False;0;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;30;-1671.107,-1011.108;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;31;-1147.898,772.5338;Float;False;Property;_Reverse1;Reverse;16;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-1161.876,531.792;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;34;-1366.6,-1309.404;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;35;-1361.991,-1063.587;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;33;1092.744,-1172.555;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;36;1179.022,-657.1981;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;37;-897.4678,539.6748;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;38;1383.726,-1141.674;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;1362.764,-866.9;Float;False;Constant;_Float1;Float 0;13;0;Create;True;0;0;False;0;0.5;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;41;-642.3608,511.0727;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;42;1504.433,-719.8701;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-1031.676,-1251.021;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;43;1756.758,-871.5321;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;-2424.474,-431.64;Inherit;False;1532.852;721.0179;Comment;10;89;87;77;74;67;64;56;55;51;50;Opacity Mask;0.4607956,0.8962264,0.4949994,1;0;0
Node;AmplifyShaderEditor.SamplerNode;46;965.233,-2001.682;Inherit;True;Property;_BaseTexture1;Base Texture;3;0;Create;True;0;0;False;0;-1;b2379fa189100bd41a34ac31f3d39c07;b2379fa189100bd41a34ac31f3d39c07;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;47;1595.909,-1175.233;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-717.5217,-1295.902;Float;False;alternateNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-1112.671,1458.713;Inherit;False;1286.692;325.121;Comment;8;91;86;78;76;72;65;62;52;Vert Offset;1,0.495283,0.7404323,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-405.2957,496.6338;Float;True;Y_Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;60;1286.762,-1603.146;Float;False;Property;_AlbeddoColor1;Albeddo Color;1;1;[HDR];Create;True;0;0;False;0;0,0,0,0;2.670157,2.524416,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;62;-1054.274,1508.713;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;61;1444.514,-1850.916;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;59;556.5372,285.2675;Inherit;False;804.8325;586.91;Comment;6;92;88;80;75;68;63;Normals;0.5588836,0.4097098,0.8773585,1;0;0
Node;AmplifyShaderEditor.ColorNode;58;1442.163,-2189.56;Float;False;Property;_AlbedoSecondaryColor1;Albedo Secondary Color;2;1;[HDR];Create;True;0;0;False;0;0,0.7498157,1,0;4.237095,4.170544,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;57;1882.307,-1188.156;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-2248.366,83.34265;Inherit;False;44;Y_Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-2374.474,-381.64;Inherit;False;44;Y_Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;54;472.4982,-279.5421;Inherit;False;1024.096;499.8789;Comment;6;93;84;83;79;73;71;Glow;0.4877625,0.8651212,0.9150943,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;53;1989.441,-882.265;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-2255.056,-199.2661;Inherit;False;49;alternateNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2211.117,-13.13708;Float;False;Constant;_Float2;Float 1;10;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-1034.072,1676.334;Inherit;False;44;Y_Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;1773.594,-1732.267;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;68;593.6382,570.0592;Inherit;True;Property;_NormalsSecondary1;Normals Secondary;5;0;Create;True;0;0;False;0;-1;2b6288a68a8cf2941a59056af1ad295d;14afe250872801e4f8434561b70a3b6d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;1813.574,-2009.554;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;2181.218,-1145.965;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;510.4342,-114.1221;Inherit;False;49;alternateNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1936.949,-324.5581;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-727.0208,1652.151;Float;False;Property;_Strength1;Strength;15;0;Create;True;0;0;False;0;0;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;522.4982,105.3376;Inherit;False;44;Y_Gradient;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-763.7737,1523.974;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1982.917,36.37891;Inherit;True;2;2;0;FLOAT;1.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;703.0792,784.1824;Float;False;Property;_NormalScale1;Normal Scale;6;0;Create;True;0;0;False;0;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-546.4758,1528.043;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;79;795.5269,-229.5421;Float;False;Property;_GlowColor1;Glow Color;10;1;[HDR];Create;True;0;0;False;0;0.5490196,0,0,0;23.96863,2.363421,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;914.8233,618.8317;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;2301.087,-1358.392;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;82;2058.556,-1708.051;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;810.6028,20.60052;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;74;-1643.959,-159.645;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;75;606.5372,335.2675;Inherit;True;Property;_NormalMap1;Normal Map;4;0;Create;True;0;0;False;0;-1;14afe250872801e4f8434561b70a3b6d;2b6288a68a8cf2941a59056af1ad295d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;78;-486.7227,1677.934;Inherit;False;49;alternateNoise;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;77;-1635.792,142.5583;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;1051.267,-70.0025;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-309.8557,1546.223;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-1360.647,-183.4821;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;2519.157,-1577.268;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;1039.729,490.3577;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;1247.928,-19.11829;Float;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;1156.72,361.1115;Float;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-81.14673,1558.677;Float;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;2943.573,-1432.82;Float;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-1122.587,-313.1381;Float;False;Dissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;1594.532,887.7187;Float;False;Property;_Metallic1;Metallic;7;0;Create;True;0;0;False;0;0.5;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;8;1840.774,1431.908;Inherit;False;91;VertexOffset;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;7;1605.337,1159.557;Float;False;Property;_Opacity1;Opacity;9;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;6;1709.869,747.2365;Inherit;False;93;Emission;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;1629.456,1020.037;Float;False;Property;_Smoothness1;Smoothness;8;0;Create;True;0;0;False;0;0.5;0.9;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;3;1701.039,537.7321;Inherit;False;90;Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;2;1697.062,629.2985;Inherit;False;92;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;4;1743.311,1272.405;Inherit;False;89;Dissolve;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2240.12,647.0272;Float;False;True;2;ASEMaterialInspector;0;0;Standard;Alex/HDRPToken;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;15;0;10;0
WireConnection;15;1;13;0
WireConnection;15;2;11;0
WireConnection;17;0;15;0
WireConnection;18;2;16;0
WireConnection;22;0;20;0
WireConnection;21;0;19;0
WireConnection;21;1;18;0
WireConnection;26;0;21;1
WireConnection;30;0;21;2
WireConnection;31;0;23;0
WireConnection;31;1;24;0
WireConnection;32;0;22;2
WireConnection;32;1;25;0
WireConnection;34;0;29;0
WireConnection;34;1;26;0
WireConnection;35;0;30;0
WireConnection;35;1;28;0
WireConnection;33;0;27;0
WireConnection;37;0;32;0
WireConnection;37;1;31;0
WireConnection;38;0;33;0
WireConnection;41;0;37;0
WireConnection;42;0;36;1
WireConnection;40;0;34;0
WireConnection;40;1;35;0
WireConnection;43;0;39;0
WireConnection;43;1;42;0
WireConnection;47;0;38;0
WireConnection;49;0;40;0
WireConnection;44;0;41;0
WireConnection;61;0;46;0
WireConnection;57;0;47;0
WireConnection;53;0;43;0
WireConnection;66;0;61;0
WireConnection;66;1;60;0
WireConnection;69;0;58;0
WireConnection;69;1;46;0
WireConnection;70;0;57;0
WireConnection;70;1;53;0
WireConnection;67;0;55;0
WireConnection;67;1;51;0
WireConnection;65;0;62;0
WireConnection;65;1;52;0
WireConnection;64;0;50;0
WireConnection;64;1;56;0
WireConnection;76;0;65;0
WireConnection;76;1;72;0
WireConnection;80;0;68;0
WireConnection;80;1;63;0
WireConnection;81;0;60;0
WireConnection;81;1;70;0
WireConnection;82;0;69;0
WireConnection;82;1;66;0
WireConnection;83;0;71;0
WireConnection;83;1;73;0
WireConnection;74;0;67;0
WireConnection;74;1;64;0
WireConnection;77;0;64;0
WireConnection;84;0;79;0
WireConnection;84;1;83;0
WireConnection;86;0;76;0
WireConnection;86;1;78;0
WireConnection;87;0;74;0
WireConnection;87;1;77;0
WireConnection;85;0;82;0
WireConnection;85;1;81;0
WireConnection;88;0;75;0
WireConnection;88;1;80;0
WireConnection;93;0;84;0
WireConnection;92;0;88;0
WireConnection;91;0;86;0
WireConnection;90;0;85;0
WireConnection;89;0;87;0
WireConnection;0;0;3;0
WireConnection;0;1;2;0
WireConnection;0;2;6;0
WireConnection;0;3;1;0
WireConnection;0;4;5;0
WireConnection;0;9;7;0
WireConnection;0;10;4;0
WireConnection;0;11;8;0
ASEEND*/
//CHKSM=32783E338C68EC6660227977C9F32768E04C87D2