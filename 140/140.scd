// Generator Starting :)
(
{
    e = Env([0, 0.4, 1, 0], [1,10]);
	Pan2.ar(PitchShift.ar(SinOsc.ar(40,0,30),0.02, Line.kr(0.8,20,10),1,0.001))*EnvGen.kr(e)
}.play
)
