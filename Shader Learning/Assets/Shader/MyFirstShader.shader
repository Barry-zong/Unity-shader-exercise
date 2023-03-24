// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/MyFirstShader"
{
   SubShader{
    pass{
        CGPROGRAM
      
        //pragma_what is its function?
        #pragma vertex MyVertexProgram 
        #pragma fragment MyFragmentProgram
        #include "UnityCG.cginc"
        //what is the mean of ":" belon? indicate?  output?
        //Does POSITION represent the world position of input model ?   
        float4 MyVertexProgram (float4 position: POSITION ) : SV_POSITION
        {
          return UnityObjectToClipPos(position);
        }
        float4 MyFragmentProgram(float4 position : SV_POSITION ): SV_TARGET
        {
            return 0;

        }

        ENDCG
    }
   }

}
