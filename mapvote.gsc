#include maps/mp/gametypes/_hud_util;
#include common_scripts/utility;
#include maps/mp/_utility;

init(){
    maps = strtok("mp_la,mp_dockside,mp_carrier,mp_drone,mp_express,mp_hijacked,mp_meltdown,mp_overflow,mp_nightclub,mp_raid,mp_slums,mp_village,mp_turbine,mp_socotra,mp_nuketown_2020,mp_downhill,mp_mirage,mp_hydro,mp_skate,mp_concert,mp_magma,mp_vertigo,mp_studio,mp_uplink,mp_bridge,mp_castaway,mp_paintball,mp_dig,mp_frostbite,mp_pod,mp_takeoff", ",");
    level.mvprev = getdvar("mapname");
    arrayremovevalue(maps, level.mvprev);
    level.mvnext = maps[randomint(maps.size)];
    arrayremovevalue(maps, level.mvnext);
    level.mvrand = maps[randomint(maps.size)];
    precacheshader("loadscreen_" + level.mvprev);
    precacheshader("loadscreen_" + level.mvnext);
    precacheshader("loadscreen_" + level.mvrand);
    precacheshader("line_horizontal");
    maps\mp\gametypes\_globallogic_utils::registerpostroundevent(::mapvote);
}

mapvote(){
    if(!waslastround()) return;
    display();
    foreach(player in level.players) player thread input();
    timer();
    results();
}

display(){
    visionsetnaked("mpintro", 1);
    level.mvui[0] = text("objective", 1, "CENTER", "CENTER", -270, 35, undefined, 0, 3);
    level.mvui[1] = text("objective", 1, "CENTER", "CENTER", -70, 35, undefined, 0, 3);
    level.mvui[2] = text("objective", 1, "CENTER", "CENTER", 130, 35, undefined, 0, 3);
    level.mvui[3] = shader("white", "CENTER", "CENTER", -270, 35, 10, 10, (0, 0, 0), 1, 2);
    level.mvui[4] = shader("white", "CENTER", "CENTER", -70, 35, 10, 10, (0, 0, 0), 1, 2);
    level.mvui[5] = shader("white", "CENTER", "CENTER", 130, 35, 10, 10, (0, 0, 0), 1, 2);
    level.mvui[6] = shader("loadscreen_" + level.mvprev, "CENTER", "CENTER", -200, 0, 160, 90, (1, 1, 1), 1, 1);
    level.mvui[7] = shader("loadscreen_" + level.mvnext, "CENTER", "CENTER", 0, 0, 160, 90, (1, 1, 1), 1, 1);
    level.mvui[8] = shader("loadscreen_" + level.mvrand, "CENTER", "CENTER", 200, 0, 160, 90, (1, 1, 1), 1, 1);
    level.mvui[9] = text("objective", 1, "LEFT", "CENTER", -265, 35, &"PREV", undefined, 2);
    level.mvui[10] = text("objective", 1, "LEFT", "CENTER", -65, 35, &"NEXT", undefined, 2);
    level.mvui[11] = text("objective", 1, "LEFT", "CENTER", 135, 35, &"RANDOM", undefined, 2);
    level.mvui[12] = shader("line_horizontal", "CENTER", "CENTER", 0, -99, 160, 15, (0, 0, 0), 1, 2);
    level.mvui[13] = text("objective", 1.5, "CENTER", "CENTER", 0, -100, &"MAP SELECTION: ", 30, 2);
    level.mvui[14] = text("objective", 1, "CENTER", "CENTER", 0, -80, &"[{+smoke}]          ^3[{+activate}]^7          [{+frag}]", undefined, 2);
    level.mvui[15] = text("objective", 1, "RIGHT", "CENTER", -125, 35, maptostring(level.mvprev), undefined, 2);
    level.mvui[16] = text("objective", 1, "RIGHT", "CENTER", 75, 35, maptostring(level.mvnext), undefined, 2);
    level.mvui[17] = text("objective", 1, "RIGHT", "CENTER", 275, 35, maptostring(level.mvrand), undefined, 2);
    level.mvui[18] = shader("white", "CENTER", "CENTER", -199, 1, 160, 90, (0, 0, 0), 0.4, 0);
    level.mvui[19] = shader("white", "CENTER", "CENTER", 1, 1, 160, 90, (0, 0, 0), 0.4, 0);
    level.mvui[20] = shader("white", "CENTER", "CENTER", 201, 1, 160, 90, (0, 0, 0), 0.4, 0);
}

