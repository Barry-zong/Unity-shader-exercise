Shader "Unlit/NPR_3_2Render"
{
    Properties
    {
        _NormalTex ("Normal",2D) = "bump" {}
        _NormalScale("Normal Scale",Range(0,2)) = 1
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("Color",Color) = (1.0,1.0,1.0,1.0)
       // _Gloss("Gloss",Range(0.01,1)) = 0.5
        _GlossValue("HighLightValue",Range(0.01,1)) = 0.5
        _GlossTex("MixTex",2D) = "white" {}
        _AOstrengh("AOstrengh",Range(0,2)) = 1
        _Specular("Specular",Range(0.01,1)) = 0.5
        _Lut ("Lut",2D) = "white" {}
        _LuTV("Lut V",Range(0.0,1.0)) = 0.5
        _StrokeSize("Stroke Size",float)=0.0
        _StrokeColor("Stroke Color",Color) = (1.0,0.0,0.0,1.0)
        _AmbientColor("Ambient Color",Color) = (0.5,0.5,0.5,0.5)
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
            float4 _NormalTex_ST;
            float _GlossValue;
            float _AOstrengh;

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
                float3 RDir = reflect(-LightDir,NormalWS);
                float3 halfVector = normalize(LightDir + ViewDir);

                float shadow = SHADOW_ATTENUATION(i);

                float NoL = dot(LightDir,NormalWS);
                float VoR = dot(ViewDir,RDir);
                float NoR = dot(halfVector,NormalWS);

                //diffuse
                float Lambert = saturate(NoL) * shadow;
                float halfLambert = min(NoL*0.5+0.5,shadow);
                //float halfLambert = NoL*0.5+0.5*shadow;
                //风格化阴影 对应hlaflambert
                float3 var_Lut = tex2D(_Lut,float2(halfLambert,_LuTV));

                //SPECULAR
                _Gloss = 1 - tex2D(_GlossTex,i.uv0).g;
                float ao = pow(tex2D(_GlossTex,i.uv0).b,_AOstrengh*50);
                //float Specular = step(_GlossValue,pow(saturate(NoR),_Gloss*256))*_Specular;
                float Specular = pow(saturate(NoR),_Gloss*256)*_Specular;
                //_GlossTex
                //float4 GlossTvalue =tex2D(_GlossTex,i.uv0);

                //float Specular = step(0.5,pow(saturate(NoR),_Gloss*256))*_Specular;
                //float Specular = step(0.5,pow(saturate(GlossTvalue),_Gloss*256))*_Specular;
                
                //3d-2d carton style
                //float3 FinalColor = DiffuseColor * var_Lut * _LightColor0 * ao + Specular + _AmbientColor*DiffuseColor;
                //3d real style
                float3 FinalColor = DiffuseColor * halfLambert * _LightColor0 * ao + Specular + _AmbientColor*DiffuseColor;

                return float4(FinalColor,1.0);
                
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
