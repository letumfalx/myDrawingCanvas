#define scr_surface
///scr_surface();
if(!surface_exists(global.canvas)) {
    global.canvas = surface_create(room_width, room_height);
}

if(!surface_exists(global.controls)) {
    global.controls = surface_create(room_width, room_height);
}



#define scr_surface_clear
///scr_surface_clear();
if(surface_exists(global.canvas)) {
    surface_set_target(global.canvas);
    draw_clear_alpha(background_color, 1);
    surface_reset_target();
}

if(surface_exists(global.controls)) {
    surface_set_target(global.controls);
    draw_clear_alpha(background_color, 0);
    surface_reset_target();
}




#define scr_surface_draw
///scr_surface_draw();

if(surface_exists(global.canvas)) {
    draw_surface(global.canvas, 0, 0);
}

if(surface_exists(global.controls)) {
    draw_surface(global.controls, 0, 0);
}



#define scr_surface_destroy
///scr_surface_destroy();
if(surface_exists(global.canvas)) {
    surface_free(global.canvas);
}

if(surface_exists(global.controls)) {
    surface_free(global.controls);
}


#define scr_surface_set
///scr_surface_set(target)


scr_surface();
switch(string_lower(argument0)) {
    case "canvas":
        surface_set_target(global.canvas);
        break;
    case "controls":
    case "control":
        surface_set_target(global.controls);
        break;
    default:
        surface_reset_target();
}

#define scr_surface_reset
//scr_surface_reset();

surface_reset_target();