input(){
    self endon("disconnect");
    self endon("mvtimer");
    self notifyonplayercommand("left", "+smoke");
    self notifyonplayercommand("right", "+frag");
    self notifyonplayercommand("select", "+usereload");
    self notifyonplayercommand("select", "+activate");
    self.mvbox[0] = shader("white", "BOTTOM", "CENTER", 0, 45, 160, 1, (1, 0.6, 0), 1, 2);
    self.mvbox[1] = shader("white", "TOP", "CENTER", 0, -45, 160, 1, (1, 0.6, 0), 1, 2);
    self.mvbox[2] = shader("white", "LEFT", "CENTER", 80, 0, 1, 90, (1, 0.6, 0), 1, 2);
    self.mvbox[3] = shader("white", "RIGHT", "CENTER", -80, 0, 1, 90, (1, 0.6, 0), 1, 2);
    self setblur(3, 1);
    self.mvindex = 0;
    for(;;){
        command = self waittill_any_return("left", "right", "select");
        if(command == "left" && self.mvindex > -1){
            self.mvindex--;
            foreach(shader in self.mvbox) shader.x -= 200;
        }else if(command == "right" && self.mvindex < 1){
            self.mvindex++;
            foreach(shader in self.mvbox) shader.x += 200;
        }else if(command == "select"){
            if(!isdefined(self.mvsel)){
                self.mvsel = self.mvindex;
                level.mvui[self.mvsel + 1].value++;
                level.mvui[self.mvsel + 1] setvalue(level.mvui[self.mvsel + 1].value);
            }else if(self.mvsel != self.mvindex){
                level.mvui[self.mvsel + 1].value--;
                level.mvui[self.mvsel + 1] setvalue(level.mvui[self.mvsel + 1].value);
                self.mvsel = self.mvindex;
                level.mvui[self.mvsel + 1].value++;
                level.mvui[self.mvsel + 1] setvalue(level.mvui[self.mvsel + 1].value);
            }
        }
    }
}

timer(){
    for(i = 0; i < 25; i++){
        level.mvui[13] setvalue(25 - i);
        wait 1;
    }
    level notify("mvtimer");
}

results(){
    map = level.mvprev;
    best = level.mvui[0].value;
    if(level.mvui[1].value > best){
        best = level.mvui[1].value;
        map = level.mvnext;
    }
    if(level.mvui[2].value > best){
        best = level.mvui[2].value;
        map = level.mvrand;
    }
    setdvar("sv_maprotation", getdvar("custom_gametype") + " map " + map);
}

text(font, fontscale, align, relative, x, y, label, value, sort){
    element = createserverfontstring(font, fontscale);
    element.hidewheninmenu = true;
    element.sort = sort;
    element setpoint(align, relative, x, y);
    if(label != undefined) element.label = label;
    if(value != undefined){
        element setvalue(value);
        element.value = value;
    }
    return element;
}

shader(shader, align, relative, x, y, width, height, color, alpha, sort){
    element;
    element = isplayer(self) ? newclienthudelem(self) : newhudelem(self);
    element.elemtype = "bar";
    element.hidewheninmenu = true;
    element.xoffset = 0;
    element.yoffset = 0;
    element.children = [];
    element.sort = sort;
    element.color = color;
    element.alpha = alpha;
    element setparent(level.uiparent);
    element setshader(shader, width, height);
    element setpoint(align, relative, x, y);
    return element;
}

maptostring(map){
    switch(map){
        case "mp_la": return &"AFTERMATH";
        case "mp_dockside": return &"CARGO";
        case "mp_carrier": return &"CARRIER";
        case "mp_drone": return &"DRONE";
        case "mp_express": return &"EXPRESS";
        case "mp_hijacked": return &"HIJACKED";
        case "mp_meltdown": return &"MELTDOWN";
        case "mp_overflow": return &"OVERFLOW";
        case "mp_nightclub": return &"PLAZA";
        case "mp_raid": return &"RAID";
        case "mp_slums": return &"SLUMS";
        case "mp_village": return &"STANDOFF";
        case "mp_turbine": return &"TURBINE";
        case "mp_socotra": return &"YEMEN";
        case "mp_nuketown_2020": return &"NUKETOWN 2025";
        case "mp_downhill": return &"DOWNHILL";
        case "mp_mirage": return &"MIRAGE";
        case "mp_hydro": return &"HYDRO";
        case "mp_skate": return &"GRIND";
        case "mp_concert": return &"ENCORE";
        case "mp_magma": return &"MAGMA";
        case "mp_vertigo": return &"VERTIGO";
        case "mp_studio": return &"STUDIO";
        case "mp_uplink": return &"UPLINK";
        case "mp_bridge": return &"DETOUR";
        case "mp_castaway": return &"COVE";
        case "mp_paintball": return &"RUSH";
        case "mp_dig": return &"DIG";
        case "mp_frostbite": return &"FROST";
        case "mp_pod": return &"POD";
        case "mp_takeoff": return &"TAKEOFF";
        default: return &"MAP";
    }
}
