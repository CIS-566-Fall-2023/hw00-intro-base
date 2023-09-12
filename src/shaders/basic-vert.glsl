#version 300 es

uniform mat4 u_Model;       
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec4 fs_Pos;
out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_Col;

const vec4 lightPos = vec4(5, 5, 3, 1);

uniform float u_Time;

// Function to perform normal displacement
void displaceNormal(inout vec4 pos, vec4 nor, float displacementAmount) {
    vec3 displacement = normalize(nor.xyz) * displacementAmount;
    pos.xyz += displacement;
}

void main() {
    fs_Col = vs_Col;
    fs_Pos = vs_Pos;

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);

    vec4 modelposition = u_Model * vs_Pos;

    // Perform normal displacement on the vertex positions
    float displacementAmount = sin(u_Time * 0.001); // Adjust displacement speed and range
    displaceNormal(modelposition, vs_Nor, displacementAmount);

    fs_LightVec = lightPos - modelposition;

    gl_Position = u_ViewProj * modelposition;
}
