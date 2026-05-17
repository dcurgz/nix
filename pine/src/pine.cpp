#include "light.h"

#include <raylib.h>

#include <cstdio>

//TODO
#if defined(PLATFORM_DESKTOP)
    #define GLSL_VERSION            330
#else   // PLATFORM_ANDROID, PLATFORM_WEB
    #define GLSL_VERSION            100
#endif

const int V_SCREEN_WIDTH = 256;
const int V_SCREEN_HEIGHT = 192;
const int V_SCALE = 4;

const int SCREEN_WIDTH = V_SCREEN_WIDTH * V_SCALE;
const int SCREEN_HEIGHT = V_SCREEN_HEIGHT * V_SCALE;

int main() {
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "pine");
    SetTargetFPS(360);

    const Texture2D EMPTY  = LoadTextureFromImage(LoadImage("resources/empty.png"));
    const Texture2D BRICK  = LoadTextureFromImage(LoadImage("resources/brick.png"));
    const Texture2D SELECT = LoadTextureFromImage(LoadImage("resources/select.png"));

    const Texture2D BRICK_NORMAL = LoadTextureFromImage(LoadImage("resources/brick.normal.png"));

    RenderTexture2D vscreen = LoadRenderTexture(V_SCREEN_WIDTH, V_SCREEN_HEIGHT);
    Rectangle vscreen_src = Rectangle { 0.0f, 0.0f, V_SCREEN_WIDTH, -V_SCREEN_HEIGHT };
    Rectangle vscreen_dst = Rectangle { 0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT };
    Vector2   vscreen_org = { 0.0f };

    Camera2D camera = { 0.0f };
    camera.zoom = 1.0f;

    Light light = { };
    light.position = Vector2 { 25.0f, 25.0f };
    light.color = Vector3 { 1.0f, 1.0f, 1.0f };
    light.strength = 1.0f;

    Shader shader = LoadShader("shaders/light.vert",
                               "shaders/light.frag");
    {
        int loc = GetShaderLocation(shader, "lightColor_vec3");
        SetShaderValue(shader, loc, &light.color, SHADER_UNIFORM_VEC3);
    }
    {
        int loc = GetShaderLocation(shader, "lightStrength_f");
        SetShaderValue(shader, loc, &light.strength, SHADER_ATTRIB_FLOAT);
    }

    int shader_texture_loc = GetShaderLocation(shader, "tileTexture_sampler2d");

    int tile_width = 32;
    int tilemap_width  = V_SCREEN_WIDTH/tile_width;
    int tilemap_height = V_SCREEN_WIDTH/tile_width;
    const Texture2D* tilemap[tilemap_width][tilemap_height];
    for (int i=0; i<tilemap_width; i++)
        for (int j=0; j<tilemap_height; j++)
            tilemap[i][j] = &BRICK;

    while (! WindowShouldClose()) {
        // VIRTUAL
        BeginTextureMode(vscreen);
        BeginMode2D(camera);
        BeginShaderMode(shader);

        Vector2 mouse = GetMousePosition();
        Vector2 mouse_world = Vector2 { mouse.x / V_SCALE, mouse.y / V_SCALE };
        {
            int loc = GetShaderLocation(shader, "lightPos_vec2");
            SetShaderValue(shader, loc, &mouse_world, SHADER_UNIFORM_VEC2);
        }

        ClearBackground(RAYWHITE);
        for (int i=0; i<tilemap_width; i++) {
            for (int j=0; j<tilemap_height; j++) {
                SetShaderValueTexture(shader, shader_texture_loc, *tilemap[i][j]);
                DrawTexture(*tilemap[i][j], i*tile_width, j*tile_width, WHITE);
            }
        }

        EndMode2D();
        EndShaderMode();
        EndTextureMode();

        // SCALED
        BeginDrawing();
        ClearBackground(RAYWHITE);
        DrawTexturePro(vscreen.texture, vscreen_src, vscreen_dst, vscreen_org, 0, WHITE);
        EndDrawing();
    }

    UnloadShader(shader);
    UnloadTexture(EMPTY);
    UnloadTexture(BRICK);
    UnloadTexture(BRICK_NORMAL);
    UnloadTexture(SELECT);

    CloseWindow();
    return 0;
}
