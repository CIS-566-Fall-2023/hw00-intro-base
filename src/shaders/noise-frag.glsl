#version 300 es

precision highp float;

uniform vec4 u_Color;
uniform float u_Time;
in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col;

vec3 random33(vec3 a)
{
    return fract(sin(vec3(dot(a, vec3(127.1, 311.7,  74.7)),
                          dot(a, vec3(269.5, 183.3, 246.1)),
                          dot(a, vec3(420.6, 631.2, 124.6))
                          )) * (43758.5453f));
}

float WorleyNoise(vec3 p, float factor, out vec3 point)
{
    p *= factor;
    vec3 pInt = floor(p);
    vec3 pFract = fract(p);

    float minDist = 1.0;
    for(int z = -1; z <= 1; ++z)
    {
        for(int y = -1; y <= 1; ++y)
        {
            for(int x = -1; x <= 1; ++x)
            {
                vec3 neighbor = vec3(float(x), float(y), float(z));
    
                vec3 temp_point = random33(pInt + neighbor);
    
                vec3 diff = neighbor - pFract + (0.5f + 0.5f * sin(u_Time + 6.2138 * temp_point));
    
                float dist = length(diff);
                if(dist < minDist)
                {
                    minDist = dist;
                    point = neighbor + temp_point;
                }
            }
        }
    }
    
    point = (pInt + point) / factor;
    return minDist;
}

void main()
{
        vec4 diffuseColor = u_Color;

        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;

        vec3 point = vec3(0.f);
        float worley = WorleyNoise(fs_Pos, 1.f, point);
        worley = clamp(worley, 0.f, 1.f);

        vec3 color;
        color.r = 0.5 + 0.5 * cos(1.56 * u_Time);
        color.g = 0.5 + 0.5 * cos(1.56 * (u_Time + 0.33));
        color.b = 0.5 + 0.5 * cos(1.56 * (u_Time + 0.67));

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * color * lightIntensity, worley);
}