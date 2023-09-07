uniform float u_Time;

in vec4 fs_Pos;
out vec4 out_Color;

void main() {
    vec3 col = cos(perlin(fs_Pos.xyz) + vec3(2.0, 5.0, 9.0) * 0.1 + sin(u_Time * 0.25));
    out_Color = vec4(col, 1.0);
}