uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time;
in vec4 fs_Pos;
out vec4 out_Col;

void main()
{
    float noise = fbm(vec3(fs_Pos * 4.5 + u_Time * 0.25));
    noise = (noise + 1.0) / 2.0;
    out_Col = vec4(vec3(1.0) * noise, 1.0);
}