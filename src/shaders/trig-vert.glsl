#version 300 es

uniform mat4 u_Model; 
uniform mat4 u_ModelInvTr; 
uniform mat4 u_ViewProj; 
uniform float u_Time;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.

out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1); 

vec3 random3(vec3 st) {
    float rand = fract(sin(dot(st, vec3(12.9898, 78.233, 45.5431))) * 43758.5453);
    return normalize(fract(vec3(2.0, 3.0, 5.0) * rand));
}

float lines(vec3 pos, float b) {
    float scale = 10.0;
    pos *= scale;
    return smoothstep(0.0, 0.5 + b * 0.5, abs((sin(pos.x * 3.1415) + sin(pos.y * 3.1415) + b * 2.0) * 0.5));
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation
    fs_Pos = vs_Pos;

    vec4 new_Pos = vec4(0);

    float sinTime = sin(u_Time * 0.01) * cos(u_Time * 0.02) * 0.2;

    vec3 st = fs_Pos.xyz;

    float pattern = lines(random3(st * 10.), 0.9 * sinTime); 

    new_Pos = fs_Pos * vec4(vec3(pattern), 1.0);

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);
    
    vec4 modelposition = u_Model * new_Pos;   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
