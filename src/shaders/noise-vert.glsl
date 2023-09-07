#version 300 es
precision highp float;

// keep these uniforms to simplify the code in main.ts
uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
in vec4 vs_Pos;
out vec4 fs_Pos;

void main() {
    fs_Pos = vs_Pos;
    gl_Position = vs_Pos;
}