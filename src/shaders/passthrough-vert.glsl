#version 300 es

layout(location = 0) in vec3 vs_Pos;
layout(location = 1) in vec2 vs_UV;

out vec2 fs_UV;

void main()
{
    fs_UV = vs_UV;
    gl_Position = vec4(vs_Pos, 1.);
}