#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

uniform mat4 u_ModelView;

uniform highp float u_Time;
uniform highp float u_VoronoiScale;
uniform highp float u_Displacement;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader
in vec4 vs_Nor;             // The array of vertex normals passed to the shader
in vec4 vs_Col;             // The array of vertex colors passed to the shader.
in vec2 vs_Uv;

out vec3 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec3 fs_Pos;
out vec3 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec2 fs_Uv;
out vec3 fs_ViewPos;

const float Pi = 3.1415926535897932;
const float PiInv = 1.0 / Pi;

vec2 sphereToPlane(vec3 uv) {
	float theta = atan(uv.y, uv.x);
	if (theta < 0.0) {
        theta += Pi * 2.0;
    }
	float phi = atan(length(uv.xy), uv.z);
	return vec2(theta * PiInv * 0.5, phi * PiInv);
}

uint hash(uint seed) {
    seed = (seed ^ uint(61)) ^ (seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> uint(4));
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> uint(15));
    return seed;
}

float rand(inout uint seed) {
    seed = hash(seed);
    return float(seed) * (1.0 / 4294967296.0);
}

vec2 floatMod(vec2 v, vec2 m) {
    return fract((v + m * 10.0) / m) * m;
}

float VoronoiNoise(vec2 uv, vec2 scale, float time) {
    uv = uv * scale + time;

    float minDist = 2.;
    vec2 base = floor(uv);
    vec2 closest;

    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            vec2 cell = base + vec2(i, j);
            vec2 modCell = floatMod(cell, scale);
            uint seed = floatBitsToUint((modCell.x + 1.0) * (modCell.y + 1.0));
            vec2 cellPos = cell + vec2(rand(seed), rand(seed));

            if (length(cellPos - uv) < minDist) {
                minDist = length(cellPos - uv);
                closest = cell;
            }
        }
    }
    uint seed = floatBitsToUint((closest.x + 1.0) * (closest.y + 1.0));
    //return minDist * rand(seed);
    return mix(0.1, 1.0, 1.0 - pow(minDist, 1.1));
    //return rand(seed);
}

vec3 displacement(vec3 n, vec2 uv, float time) {
    vec2 uv2 = sphereToPlane(normalize(vec3(uv * 2.0 - 1.0, 1.0)));
    float r = length(uv - 0.5);
    float r2 = abs(r) - 0.5;
    vec3 noiseDisplacement = n * VoronoiNoise(uv2, vec2(u_VoronoiScale), time) * u_Displacement;
    vec3 shapeDisplacement = n * pow(r2, 3.0) * 4.0;
    return noiseDisplacement + shapeDisplacement;
}

void main()
{
    fs_Col = vs_Col.xyz;                         // Pass the vertex colors to the fragment shader for interpolation
    fs_Uv = vs_Uv;

    //vec2 uv = sphereToPlane(normalize(vec3(vs_Uv * 2.0 - 1.0, 1.0)));
    vec3 pos = vs_Pos.xyz + displacement(vs_Nor.xyz, vs_Uv, u_Time);

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = normalize(invTranspose * vec3(vs_Nor));          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.
    fs_ViewPos = vec3(u_ModelView * vec4(pos, 1.0));
    vec4 modelposition = u_Model * vec4(pos, 1.0);   // Temporarily store the transformed vertex positions for use below
    fs_Pos = modelposition.xyz;

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
