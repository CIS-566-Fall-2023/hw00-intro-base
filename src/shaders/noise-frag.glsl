#version 300 es

precision highp float;

uniform vec4 u_Color;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col;

vec2 random(vec2 r) {
    return fract(sin(vec2(dot(r, vec2(127.1, 311.7)), dot(r, vec2(269.5, 183.3)))) * 43758.5453);
}

float surflet(vec2 P, vec2 gridPoint) {
    // Compute falloff function by converting linear distance to a polynomial
    float distX = abs(P.x - gridPoint.x);
    float distY = abs(P.y - gridPoint.y);
    float tX = 1.0 - 6.0 * pow(distX, 5.f) + 15.0 * pow(distX, 4.f) - 10.0 * pow(distX, 3.f);
    float tY = 1.0 - 6.0 * pow(distY, 5.f) + 15.0 * pow(distY, 4.f) - 10.0 * pow(distY, 3.f);
    // Get the random vector for the grid point
    vec2 gradient = 2.f * random(gridPoint) - vec2(1.f);
    // Get the vector from the grid point to P
    vec2 diff = P - gridPoint;
    // Get the value of our height field by dotting grid->P with our gradient
    float height = dot(diff, gradient);
    // Scale our height field (i.e. reduce it) by our polynomial falloff function
    return height * tX * tY;
}


float perlinNoise(vec2 uv) {
        float surfletSum = 0.f;
        // Iterate over the four integer corners surrounding uv
        for(int dx = 0; dx <= 1; ++dx) {
                for(int dy = 0; dy <= 1; ++dy) {
                        surfletSum += surflet(uv, floor(uv) + vec2(dx, dy));
                }
        }
        return surfletSum;
}

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        float perlin = clamp(perlinNoise(fs_Pos.xy), 0.f, 1.f);

        // Apply perlin.
        diffuseColor *= perlin;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.3;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}