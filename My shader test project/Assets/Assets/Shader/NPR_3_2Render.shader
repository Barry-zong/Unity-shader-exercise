Shader "Unlit/NPR_3_2Render"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("Color",Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            float4 _MainTex_ST;
            float4 _MainColor;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv0=TRANSFORM_TEX(v.texcoord,_MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.LightDir = UnityWorldSpaceLightDir(v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 DiffuseColor = tex2D(_MainTex,i.uv0) * _MainColor;

                float3 NormalWS = i.worldNormal;
                float3 LightDir = i.LightDir;

                float NoL = dot(LightDir,NormalWS);
                float3 FinalColor = DiffuseColor * NoL* _LightColor0;

                return float4(NoL,NoL,NoL,1.0);
                
            }

            ENDCG
        }
    }
}
