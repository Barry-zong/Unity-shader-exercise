Shader "Unlit/NPR_3_3Shadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("Color",Color) = (1.0,1.0,1.0,1.0)
        _Lut ("Lut",2D) = "white" {}
        _LuTV("Lut V",Range(0.0,1.0)) = 0.5
        _StrokeSize("Stroke Size",float)=0.0
        _StrokeColor("Stroke Color",Color) = (1.0,0.0,0.0,1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        pass
        {

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
        {
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _fwdbase
           
            #include "UnityCG.cginc"
            #include "lighting.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 LightDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _Lut;
            float4 _MainTex_ST;
            float4 _MainColor;
            float _LuTV;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv0=TRANSFORM_TEX(v.texcoord,_MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.LightDir = UnityWorldSpaceLightDir(v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                float4 DiffuseColor = tex2D(_MainTex,i.uv0) * _MainColor;

                float3 NormalWS = normalize(i.worldNormal) ;
                float3 LightDir = normalize(i.LightDir);

                float NoL = dot(LightDir,NormalWS);
                float Lambert = saturate(NoL);
                float halfLambert = NoL*0.5+0.5;
                float3 var_Lut = tex2D(_Lut,float2(halfLambert,_LuTV));
                float3 FinalColor = DiffuseColor * var_Lut * _LightColor0;

                return float4(FinalColor,1.0);
                
            }

            ENDCG
        }
    }
}
