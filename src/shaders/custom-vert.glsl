#version 300 es

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time; // Incrementing variable passed from TypeScript

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_Col;
out vec4 fs_Pos;


const vec4 lightPos = vec4(5, 5, 3, 1);

void main() {
    vec4 modifiedPos = vs_Pos;
    modifiedPos.x += sin(u_Time*0.8 + vs_Pos.y * 0.8); 
    modifiedPos.y += sin(u_Time*0.8 + vs_Pos.z * 0.8); 
    //modifiedPos.z += sin(u_Time*0.8 + vs_Pos.y * 0.8); 
    fs_Col = vs_Col;
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);
    vec4 modelposition = u_Model * modifiedPos;
    fs_Pos = u_Model * vs_Pos;
    fs_LightVec = lightPos - modelposition;
    gl_Position = u_ViewProj * modelposition;
}
