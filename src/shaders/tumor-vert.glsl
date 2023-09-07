// keep these uniforms to simplify the code in main.ts
uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time;

in vec4 vs_Pos;
in vec4 vs_Nor;

out vec4 fs_Pos;
out vec4 fs_Nor;

void main() {
    vec4 pos = vs_Pos + vs_Nor * perlin(vs_Pos.xyz * 0.5 + u_Time * 0.1);

    fs_Pos = u_Model * pos;
    fs_Nor = u_ModelInvTr * vs_Nor;

    gl_Position = u_ViewProj * u_Model * pos;
}