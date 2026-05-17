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

out vec4 finalColor;

void main() {
    //vec2 lightDir = normalize(lightPos_vec2 - fragPosition.xy);
    float lightDistance = length(lightPos_vec2 - fragPosition.xy);
    lightDistance = lightDistance/32;
    float lightIntensity = min(1.0f, lightStrength_f/lightDistance);
    vec3 color = texture(tileTexture_sampler2d, fragTexCoord).xyz;
    finalColor = vec4(lightIntensity * color, 1.0f);
}
