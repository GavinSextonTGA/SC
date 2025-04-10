# Code Analysis
## Link To Google Slide
https://docs.google.com/presentation/d/1VkP_rdohF_pCfckdcEk1XHE7P1hJ1xp_qZoeTA-bOIs/edit#slide=id.g34c7873ac3e_0_78
## Link to Code
https://sccode.org/1-5hc
### markdown will be everything in the presentation
# Artistic Analysis
The Piece is entirely one chord pictured here. If you’re brave enough you can analyze the chord for yourself, as its very discordant.
With how many notes it has its more useful to note what notes it doesn’t have, being C, F, and F#.


The Piece is divided into what I would call 3 movements, all of them use this chord and don’t really spread the notes to the point where a real melody is recognizable. The piece different every time the code is run.

## Movement I
Movement I is the most discordant and honestly my least favorite movement. The quick repeated stabs of the entire chord with the changes only being in the velocity of the notes is really the only thing going on.


The feel is overwhelming and uneasy, there is a pattern in the velocity changes and it creates a weird sort of swell.


## Movement II
Movement II is where things get a bit more interesting, the chords separate a bit and the velocities that are louder carve out a sort of ostinato. The emphasis moves from the midrange to the top and then the bottom of the piano.


This one is a bit more listenable to me, the dynamic range and changes are more interesting.


## Movement III
Movement III is peak cinema.
The chord gets arpeggiated a bit and randomly, starting very close together, then drifting further and further apart. To where one chord takes forever.


Honestly it’s beautiful and sad, idk why but the simple act of it slowing down and getting quieter is actually beautiful.


# Code Analysis
The piece sends virtual midi out to a digital piano in order to produce sound. It is hard coded to have 24 different notes. The midi notes go through a lot of randomization and end up creating the weird art seen above. It also uses extensions for some midi functions it seems.


## Variables
The first thing the code does outside from waiting for the server to boot is declare a bunch of variables.
Most are self explanatory, but the bins are the unique pitches that are being played, lut is a table of the 4 variables below it that gets set later, and idx is the timer that counts up to 915 to determine the length of the piece as well as the movements.


## Set Up
The whole process gets initialized when the user presses (cmd + . ).
It does stuff that I assume is just getting the Midi client ready, sets the number of bins (or pitches) to 24, creates a table to track and randomize the period, phase, rangemin, and rangemax using a sin wav (i think?!?!).
It then randomizes the pitches of the bins and then sorts them in order of their pitch.
Finally, index (the clock) is set at 0.


## Creating the Piece (0)
With the pitches set and the clock wound up, things are ready to get started.
It also gets too complicated for me to fully understand so I had ChatGPT give its 2 cents with this one, I didn’t use it extensively though.
It is half debugging and half randomization with reading the lut (which I now know stands for look up table)
Notably the first range of the idx doesn’t have the delay_between_chords, which explains the difference between movements 1 and 2.
Most of the velocity randomization seems to come from reading the lut differently.


## Creating the Piece (1)
Section 3 does exactly what I would expect it to do, strumming them very slowly in a random order, then as idx goes past 890 the strum = strum  * 1.2 makes the slowing down sequence we get, and the ampmod gets lessened, lessening the volume. The delay between the chords also get smaller.


## Creating the Piece (10)
The end of the loop of the creation code, this has the stopping point when idx is 915, sets some variables to wait? It also contains the actual midi data to be sent in with note on, with its pitch with bin, amp with ampmod, and the final index of the lut data after one run through the loop, for each bin.
The delay code is after it, having it wait a bit before turning the midi note off on each bin.
Idx = idx +1 means we’re counting up and repeating.
The notes are turned off at the end of the piece, and then prints The End.
