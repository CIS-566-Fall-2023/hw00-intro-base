uniform vec4 u_Color;
uniform float u_Time;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec3 fs_Pos;

out vec4 out_Col;

void main()
{
    // Material base color (before shading)
    float noise = (perlin(fs_Pos * 4.5 + u_Time * 0.25) + 1.0) / 2.0;
    if(step(0.5f, noise) == 0.0) {
        discard; 
    }
    vec4 diffuseColor = vec4(u_Color.rgb, 1.0);
    
    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    // Avoid negative lighting values
    // diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.2;
    float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                        //to simulate ambient lighting. This ensures that faces that are not
                                                        //lit by our point light are not completely black.

    // Compute final shaded color
    out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
