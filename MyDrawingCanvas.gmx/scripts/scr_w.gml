#define scr_w
///scr_w(percent)

var percent = argument0;

if(percent < 0) percent = 0;
else if(percent > 1) percent = 1;

return room_width * percent;


#define scr_h
///scr_h(percent)

var percent = argument0;

if(percent < 0) percent = 0;
else if(percent > 1) percent = 1;

return room_height * percent;