# Proof of concept T6 LUI mapvote. 
## Note
- Controller / arrow key navigation has not yet been added.
- Client overflow could be an issue with the frequency LUI notify events are sent, could change it to update each client every second, rather than on every vote.
- The way the mapvote is attached to the main endGame function hasn't really been tested for hiccups. Setting the client state to not "intermission" seems to be
required for the menu buttons to work, haven't explored why. The idea here is to have it appear after the intermission rather than tacking it on as a post round event.
- This is a quick and dirty demonstration of what can be done with LUI, I have no doubt that there may be better ways to achieve the same result, and that there is a lot more that
can be done with LUI given some time.
