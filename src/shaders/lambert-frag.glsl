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

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

vec3 random3(vec3 pos){
    return fract(vec3(
        9175.3f * cos(dot(pos, vec3(135.235f, 593.3f, -354.1f))), 
        124.9f * sin(dot(pos, vec3(937.1f, -2031.1f, 24.6f))), 
        -1234.62f * sin(dot(pos, vec3(-752.91f, -468.57f, 462.24f)))
    ));
}

float surflect3D(vec3 grid, vec3 pos)
{
    vec3 diff = grid - pos;
    vec3 grad = 2.0f * random3(grid) - vec3(1.0f, 1.0f, 1.0f);
    float tx = 6.0f * pow(abs(diff.x), 5.0f) - 15.0f * pow(abs(diff.x), 4.0f) + 10.0f * pow(abs(diff.x), 3.0f);
    float ty = 6.0f * pow(abs(diff.y), 5.0f) - 15.0f * pow(abs(diff.y), 4.0f) + 10.0f * pow(abs(diff.y), 3.0f);
    float tz = 6.0f * pow(abs(diff.z), 5.0f) - 15.0f * pow(abs(diff.z), 4.0f) + 10.0f * pow(abs(diff.z), 3.0f);
    return dot(diff, grad) * (1.0f - tx) * (1.0f - ty) * (1.0f - tz);
}

float perlinNoise(vec3 pos){
    float sum = 0.0f;
    for(int dx = 0; dx <= 1; dx++){
        for(int dy = 0; dy <= 1; dy++){
            for(int dz = 0; dz <= 1; dz++){
                float surf = surflect3D(floor(pos + vec3(0.001f, 0.001f, 0.001f)) + vec3(dx, dy, dz), pos);
                sum += surf;
            }
        }
    }
    return sum;
}

float worleyNoise(vec3 pos){
    float sum = 0.0f;
    float minDis = 1.0f;
    for(int dx = -1; dx <= 1; dx++){
        for(int dy = -1; dy <= 1; dy++){
            for(int dz = -1; dz <= 1; dz++){
                vec3 grid = floor(pos + vec3(0.001f, 0.001f, 0.001f) + vec3(dx, dy, dz));
                float dis = length(grid + random3(grid) - pos);
                minDis = min(dis, minDis);
            }
        }
    }
    return 1.0f - minDis;
}

void main()
{
    // vec4 diffuseColor = u_Color;     // Material base color (before shading)
    // float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    // diffuseTerm = clamp(diffuseTerm, 0, 1);     // Avoid negative lighting values
    // float ambientTerm = 0.2;
    // float lightIntensity = diffuseTerm + ambientTerm;
    // out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);

    float noise = 0.0f;
    // noise += clamp(perlinNoise(fs_Pos.xyz * 3.0f) + 0.3f, 0.0f, 1.0f);
    noise += 0.5f * worleyNoise(fs_Pos.xyz * 2.5f);

    float amp = 0.5f;
    float freq = 1.0f;
    for(int i = 0; i < 3; i++)
    {
        // noise += amp * 0.7f * clamp(perlinNoise(fs_Pos.xyz * 3.0f * freq) + 0.5f, 0.0f, 1.0f);
        noise += amp * 0.7f * (1.0f - abs(perlinNoise(fs_Pos.xyz * 3.0f * freq)));
        // noise += amp * worleyNoise(fs_Pos.xyz * 2.5f * freq);
        freq *= 2.0f;
        amp /= 2.0f;
    }
    
    out_Col = vec4(u_Color.xyz * noise, u_Color.a);
}
