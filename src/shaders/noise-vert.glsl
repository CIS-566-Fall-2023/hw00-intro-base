#version 300 es

uniform mat4 u_Model;

uniform mat4 u_ModelInvTr;

uniform mat4 u_ViewProj;

uniform float u_Time;

uniform vec3 u_CamPos;

in vec4 vs_Pos;

in vec4 vs_Nor;

in vec4 vs_Col;

out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_Col;
out vec4 fs_Pos;
out vec4 fs_CameraPos;

const vec4 lightPos = vec4(5, 5, 3, 1);

float noise1D( vec3 p ) {
    return fract(sin(dot(p, vec3(127.1, 311.7, 524.2))) *
                 43758.5453);
}

float interpNoise1D(float x) {
    vec3 intX = vec3(floor(x));
    float fractX = fract(x);

    float v1 = noise1D(intX);
    float v2 = noise1D(intX + vec3(1.0));
    return mix(v1, v2, fractX);
}

float fbm(float x) {
    float total = 0.0;
    float persistence = 0.5f;
    int octaves = 8;
    float freq = 2.f;
    float amp = 0.5f;
    for(int i = 1; i <= octaves; i++) {
        total += interpNoise1D(x * freq) * amp;

        freq *= 2.f;
        amp *= persistence;
    }
    return total;
}


void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.


    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    fs_Pos = modelposition;

    float t = sin(u_Time * 0.001);

    modelposition.x = cos(t) * modelposition.x + abs(fbm(0.0 * modelposition.x));
    modelposition.y = cos(t) * modelposition.y + abs(fbm(1.0 * modelposition.y));
    //modelposition.z *= -cos(t) * fbm(modelposition.z * 0.4);

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
    // Set camera position.
    fs_CameraPos = vec4(u_CamPos[0], u_CamPos[1], u_CamPos[2], 1.f);
}