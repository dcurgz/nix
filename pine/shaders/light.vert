#version 330

// raylib
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;

out vec2 fragTexCoord;
out vec4 fragColor;

// fragment in world-space
out vec3 fragPosition;

// raylib
uniform mat4 matView;
uniform mat4 matProjection;
uniform mat4 matModel;

void main() {
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;
    gl_Position = matModel * matView * matProjection * vec4(vertexPosition, 1.0);
    fragPosition = vec3(matModel * vec4(vertexPosition, 1.0));
}
