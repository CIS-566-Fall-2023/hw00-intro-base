#version 300 es

precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos; 

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

vec3 random3(vec3 p3) {
    vec3 p = fract(p3 * vec3(.4307,.12349,.33489));
    p += dot(p, p.yxz+19.89);
    return fract(vec3((p.x + p.y)*p.z, (p.x+p.z)*p.y, (p.y+p.z)*p.x));
}

float surflet3D(vec3 p, vec3 gridPoint) {

    float t2x = abs(p.x - gridPoint.x);
    float t2y = abs(p.y - gridPoint.y);
    float t2z = abs(p.z - gridPoint.z);

    float tx = 1.f - 6.f * pow(t2x, 5.f) + 15.f * pow(t2x, 4.f) - 10.f * pow(t2x, 3.f);
    float ty = 1.f - 6.f * pow(t2y, 5.f) + 15.f * pow(t2y, 4.f) - 10.f * pow(t2y, 3.f);
    float tz = 1.f - 6.f * pow(t2z, 5.f) + 15.f * pow(t2z, 4.f) - 10.f * pow(t2z, 3.f);

    vec3 gradient = random3(gridPoint) * 2.f - vec3(1.f);

    vec3 diff = p - gridPoint;

    float height = dot(diff, gradient);

    return height * tx * ty * tz;
}

float perlinNoise3D(vec3 p) {
    float surfletSum = 0.f;

    for (int dx = 0; dx <= 1; ++dx) {
        for (int dy = 0; dy <= 1; ++dy) {
            for (int dz = 0; dz <= 1; ++dz) {
                surfletSum += surflet3D(p, floor(p) + vec3(dx, dy, dz));
            }
        }
    }
    return surfletSum ;
}

void main()
{
    // Material base color (before shading)

        vec4 diffuseColor = u_Color;

        diffuseColor *= 1.0 - abs(perlinNoise3D(vec3(fs_Pos) * 5.0)) - 0.4;

        diffuseColor += perlinNoise3D(vec3(fs_Pos) * 10.0 * (cos(u_Time * 0.0015 + 0.9)));

        float diffuseBound = diffuseColor.a;
        diffuseColor.a = 1.f;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);

        float ambientTerm = 0.5;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color

        if (diffuseBound > 0.45) {
            out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
        } else {
            out_Col = vec4(0.f);
        }
            
}