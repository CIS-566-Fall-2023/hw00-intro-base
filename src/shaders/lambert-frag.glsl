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

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

const int N_OCTAVES=8;

float noisegen3(vec3 pos){
    return fract(sin(dot(pos, vec3(12.9898,78.233,43.21)))*43758.5453);
}

float sampleNoisei(vec3 pos, float frequency,float time){
    //return 1.0f;
    vec3 sample_point=pos*(frequency);
    //vec3 sample_point=pos;
    vec3 point=floor(sample_point);
    vec3 local=fract(sample_point);
    //return 1.0f;
    float R1=noisegen3(point);
    float R2=noisegen3(point+vec3(1.0f));
    return mix(R1,R2,time); 
}

float FBM3D(vec3 pos,float time){
    float total=0.0f;
    float persistance=0.25f;

    for(int i=0;i<N_OCTAVES;i++){
        float frequency=pow(2.0f,float(i));
        float amplitude=pow(persistance,float(i));
        total+= sampleNoisei(pos,frequency,time)*amplitude; 
    }
    //return 0.0f;
    return total*1.2f;
}


void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity*FBM3D(vec3(fs_LightVec),u_Time), diffuseColor.a);
}
