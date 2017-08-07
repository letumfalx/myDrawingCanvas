#define scr_player_color
///scr_player_color(player_number);

switch(argument0) {
    case 0:
        return c_blue;
    case 1:
        return c_green;
    case 2:
        return c_maroon;
    case 3:
        return c_orange;
    case 4:
        return c_teal;
    case 5:
        return c_yellow;
}
#define scr_player_color_decode
///scr_player_color_decode(color);

switch(argument0) {
    case c_blue:
        return 0;
    case c_green:
        return 1;
    case c_maroon:
        return 2;
    case c_orange:
        return 3;
    case c_teal:
        return 4;
    case c_yellow:
        return 5;
}