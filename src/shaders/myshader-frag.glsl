#version 300 es

precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_Col;
in vec4 fs_Pos;

uniform float u_Time;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.


//=====================================================================
// Noise Functions
//=====================================================================
vec3 random3(vec3 p)
{
    return fract(sin(vec3(dot(p,vec3(127.1f, 311.7f, 191.999f)),
                        dot(p, vec3(269.5f, 183.3f, 191.999f)),
                        dot(p, vec3(420.6f, 631.2f, 191.999f))))
                                * 43758.5453f);
}

const float PI = 3.14159265359;

float WorleyNoise(vec3 xyz, float columns, float rows, float aisle) {
	
	vec3 index_xyz = floor(vec3(xyz.x * columns, xyz.y * rows, xyz.z * aisle));
	vec3 fract_xyz = fract(vec3(xyz.x * columns, xyz.y * rows, xyz.z * aisle));
	
	float minimum_dist = 1.0;  
	
    for(int z= -1; z <= 1; z++){
	    for (int y= -1; y <= 1; y++) {
		    for (int x= -1; x <= 1; x++) {
                vec3 neighbor = vec3(float(x),float(y),float(z));
                vec3 point = random3(index_xyz + neighbor);
                
                vec3 diff = neighbor + point - fract_xyz;
                float dist = length(diff);
                minimum_dist = min(minimum_dist, dist);
            }
		}
	}
	
	return minimum_dist;
}

void main()
{

    // Rainbow Palette!
    vec3 a = vec3(0.1, 0.1, 0.1) * 2.0;
    vec3 b = vec3(0.5, 0.5, 0.5) * -0.75;
    vec3 c = vec3(1.0, 1.0, 1.0) * 2.0;
    vec3 d = vec3(0.0, 0.33, 0.67) * 4.0
    + (u_Time / 100.0);
    
    float worleyNoise = WorleyNoise(
        fs_Pos.xyz * cos(u_Time * 0.015), 
        5.0, 
        5.0,
        5.0);
    
    vec4 diffuseColor = vec4(
        u_Color.r * worleyNoise, 
        u_Color.g * worleyNoise, 
        u_Color.b * worleyNoise, 1.0);

    // Distort the colors with the rainbow effect
    vec3 rainbowEffect = diffuseColor.rgb + a + b * cos(2.0 * PI * (c + d));

    out_Col = vec4(diffuseColor.rgb + rainbowEffect, diffuseColor.a);
}
