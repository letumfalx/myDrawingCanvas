#define scr_code
///scr_code(keyword);

//assign some string representation for the actions
switch(argument0) {
    
    case "client-draw": return 6;
    case "erase-pen": return 5;
    case "draw-pen": return 4;
    case "client-other": return 3;
    case "client-color": return 2;    
    case "client-broadcast": return 1;
    
    case "client-send": return -2;
    case "client-connected": return -1;
    case "client-disconnect": return -3;
    
}



#define scr_decode
///scr_decode(buffer);

//ready the buffer for reading
var buff = argument0;
buffer_seek(buff, buffer_seek_start, 0);

//gets the command in the first signed byte
//note that buffer loc increments per buffer_read
var info_type = buffer_read(buff, buffer_s8);

/*
info_type < 0 -> server decode
info_type > 0 -> client decode
*/

//checks and execute necessary functions base on the info_type

if(info_type == scr_code("client-send")) {
    var buffer = buffer_create(16, buffer_grow, 1);
    
    buffer_copy(buff, 1, buffer_get_size(buff) - 1, buffer, 0);    
    buffer_seek(buffer, buffer_seek_end, 0);
    scr_broadcast(buffer);
    buffer_delete(buffer);
    
}

//sends necessary data to the recently connected client and to all the other clients
else if(info_type == scr_code("client-connected")) {
    
    //send to all connected that a player has connected
    var buffer = buffer_create(16, buffer_grow, 1);                 //create a buffer with size 16 bytes that can grow and aligned 1 byte
    scr_buffer_set_header(buffer, "client-broadcast");              //set the header
    buffer_write(buffer, buffer_u8, obj_server.last_connected);     //set the index of the last connected
    buffer_write(buffer, buffer_string, obj_server.client_ip[obj_server.last_connected]);  //send the ip of the connected
    scr_broadcast(buffer);                                          //send the message to all connected
    buffer_delete(buffer);                                          //delete used buffer
    
    //send the color of the player
    buffer = buffer_create(16, buffer_grow, 1);                     //same as above
    scr_buffer_set_header(buffer, "client-color");                  //set header
    buffer_write(buffer, buffer_u8, obj_server.last_connected);     //set the data
    scr_buffer_send(obj_server.client_socket[obj_server.last_connected], buffer);      //send to only one player
    buffer_delete(buffer); 
    
    //send other connected player to the recently connected one
    buffer = buffer_create(16, buffer_grow, 1);
    scr_buffer_set_header(buffer, "client-other");
    for(var i=0; i<conn_max; i++) {
        buffer_write(buffer, buffer_string, obj_server.client_ip[i]);
    }
    scr_buffer_send(obj_server.client_socket[obj_server.last_connected], buffer);
    buffer_delete(buffer);
    
    var totalInk = instance_number(obj_ink);
    buffer = buffer_create(16, buffer_grow, 1);
    scr_buffer_set_header(buffer, "client-draw");
    buffer_write(buffer, buffer_u16, totalInk);
    for(var i=0; i<totalInk; i++) {
        var obj = instance_find(obj_ink, i);
        buffer_write(buffer, buffer_u8, scr_player_color_decode(obj.image_blend));
        buffer_write(buffer, buffer_s16, obj.x);
        buffer_write(buffer, buffer_s16, obj.y);
    }
    scr_buffer_send(obj_server.client_socket[obj_server.last_connected], buffer);
    buffer_delete(buffer);
}

//i forgot this
else if(info_type == scr_code("client-broadcast")) {        

    //set the client's player data
    var r_index = buffer_read(buff, buffer_u8);                     //get the first unsigned 8-bit data which is the index of player last connected
    var r_ip = buffer_read(buff, buffer_string);                    //get the string of the ip of the player last connected
    obj_client.client_ip[r_index] = r_ip;                           //set the client object's ip list
   
}

//sets the client's color
else if(info_type == scr_code("client-color")) {
    global.myColor = scr_player_color(buffer_read(buff, buffer_u8));    //set the color of the client in client
}

//sets other client's ip
else if(info_type == scr_code("client-other")) {
    for(var i=0; i<conn_max; i++) {
        obj_client.client_ip[i] = buffer_read(buff, buffer_string);
    }
}

//draw the pen
else if(info_type == scr_code("draw-pen") && obj_client.get_sim_info) {
    obj_client.get_sim_info = false;
    var color = scr_player_color(buffer_read(buff, buffer_u8));
    var pos_x = buffer_read(buff, buffer_s16);
    var pos_y = buffer_read(buff, buffer_s16);
    var obj = instance_position(pos_x, pos_y, obj_ink);
    if(obj == noone || obj.image_blend != color) {
        var obj2 = instance_create(pos_x, pos_y, obj_ink);
        obj2.image_blend = color;
    }
    obj_client.get_sim_info = true;
}
//i dont know this
else if(info_type == scr_code("erase-pen")) {
    var color = scr_player_color(buffer_read(buff, buffer_u8));
    var pos_x = buffer_read(buff, buffer_s16);
    var pos_y = buffer_read(buff, buffer_s16);
    var obj = instance_position(pos_x, pos_y, obj_ink);
    with(obj) {
        instance_destroy();
    }
}
else if(info_type == scr_code("client-disconnect")) {
    var index = buffer_read(buff, buffer_u8);
    obj_client.client_ip[index] = "";
}
else if(info_type == scr_code("client-draw")) {
    if(!obj_client.get_init_info) {
        var inkCount = buffer_read(buff, buffer_u16);
        for(var i=0; i<inkCount; i++) {
            var color = scr_player_color(buffer_read(buff, buffer_u8));
            var px = buffer_read(buff, buffer_s16);
            var py = buffer_read(buff, buffer_s16);
            var obj = instance_create(px, py, obj_ink);
            obj.image_blend = color;
            /*
            var obj = instance_position(px, py, obj_ink);
            if(obj == noone || obj.image_blend != global.myColor) {
                var obj2 = instance_create(px, py, obj_ink);
                obj2.image_blend = color;
            } 
            */
        }
        obj_client.get_init_info = true;
    }

/*
    var color = scr_player_color(buffer_read(buff, buffer_u8));
    var px = buffer_read(buff, buffer_s16);
    var py = buffer_read(buff, buffer_s16);
    var obj = instance_position(px, py, obj_ink);
    if(obj == noone || obj.image_blend != global.myColor) {
        var obj2 = instance_create(px, py, obj_ink);
        obj2.image_blend = color;
    }
*/
}


#define scr_buffer_send
///scr_buffer_send(socket, buffer);

//use to send any packet data from specified socket and buffer
network_send_packet(argument0, argument1, buffer_tell(argument1));

#define scr_broadcast
///scr_broadcast(buffer);

//use to send data all over the clients
for(var i=0; i<conn_max; i++) {
    if(obj_server.client_socket[i] != noone) {
        network_send_packet(obj_server.client_socket[i], argument0, buffer_tell(argument0));
    }
}


#define scr_buffer_reset
///scr_buffer_reset(buffer);

//reset the buffer's current position
buffer_seek(argument0, buffer_seek_start, 0);

#define scr_buffer_set_header
///scr_buffer_set_header(buffer, keyword);

//sets the header (the integer equivalent of the function keys in scr_code)
scr_buffer_reset(argument0);
buffer_write(argument0, buffer_s8, scr_code(argument1));


#define scr_buffer_set_header_client
///scr_buffer_set_header_client(buffer, keyword);

//use for sending data from a client to server to broadcast clients
scr_buffer_set_header(argument0, "client-send");
buffer_write(argument0, buffer_s8, scr_code(argument1));
