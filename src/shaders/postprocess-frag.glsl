#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 fs_Color;

uniform float u_Time;
uniform sampler2D u_RenderedImage;
uniform float u_Factor;

float random21(vec2 a)
{
    return fract(sin(dot(a, vec2(127.1, 311.7))) * (43758.5453f));
}

vec2 random2D(vec2 p)
{
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)),
                           dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

float WorleyNoise(vec2 uv, float factor, out vec2 point)
{
    uv *= factor;
    vec2 uvInt = floor(uv);
    vec2 uvFract = fract(uv);

    float minDist = 1.0;
    for(int y = -1; y <= 1; ++y)
    {
        for(int x = -1; x <= 1; ++x)
        {
            vec2 neighbor = vec2(float(x), float(y));

            vec2 temp_point = random2D(uvInt + neighbor);

            vec2 diff = neighbor - uvFract + (0.5f + 0.5f * sin(u_Time + 6.2138 * temp_point));

            float dist = length(diff);
            if(dist < minDist)
            {
                minDist = dist;
                point = neighbor + temp_point;
            }
        }
    }
    point = (uvInt + point) / factor;
    return minDist;
}

float interpNoise2D(vec2 uv)
{
    int intX = int(floor(uv.x));
    float fractX = fract(uv.x);
    int intY = int(floor(uv.y));
    float fractY = fract(uv.y);

    fractX = fractX * fractX * (3.f - 2.f * fractX);
    fractY = fractY * fractY * (3.f - 2.f * fractY);

    float v1 = random21(vec2(intX, intY));
    float v2 = random21(vec2(intX + 1, intY));
    float v3 = random21(vec2(intX, intY + 1));
    float v4 = random21(vec2(intX + 1, intY + 1));

    float i1 = mix(v1, v2, fractX);
    float i2 = mix(v3, v4, fractX);

    return mix(i1, i2, fractY);
}

float NoiseFBM(vec2 uv)
{
    float total = 0.0f;
    float persistence = 0.5f;
    int octaves = 8;
    float freq = 2.f;
    float amp = 0.5;
    for(int i = 0; i < octaves; ++i)
    {
        total += interpNoise2D(uv * freq + u_Time) * amp;
        freq *= 2.f;
        amp *= persistence;
    }

    return total;
}

// perlin
vec2 falloff(vec2 p, vec2 corner)
{
    vec2 t = abs(p - corner);
    t = vec2(1.f) - t * t * t * (t * (t * 6.f - 15.f) + 10.f);
    return t;
}
float surflet(vec2 P, vec2 gridPoint)
{
    vec2 t = falloff(P, gridPoint);
    vec2 gradient = 2.f * random2D(gridPoint) - 1.f;
    vec2 diff = P - gridPoint;

    float height = dot(diff, gradient);

    return height * t.x * t.y;
}
float perlinNoise(vec2 uv)
{
    float surfletSum = 0.f;
    for(int dx = 0; dx < 2; ++dx)
    {
        for(int dy = 0; dy < 2; ++dy)
        {
            surfletSum += surflet(uv, floor(uv) + vec2(dx, dy));
        }
    }

    return surfletSum;
}

void main()
{
    //vec2 point;
    //float WorleyNoise = WorleyNoise(fs_UV, u_Factor, point);
    //WorleyNoise = clamp(WorleyNoise, 0., 1.);
    //WorleyNoise = 1.f - WorleyNoise;
    //WorleyNoise = pow(WorleyNoise, 1.1f);

    //float fbm = NoiseFBM(fs_UV);
    //float perlin = perlinNoise(fs_UV * 10.f);
    
    fs_Color = vec4(texture(u_RenderedImage, fs_UV).rgb, 1);
}