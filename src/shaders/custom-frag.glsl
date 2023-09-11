#version 300 es

precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Radius;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in float fs_Time;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float falloff(float dist) {
    return 3.0 * exp(-4.0 * abs(2.5 * dist - 1.0));
}

vec3 random3(vec3 p) {
    return fract(sin(vec3(dot(p, vec3(127.1, 311.7, 670.2)),
                          dot(p, vec3(269.5, 183.3, 378.1)),
                          dot(p, vec3(420.6, 631.2, 892.3)))) 
                          * 43758.5453);
}


float WorleyNoise(vec3 uv) {
    vec3 uvInt = floor(uv);
    vec3 uvFract = fract(uv);
    float minDist = 1.0; // Minimum distance initialized to max.
    for (int z = -1; z <= 1; ++z) {
        for (int y = -1; y <= 1; ++y) {
            for (int x = -1; x <= 1; ++x) {
                vec3 neighbor = vec3(float(x), float(y), float(z)); // Direction in which neighbor cell lies
                vec3 point = random3(uvInt + neighbor); // Get the Voronoi centerpoint for the neighboring cell
                vec3 diff = neighbor + point - uvFract; // Distance between fragment coord and neighbor’s Voronoi point
                float dist = length(diff);
                minDist = min(minDist, dist);
            }
        }
    }
    
    return falloff(minDist);
}

float fworley(vec3 p, float time) {
    //Stack noise layers 
	return sqrt(sqrt(sqrt(
		WorleyNoise(p * 5.6 + 0.06*time) *
		sqrt(WorleyNoise(p * 45.1 + 0.12 + -0.12 * time)) *
		sqrt(sqrt(WorleyNoise(p * -12.0 + 0.04 * time))))));
}


void main(){
    // Material base color (before shading)
    vec4 diffuseColor = u_Color;

    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    // Avoid negative lighting values
    // diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.2;
    vec2 uv = fs_Nor.xy;
    float time = fs_Time;
    float noise = fworley(normalize(vec3(fs_Nor)), time * 0.05);
    
    float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                        //to simulate ambient lighting. This ensures that faces that are not
                                                        //lit by our point light are not completely black.

    // Compute final shaded color
    out_Col = vec4((diffuseColor.rgb) * lightIntensity, diffuseColor.a);
    out_Col = vec4(out_Col.r * noise, out_Col.g * noise * noise, out_Col.b * noise * pow(noise, 0.5 - noise), out_Col.a);
}