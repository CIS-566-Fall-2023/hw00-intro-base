#version 300 es
precision highp float;

in vec4 fs_Pos;
out vec4 Out_cal;

float noise1D(int);
vec3 hash(vec3);
float noise(vec3);

uniform float u_Time;

//1D hash by Hugo Elias
float noise1D(int n){
    n = (n << 13) ^ n;
    n = n * (n * n * 15731 + 789221) + 1376312589;
    return float( n & ivec3(0x0fffffff))/float(0x0fffffff);
}

//3D hash by iq: https://www.shadertoy.com/view/4sfGzS
vec3 hash( vec3 p ) 
{                        
    // 3D -> 1D
    float n = p.x*3.0 + p.y*113.0 + p.z*311.0;
    return 2.0 * vec3(noise1D(int(n))) - 1.0;
}

//https://iquilezles.org/articles/gradientnoise/
//https://www.shadertoy.com/view/4sfGzS
//https://www.shadertoy.com/view/Xl3Gzj#
float noise( vec3 x )
{
    vec3 i = floor(x),
         f = fract(x),
         u = f*f*f* (f * ( -15.0 + 6.0* f ) + 10.0); 
 
    return mix(
              mix( mix( dot( hash( i + vec3(0,0,0) ), f - vec3(0,0,0) ), 
                        dot( hash( i + vec3(1,0,0) ), f - vec3(1,0,0) ), u.x),
                   mix( dot( hash( i + vec3(0,1,0) ), f - vec3(0,1,0) ), 
                        dot( hash( i + vec3(1,1,0) ), f - vec3(1,1,0) ), u.x), u.y),
              mix( mix( dot( hash( i + vec3(0,0,1) ), f - vec3(0,0,1) ), 
                        dot( hash( i + vec3(1,0,1) ), f - vec3(1,0,1) ), u.x),
                   mix( dot( hash( i + vec3(0,1,1) ), f - vec3(0,1,1) ), 
                        dot( hash( i + vec3(1,1,1) ), f - vec3(1,1,1) ), u.x), u.y), 
                u.z);
}

#define OCTAVES 8
float fbm (in vec3 st) {
    // Initial values
    float value = 0.0;
    float amplitude = .5;
    float frequency = 0.5;
    //
    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st * frequency);
        st *= 2.;
        amplitude *= .5;
        frequency *= 1.6;
    }
    return value;
}

void main()
{
    float perlin = noise(vec3(fs_Pos.xyz * 5. + u_Time * 0.002));
    //float fbm = fbm(fs_Pos.xyz * 2. + u_Time * 0.003);

    //loat noiseVal = fbm;
    //adapted from https://www.shadertoy.com/view/lltcWl
    vec2 uv = gl_FragCoord.xy / 500.;

    const int ITERATIONS = 5;
    float noiseVal = 0.0;
    float sum = 0.0;
    float multiplier = 0.7;
    for (int i = 0; i < ITERATIONS; i++) {
        vec3 noisePos = vec3(vec2(2.0*uv.x+50.0*sin(0.001*u_Time),2.0*uv.y+50.0*cos(0.001*u_Time)), 0.002 * u_Time / multiplier);
        noiseVal += multiplier * abs(fbm(noisePos));
        sum += multiplier;
        multiplier *= 0.6;
        uv = 2.0 * uv + 4.3;
    }
    noiseVal /= sum;

    vec3 fragColor = 0.5 + 0.5 * cos(6.283185 * (3.0 * noiseVal + vec3(0.15, cos(0.0001*uv.x+0.01*u_Time+0.1), sin(0.001*uv.y+0.002*u_Time))));

    Out_cal = vec4(fragColor, 1.0);

}