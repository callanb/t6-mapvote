#include maps\mp\_utility;
#include common_scripts\utility;

main() {
    level.mapvoteMaps = strTok(getDvarStringDefault("mapvote_maps", "mp_la,mp_dockside,mp_carrier,mp_drone,mp_express,mp_hijacked,mp_meltdown,mp_overflow,mp_nightclub,mp_raid,mp_slums,mp_village,mp_turbine,mp_socotra,mp_nuketown_2020,mp_downhill,mp_mirage,mp_hydro,mp_skate,mp_concert,mp_magma,mp_vertigo,mp_studio,mp_uplink,mp_bridge,mp_castaway,mp_paintball,mp_dig,mp_frostbite,mp_pod,mp_takeoff"), ",");
    level.mapvoteMode = getDvarStringDefault("mapvote_mode", "tdm");
    level.mapvoteVoteTime = getDvarIntDefault("mapvote_vote_time", 30);
    level.mapvoteEndTime = getDvarIntDefault("mapvote_end_time", 5);
    preCacheMenu("mapvote");
    preCacheString(&"mapvote_start");
    preCacheString(&"mapvote_state");
    preCacheString(&"mapvote_complete");
    maps\mp\gametypes\_globallogic_utils::registerPostRoundEvent(::mapvote);
}

mapvote() {
    if (!wasLastRound()) return;
    createMapvoteOptions();
    startMapvoteAll();
    wait level.mapvoteVoteTime;
    mapIndex = getMostVoted();
    notifyMapvoteCompleteAll(mapIndex);
    wait level.mapvoteEndTime;
    setDvar("sv_mapRotation", "exec " + level.mapvoteMode + " " + level.mapvoteOptions[mapIndex]);
}

createMapvoteOptions() {
    maps = array_randomize(level.mapvoteMaps);
    level.mapvotePlayerVote = [];
    level.mapvoteOptions = [];
    level.mapvoteVotes = [];
    level.mapvoteOptions[0] = maps[0];
    level.mapvoteOptions[1] = maps[1];
    level.mapvoteOptions[2] = maps[2];
    level.mapvoteVotes[0] = 0;
    level.mapvoteVotes[1] = 0;
    level.mapvoteVotes[2] = 0;
}

startMapvote() {
    self setClientDvar("mapvote_client_vote_time", level.mapvoteVoteTime * 1000);
    self setClientDvar("mapvote_client_end_time", level.mapvoteEndTime * 1000);
    self setClientDvar("mapvote_client_option_0", level.mapvoteOptions[0]);
    self setClientDvar("mapvote_client_option_1", level.mapvoteOptions[1]);
    self setClientDvar("mapvote_client_option_2", level.mapvoteOptions[2]);
    self openMenu("mapvote");
    self thread onMapvoteResponse();
}

startMapvoteAll() {
    foreach (player in level.players) {
        player startMapvote();
    }
}

notifyMapvoteState() {
    self luiNotifyEvent(&"mapvote_state", 3, getVotesAsPercentage(0), getVotesAsPercentage(1), getVotesAsPercentage(2));
}

notifyMapvoteStateAll() {
    foreach (player in level.players) {
        player notifyMapvoteState();
    }
}

notifyMapvoteComplete(votedMapIndex) {
    self notify("mapvote_complete");
    self luiNotifyEvent(&"mapvote_complete", 1, votedMapIndex + 1);
}

notifyMapvoteCompleteAll(votedMapIndex) {
    foreach (player in level.players) {
        player notifyMapvoteComplete(votedMapIndex);
    }
}

onMapvoteResponse() {
    self endon("disconnect");
    self endon("mapvote_complete");
    for (;;) {
        self waittill("menuresponse", menu, response);
        if (menu == "mapvote") {
            index = int(response);
            if (!isDefined(level.mapvotePlayerVote[self.guid])) {
                level.mapvotePlayerVote[self.guid] = index;
                level.mapvoteVotes[index]++;
                notifyMapvoteStateAll();
            } else if (level.mapvotePlayerVote[self.guid] != index) {
                level.mapvoteVotes[level.mapvotePlayerVote[self.guid]]--;
                level.mapvotePlayerVote[self.guid] = index;
                level.mapvoteVotes[index]++;
                notifyMapvoteStateAll();
            }
        }
    }
}

getMostVoted() {
    mostVoted = 0;
    if(level.mapvoteVotes[1] > mostVoted) mostVoted = 1;
    if(level.mapvoteVotes[2] > mostVoted) mostVoted = 2;
    return mostVoted;
}

getVotesAsPercentage(index) {
    return int(level.mapvoteVotes[index] / (level.mapvoteVotes[0] + level.mapvoteVotes[1] + level.mapvoteVotes[2]) * 100);
}

getDvarStringDefault(dvarName, defaultValue) {
    value = getDvar(dvarName);
    return value == "" ? defaultValue : value;
}