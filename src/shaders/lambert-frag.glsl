#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time;
// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec2 fs_uvs;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

const int N_OCTAVES=8;

vec2 noisegen3(vec2 pos){
    return vec2(fract(sin(dot(pos, vec2(12.9898,78.233)))*43758.5453),fract(sin(dot(pos, vec2(35.153827,44.10041)))*10101.9959));
}

float fade(float a,float b,float t){
    return a+b*(6.0f*pow(t,5.0f)-15.0f*pow(t,4.0f)+10.0f*pow(t,3.0f));
}

float PerlinNoisei(vec2 pos, float frequency){
    
    vec2 sample_point=pos*(frequency);

    vec2 point=floor(sample_point);
    vec2 local=fract(sample_point);

    float R0=dot(noisegen3(point),pos-point);
    float R1=dot(noisegen3(point+vec2(1.0f,0.0f)),pos-(point+vec2(1.0f,0.0f)));
    float R2=dot(noisegen3(point+vec2(0.0f,1.0f)),pos-(point+vec2(0.0f,1.0f)));
    float R3=dot(noisegen3(point+vec2(1.0f)),pos-(point+vec2(1.0f)));
    return fade(fade(R0,R1,local.x),fade(R2,R3,local.x),local.y); 
}

float FBM3D(vec2 pos){
    float total=0.0f;
    float persistance=0.25f;

    for(int i=0;i<N_OCTAVES;i++){
        float frequency=pow(2.0f,float(i));
        float amplitude=pow(persistance,float(i));
        total+= PerlinNoisei(pos,frequency)*amplitude; 
    }
    //return 0.0f;
    return total*0.8f+0.3f;
}


void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 1.0;

        float lightIntensity = ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color FBM3D(vec3(fs_LightVec),u_Time)
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a*FBM3D(fs_uvs));
        if(length(vec3(out_Col))>=1.0f){
            out_Col.xyz=vec3(1.0f);
        }

}
