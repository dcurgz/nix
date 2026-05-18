#version 330

// raylib
in vec3 vertexPosition;

// light.vert
in vec2 fragTexCoord;
in vec4 fragColor;

// light.vert
in vec3 fragPosition;

uniform vec2 lightPos_vec2;
uniform vec3 lightColor_vec3;
uniform float lightStrength_f;

uniform sampler2D tileTexture_sampler2d;
uniform sampler2D tileNormal_sampler2d;

out vec4 finalColor;

void main() {
    vec3 base_color = texture(tileTexture_sampler2d, fragTexCoord).xyz;
    vec3 normal     = texture(tileNormal_sampler2d, fragTexCoord).rgb * 2.0 - 1.0;
    normal = normalize(normal);
    normal.y = -normal.y;

    vec3 light_pos = vec3(lightPos_vec2, 1.0f);
    vec3 light_dir = normalize(light_pos - fragPosition);

    float norm_c = max(dot(normal, light_dir), 0.0f);

    float dist  = distance(lightPos_vec2, fragPosition.xy);
    float atten = lightStrength_f / (2.5 + 0.1 * dist + 0.001 * dist * dist);
    //float atten = smoothstep(100, 0, dist);
    vec3 diffuse = lightColor_vec3 * atten * max(0.3f, norm_c);
    finalColor = vec4(diffuse * base_color, 1.0f);
}
