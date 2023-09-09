#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.
uniform float u_Time;
uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec3 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

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
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    vec3 local_pos = vs_Pos.xyz;
    float fbm_1 = NoiseFBM(local_pos);
    local_pos *= (0.5f * sin(cos(.7f * u_Time) + sin(.7f * u_Time)) + 0.5f) * fbm_1 + 0.3;
    float fbm_2 = NoiseFBM(local_pos);
    vec4 modelposition = u_Model * vec4(local_pos, 1.f);   // Temporarily store the transformed vertex positions for use below
    modelposition += fs_Nor * fbm_2 * 1.1f;
    modelposition += fs_Nor * (0.5f * sin(cos(0.5f * u_Time)) + .5f);

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
    fs_Pos = gl_Position.xyz;
}
