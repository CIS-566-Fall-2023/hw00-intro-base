#version 300 es

precision highp float;

uniform vec4 u_Color;
uniform float u_Time;
in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col;

float random31(vec3 a)
{
    return fract(sin(dot(a, vec3(127.1, 311.7,  74.7))) * (43758.5453f));
}

float interpNoise3D(vec3 p)
{
    int intX = int(floor(p.x));
    float fractX = fract(p.x);
    int intY = int(floor(p.y));
    float fractY = fract(p.y);
    int intZ = int(floor(p.z));
    float fractZ = fract(p.z);

    fractX = fractX * fractX * (3.f - 2.f * fractX);
    fractY = fractY * fractY * (3.f - 2.f * fractY);
    fractZ = fractZ * fractZ * (3.f - 2.f * fractZ);

    float results[2];
    float v[2];
    for(int z = 0; z < 2; ++z)
    {
        for(int y = 0; y < 2; ++y)
        {
            float v1 = random31(vec3(intX, intY + y, intZ + z));
            float v2 = random31(vec3(intX + 1, intY + y, intZ + z));

            v[y] = mix(v1, v2, fractX);
        }
        results[z] = mix(v[0], v[1], fractY);
    }

    return mix(results[0], results[1], fractZ);
}

float NoiseFBM(vec3 p)
{
    float total = 0.0f;
    float persistence = 0.5f;
    int octaves = 8;
    float freq = 2.f;
    float amp = 0.5;
    for(int i = 0; i < octaves; ++i)
    {
        total += interpNoise3D(p * freq + u_Time) * amp;
        freq *= 2.f;
        amp *= persistence;
    }

    return total;
}

void main()
{
        vec4 diffuseColor = vec4(1, 0, 0, 1);

        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;

        float fbm = NoiseFBM(fs_Pos);
        fbm = clamp(fbm, 0.f, 1.f);

        vec3 color;
        color.r = 0.5 + 0.5 * cos(1.56 * u_Time);
        color.g = 0.5 + 0.5 * cos(1.56 * (u_Time + 0.33));
        color.b = 0.5 + 0.5 * cos(1.56 * (u_Time + 0.67));

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * color * lightIntensity, fbm);
}