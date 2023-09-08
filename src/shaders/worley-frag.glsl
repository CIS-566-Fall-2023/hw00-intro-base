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
uniform float u_worley0;
uniform float u_worley1;
uniform float u_time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

vec3 random3( vec3 p ) {
 return fract(
    sin(
        vec3(
            dot(p.xy, vec2(127.1, 311.7)),
            dot(p.yz, vec2(269.5,183.3)),
            dot(p.zx, vec2(20.1 ,123.3))
            )
        )* 43758.5453
 );
}

float WorleyNoise(vec3 uv) {
    uv *= 3.0; // Now the space is 10x10 instead of 1x1. Change this to any number you want.
    vec3 uvInt = floor(uv);
    vec3 uvFract = fract(uv);
    float minDist = 100.0; // Minimum distance initialized to max.
    for(int z = -1; z <= 1; ++z){
        for(int y = -1; y <= 1; ++y) {
            for(int x = -1; x <= 1; ++x) {
                vec3 neighbor = vec3(float(x), float(y), float(z)); // Direction in which neighbor cell lies
                vec3 point = random3(uvInt + neighbor); // Get the Voronoi centerpoint for the neighboring cell
                vec3 diff = neighbor + point - uvFract; // Distance between fragment coord and neighbor’s Voronoi point
                float dist = length(diff);
                minDist = min(minDist, dist);
            }
        } 
    }
    return minDist;
}


void main()
{
    // Material base color (before shading)
    float worleyTerm = smoothstep(u_worley0,u_worley1,WorleyNoise(fs_Pos.xyz
     + vec3(u_time/10.0)
    ));
    vec3 color = (vec3(worleyTerm)*u_Color.xyz + u_Color.xyz);
    vec4 diffuseColor = vec4(color,1.0);
        // Compute final shaded color 
    out_Col = vec4(diffuseColor.rgb, diffuseColor.a);
}
