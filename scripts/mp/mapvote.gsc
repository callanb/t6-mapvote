#include maps\mp\_utility;

main() {
    preCacheMenu("mapvote");
    preCacheString(&"mp_raid");
    preCacheString(&"mp_slums");
    preCacheString(&"mp_village");
    preCacheString(&"mapvote_start");
    preCacheString(&"mapvote_state");
    preCacheString(&"mapvote_complete");
    maps\mp\gametypes\_globallogic_utils::registerPostRoundEvent(::mapvote);
    level thread onPlayerChat();
}

onPlayerChat() {
    for (;;) {
        level waittill("say", message, player, isHidden);
        mapvote();
    }
}

mapvote() {
    //if (!wasLastRound()) return;
    createMapvoteOptions();
    startMapvoteAll();
    wait 5;
    mapIndex = getMostVoted();
    notifyMapvoteCompleteAll(mapIndex);
    //setDvar("sv_mapRotation", "exec tdm " + level.mapvoteOptions[mapIndex]);
}

createMapvoteOptions() {
    level.mapvotePlayerVote = [];
    level.mapvoteOptions = [];
    level.mapvoteVotes = [];
    level.mapvoteOptions[0] = "mp_raid";
    level.mapvoteOptions[1] = "mp_slums";
    level.mapvoteOptions[2] = "mp_village";
    level.mapvoteVotes[0] = 0;
    level.mapvoteVotes[1] = 0;
    level.mapvoteVotes[2] = 0;
}

startMapvote() {
    self openMenu("mapvote");
    self notifyMapvoteStart();
    self thread onMapvoteResponse();
}

startMapvoteAll() {
    foreach (player in level.players) {
        player startMapvote();
    }
}

notifyMapvoteStart() {
    self luiNotifyEvent(&"mapvote_start", 3, istring(level.mapvoteOptions[0]), istring(level.mapvoteOptions[1]), istring(level.mapvoteOptions[2]));
}

notifyMapvoteStartAll() {
    foreach (player in level.players) {
        player notifyMapvoteStart();
    }
}

notifyMapvoteState() {
    self luiNotifyEvent(&"mapvote_state", 3, level.mapvoteVotes[0], level.mapvoteVotes[1], level.mapvoteVotes[2]);
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
    mostVoted = level.mapvoteVotes[0];
    if(level.mapvoteVotes[1] > mostVoted) mostVoted = level.mapvoteVotes[1];
    if(level.mapvoteVotes[2] > mostVoted) mostVoted = level.mapvoteVotes[2];
    return mostVoted;
}