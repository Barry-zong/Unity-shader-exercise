Shader "Unlit/NPR_3_2Render_update"
{
    Properties
    {
        _NormalTex ("Normal",2D) = "bump" {}
        _NormalScale("Normal Scale",Range(0,2)) = 1
        [HDR]_SpecularColor("Specular Color",Color) = (1.0,1.0,1.0,1.0)
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("Color",Color) = (1.0,1.0,1.0,1.0)
        _GlossTex("Mask Tex",2D) = "white" {}
        _AOstrengh("AOstrengh",Range(0,2)) = 1
        [HDR]_HighLightColor("High Light Color",Color) = (1.0,1.0,1.0,1.0)
        _Specular("Specular",Range(0.01,1)) = 0.5
        _Lut ("Lut",2D) = "white" {}
       // _LuTV("Lut V",Range(0.0,1.0)) = 0.5
        _StrokeSize("Stroke Size",float)=0.0
        [HDR]_StrokeColor("Stroke Color",Color) = (1.0,0.0,0.0,1.0)
        [HDR]_FresnelColor("Fresnel Up Color",Color) = (1.0,1.0,1.0,1.0)
        _FresnelUpIntensity("Fresnel Up Intensity",Range(0,1)) = 0.5
        _FresnelUpPowel("Fresnel Up power",Range(0.01,1)) = 0.5
        _FresnelColorDown("Fresnel Down Color",Color) = (1.0,1.0,1.0,1.0)
        _FresnelDownInt("Fresnel Down Intensity",Range(0.01,1)) = 0.5
        _FresnelDownPowel("Fresnel Down power",Range(0.01,1)) = 0.5
        _CubeMap("cube Map",Cube)= "_Skybox" {}
        _MetalInt("Metal Intensity",Range(0.01,1)) = 0.5
        _Roughness("Roughness",Range(0,0.9)) = 0
        _AmbientColor("Ambient Color",Color) = (0.5,0.5,0.5,0.5)
        _AmbientColorGround("Ambient Color Ground",Color) = (0.5,0.5,0.5,0.5)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        pass
        {
            //物体外扩描边
            cull front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
           

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            float _StrokeSize;
            float4 _StrokeColor;

            v2f vert (a2v v)
            {
                v2f o;
                v.vertex.xyz += v.normal*0.01*_StrokeSize;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            float4 frag (v2f i) : SV_TARGET
            {
                return _StrokeColor;
            }
            ENDCG

        }

        Pass
        {   //贴图，法线，光照阴影
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _fwdbase
            #pragma multi_compile SHADOWS_SCREEN
           
            #include "UnityCG.cginc"
            #include "lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv0 : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 LightDir : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                SHADOW_COORDS(4)
                float3 viewDir : TEXCOORD5;
                float3 worldTangent : TEXCOORD6;
                float3 worldBitTangent : TEXCOORD7;

            };

            sampler2D _MainTex;
            sampler2D _Lut;
            float4 _MainTex_ST;
            float4 _MainColor;
            float _LuTV;
            float _Gloss;
            float _Specular;
            float3 _AmbientColor;
            float  _NormalScale;
            sampler2D _NormalTex;
            sampler2D _GlossTex;
            float3 _HighLightColor;
            float4 _NormalTex_ST;
            float _AOstrengh;
            float3 _SpecularColor;
            float3 _AmbientColorGround;
            float3 _FresnelColor;
            float3 _FresnelColorDown;
            float _MetalInt;
            float _Roughness;
            float _FresnelUpPowel;
            float _FresnelDownPowel;
            float _FresnelDownInt;
            float _FresnelUpIntensity;
            samplerCUBE _CubeMap;

            v2f vert (a2v v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv0.xy=TRANSFORM_TEX(v.texcoord,_MainTex);
                o.uv0.zw=TRANSFORM_TEX(v.texcoord,_NormalTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldTangent = UnityObjectToWorldDir(v.tangent);
                o.worldBitTangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
                o.LightDir = UnityWorldSpaceLightDir(o.worldPos);
                o.viewDir = UnityWorldSpaceViewDir(o.worldPos);
                TRANSFER_SHADOW(o);
                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                float4 DiffuseColor = tex2D(_MainTex,i.uv0) * _MainColor;
                float3 normalTS = UnpackNormalWithScale( tex2D(_NormalTex,i.uv0.zw),_NormalScale);
                float3x3 TBN = float3x3(normalize(i.worldTangent),normalize(i.worldBitTangent),normalize(i.worldNormal));

                float3 NormalWS = mul(normalTS,TBN) ;
                float3 LightDir = normalize(i.LightDir);
                float3 ViewDir = normalize(i.viewDir);
                float3 VrDir = reflect(-ViewDir,NormalWS);
                float3 RDir = reflect(-LightDir,NormalWS);
                float3 halfVector = normalize(LightDir + ViewDir);

                float shadow = SHADOW_ATTENUATION(i);

                float NoL = dot(LightDir,NormalWS);
                float VoR = dot(ViewDir,RDir);
                float NoR = dot(halfVector,NormalWS);
                float NoV = 1 - dot(NormalWS,ViewDir);

                //diffuse
                float Lambert = saturate(NoL) * shadow;
                float halfLambert = min(NoL*0.5+0.5,shadow);
               
                //float halfLambert = NoL*0.5+0.5*shadow;
                //风格化阴影 对应hlaflambert
                float3 var_Lut = tex2D(_Lut,float2(halfLambert,_LuTV));

                //SPECULAR
                float4 MaskMapValue = tex2D(_GlossTex,i.uv0);
                _Gloss = 1 - MaskMapValue.g;
                float3 Metal = MaskMapValue.r;
                float ao = pow(MaskMapValue.b,_AOstrengh*50);
                float SelfLig = MaskMapValue.w;
                float3 Diffuse = DiffuseColor * halfLambert * _LightColor0 * ao;
                float3 Specular = pow(saturate(NoR),_Gloss*256)*_Specular * _SpecularColor ;

                //_CubeMap    metal effect
                
                float3 var_CubeMap = texCUBElod(_CubeMap,float4(VrDir,_Roughness*7.0));
                float3 metalValue = var_CubeMap * Metal * _MetalInt;
                
                //Fresnel effect

                float3 Fresnel =pow(saturate(NoV),_FresnelUpPowel*15) * _FresnelColor * _FresnelUpIntensity * saturate(NormalWS.y) * var_CubeMap ;
                //float3 FresnelDown =step(1 * _SmoothRange ,pow(1-(pow(saturate(NoV), _FresnelDownPowel*15) * saturate(-NormalWS.y)),300 * _FresnelDownInt)) + _FresnelColorDown;
                 float3 FresnelDown =pow(1-(pow(saturate(NoV), _FresnelDownPowel*15) * saturate(-NormalWS.y)),300 * _FresnelDownInt) + _FresnelColorDown * saturate(-NormalWS.y);
                //Ambient ground color
                
                float3 AmbientGc = lerp(_AmbientColor,_AmbientColorGround,-NormalWS.y) *DiffuseColor ;

                //Hight light color

                float3 Highlight = _HighLightColor * SelfLig ;

                //Final output
                float3 FinalColor = (Diffuse + Specular + AmbientGc + Fresnel + metalValue + Highlight) * FresnelDown;

                return float4(FinalColor,1.0);
                //return float4( FresnelDown,1.0);
                
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
