#include <raylib.h>

#include <cstdio>

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

    RenderTexture2D vscreen = LoadRenderTexture(V_SCREEN_WIDTH, V_SCREEN_HEIGHT);
    Rectangle vscreen_src = Rectangle { 0.0f, 0.0f, V_SCREEN_WIDTH, -V_SCREEN_HEIGHT };
    Rectangle vscreen_dst = Rectangle { 0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT };
    Vector2   vscreen_org = { 0.0f };

    int tile_width = 32;
    int tile_height = 32;
    int tilemap_width  = V_SCREEN_WIDTH/32;
    int tilemap_height = V_SCREEN_WIDTH/32;
    const Texture2D* tilemap[tilemap_width][tilemap_height];
    for (int i=0; i<tilemap_width; i++)
        for (int j=0; j<tilemap_height; j++)
            tilemap[i][j] = &EMPTY;

    bool mouse_down_prev = false;
    bool mouse_down = false;

    while (! WindowShouldClose()) {
        BeginTextureMode(vscreen);
        ClearBackground(RAYWHITE);
        for (int i=0; i<tilemap_width; i++)
            for (int j=0; j<tilemap_height; j++)
                DrawTexture(*tilemap[i][j], i*32, j*32, WHITE);

        Vector2 mouse = GetMousePosition();
        int tile_x = (mouse.x/V_SCALE) / 32;
        int tile_y = (mouse.y/V_SCALE) / 32;

        DrawTexture(SELECT, tile_x*32, tile_y*32, WHITE);
        EndTextureMode();

        if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT))
            mouse_down = true;
        else
            mouse_down = false;
        
        if (mouse_down && !mouse_down_prev) {
            //click
            tilemap[tile_x][tile_y] =
                tilemap[tile_x][tile_y] == &BRICK
                ? &EMPTY
                : &BRICK;
            printf("click\n");
        }

        BeginDrawing();
        ClearBackground(RAYWHITE);
        DrawTexturePro(vscreen.texture, vscreen_src, vscreen_dst, vscreen_org, 0, WHITE);
        EndDrawing();

        mouse_down_prev = mouse_down;
    }

    CloseWindow();
    return 0;
}
