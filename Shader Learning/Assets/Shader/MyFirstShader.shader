// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/MyFirstShader"
{

  Properties
  {
    _Tint("Tint",Color) = (1,1,1,1)
    _MainTex ("Texture",2D) = "white"{}
  }

   SubShader{
    pass{
        CGPROGRAM
      
        //pragma_what is its function?
        #pragma vertex MyVertexProgram 
        #pragma fragment MyFragmentProgram
        #include "UnityCG.cginc"

        // Why here?
        float4 _Tint;
        sampler2D _MainTex;
        float4 _MainTex_ST;
        struct Interpolators 
        {
          float4 position : SV_POSITION;  
          //so much texcoord0?
          float2 uv : TEXCOORD0;
        };
        //why this ; ?
        struct VertexData
        {
          float4 position : POSITION;
          float2 uv : TEXCOORD0;
        };

        //what is the mean of ":" belon? indicate?  output?
        //Does POSITION represent the world position of input model ?   
        Interpolators MyVertexProgram 
        (
          VertexData v
        ) 
        {
          Interpolators i;
          i.position = UnityObjectToClipPos(v.position);
          i.uv = TRANSFORM_TEX(v.uv,_MainTex);
          return i;       
        }
        //Is this position same as the up one?
        float4 MyFragmentProgram
        (
          Interpolators i
        ): SV_TARGET
        {
          return tex2D(_MainTex,i.uv)* _Tint ;   
          //return tex2D(_MainTex,i.uv) ;        
        }

        ENDCG
    }
   }

}
