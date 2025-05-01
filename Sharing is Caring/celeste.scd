s.boot;

s.options.numBuffers = 1024 * 256;
s.options.memSize = 2.pow(20);
s.options.maxNodes = 1024 * 32;
s.options.numOutputBusChannels = 2; // total number of output channels
s.options.numInputBusChannels = 2;
~reverbBus = Bus.audio(s,2)
// REVERB from example
(
Ndef(\verb, { |inBus = 0|
    var input = In.ar(inBus, 2);
    var delrd, sig, deltimes, output;
	delrd = LocalIn.ar(4);

	// This will be our eventual output, which will also be recirculated
	output = input + delrd[[0,1]];

	// Cross-fertilise the four delay lines with each other:
	sig = [output[0]+output[1], output[0]-output[1], delrd[2]+delrd[3], delrd[2]-delrd[3]];
	sig = [sig[0]+sig[2], sig[1]+sig[3], sig[0]-sig[2], sig[1]-sig[3]];
	// Attenutate the delayed signals so they decay:
	sig = sig * [0.4, 0.37, 0.333, 0.3];

	// Here we give delay times in milliseconds, convert to seconds,
	// then compensate with ControlDur for the one-block delay
	// which is always introduced when using the LocalIn/Out fdbk loop
	deltimes = [101, 143, 165, 177] * 0.001 - ControlDur.ir;

	// Apply the delays and send the signals into the feedback loop
	LocalOut.ar(DelayC.ar(sig, deltimes, deltimes));

	// Now let's hear it:
	output

}).play
)
(
SynthDef(\celesteBass, {
    // Mouse Control
    var freq = MouseY.kr(55, 220, 0.05, 0.5);

    // Parameters
	    // Filter LFO
	var flfoRate = 0.2;
    var flfoDepth = 8000;
        // Chorus
	var clfoRate = 0.5;
    var clfoDepth = 2;
    var numVoices = 4;
    var maxDelay = 0.02;

    // Sound Sources
    var basA = LFSaw.ar(freq, 0, 0.4);
    var basB = SinOsc.ar(freq, 0, 0.3);
    var basC = PinkNoise.ar(0.5) * (-10.dbamp);

    // Filter for Saw Wave
    var cutoff = SinOsc.kr(flfoRate).range(freq, freq + flfoDepth);
    var resonance = LinLin.kr(flfoDepth, 0, 2000, 0.1, 0.8);
    var filtered = RLPF.ar(basA, cutoff, resonance.reciprocal.sqrt);

    // Dry mix (before chorus)
    var dryMix = filtered + basB + basC;

    // Chorus
    var chorus = Mix.fill(numVoices, { |i|
        var lfo = SinOsc.kr(clfoRate * Rand(0.9, 1.1), phase: Rand(0, 2pi));
        var detune = lfo * clfoDepth;

        // Chorus to Each Voice Individually
        var chorusVoice = (
            RLPF.ar(
                LFSaw.ar(freq + detune, 0, 0.5),
                cutoff,
                resonance.reciprocal.sqrt
            ) +

            SinOsc.ar(freq + detune, 0, 0.5) +
            basC
        );

        DelayC.ar(
            chorusVoice,
            maxDelay * 2,
            (lfo * 0.5 + 0.5) * maxDelay // Moving delay
        ) * 0.15 // Voice volume
    });

    // Final output (dry + wet)
    var output = (dryMix * 0.5) + (chorus);

	// EQ
    // Bass Boost
    output = BHiPass.ar(output, 40, 0.8, 5);
    // Mids
    output = BPeakEQ.ar(output, 250, 0.8, -4);
    // Presence
    output = BPeakEQ.ar(output, 3000, 0.5, 3);
    // Highs
    output = BHiShelf.ar(output, 8000, 1.0, 0);
    // Safety limiter
    output = Limiter.ar(output, 0.99);

	output = output * (-15.dbamp);// Things are always too loud
    Out.ar(0, output ! 2);
}).add;
)


// Celeste Lead
(
SynthDef(\celesteLead, {
    var preFreq = MouseY.kr(55, 220, 0.05, 0.5);
	var baseFreq = preFreq *4; // 2 octaves above bass
    var freq = \freqRatio.kr(1) * baseFreq;
    var env = EnvGen.kr(
        Env.new(
            [0, 1, 0.6, 0],                // levels: attack, sustain, release
            [0.01, 0.4, 0.4],             // times
            \gate.kr(1),                   // gate control
            doneAction: 2
        )
    );

    // Sine waves with envelope applied
	var leadA = SinOsc.ar(freq * 2, 0, 0.3) * env;
	var leadB = SinOsc.ar(freq, 0, 0.3) * env;
	var leadC = Pulse.ar(freq * 0.5 , 0.5, 0.3) * env;
	var leadD = PinkNoise.ar(0.5)* (-5.dbamp) * env;
    var output = leadA + leadB + leadC + leadD;

//EQ
    // Lows
    output = BHiPass.ar(output, 40, 0.8, 0.8);
    // Mids
    output = BPeakEQ.ar(output, 250, 0.8, -4);
    // Pressence
    output = BPeakEQ.ar(output, 3000, 0.5);
    // Highs
    output = BHiShelf.ar(output, 8000, 1.0);
    // Limiter
    output = Limiter.ar(output, 0.99);

	Out.ar(0, output ! 2);
}).add;
)

// ARPS

(
SynthDef(\celesteArp, {
    var env = EnvGen.kr(Env.perc(0.01, 1.2), doneAction: 2);
    var prefreq = MouseY.kr(55, 220, 0.05, 0.5);

    // Choose ONE random frequency from the list
    var freq = Select.kr(
        IRand(0, 3), // Random index 0-3
        [prefreq * 2, prefreq * 2.4, prefreq * 3, prefreq * 3.75]
    );

    // Sound sources (now using single frequency)
    var arpA = RLPF.ar(Saw.ar(freq), freq *2, 0.2) * 0.5 * env;
    var arpB = RLPF.ar(Pulse.ar(freq), freq *2, 0.2) * 0.5 * env;
    var arpC = RLPF.ar(SinOsc.ar(freq*2), freq *2, 0.2) * 0.5 * env;

    var output = arpA + arpB + arpC;
    Out.ar(0, output * (-18.dbamp) ! 2);
}).add;
)



//ROUTINE
(
var sixteenthNoteDur = 0.125; // 120BPM = 0.125s per 16th note
var clock = TempoClock(120/60); // 120 BPM


// This part is mostly AI, I don't know anything about routines
~routine = Routine({
    var idx = 0;
    var maxIdx = 16;
    var synths = List.new;
    loop {


        // Calculate position once per iteration
        var pos = idx % maxIdx;

        synths.do(_.free); synths.clear;
		if (idx == 0){ Synth(\celesteBass)};


        // First wait
        sixteenthNoteDur.wait;


        // more wait
        sixteenthNoteDur.wait;

        // Arp triggers
        if (pos % 2 == 0) { Synth(\celesteArp) };

        // Increment and loop
        idx = idx + 1;

        // Debug print every measure
        if (idx == 0) { ("Measure: " ++ (idx/maxIdx).asInteger).postln };
    };
}).play(clock);
)
// TESTING
x = Synth(\celesteLead);
x.free;

y = Synth(\celesteBass);
y.free

z = Synth (\celesteArp);
z.free
// To stop:

~routine.stop;



// KEY BINDINGS TO PLAY WITH LEAD
(
var window = Window.new("Hold keys: a=1, s=1.125, d=1.2, f=1.333, j=1.5, k=1.6, l=1.875, ;=2").front;
var synths = Dictionary.new;

window.view.keyDownAction = { |view, char, mod, unicode|
    case
    { (char == $a) && (synths[\a].isNil) }         { synths[\a] = Synth(\celesteLead, [\freqRatio, 1, \gate, 1]) }
    { (char == $s) && (synths[\s].isNil) }         { synths[\s] = Synth(\celesteLead, [\freqRatio, 1.125, \gate, 1]) }
    { (char == $d) && (synths[\d].isNil) }         { synths[\d] = Synth(\celesteLead, [\freqRatio, 1.2, \gate, 1]) }
    { (char == $f) && (synths[\f].isNil) }         { synths[\f] = Synth(\celesteLead, [\freqRatio, 1.333, \gate, 1]) }
    { (char == $j) && (synths[\j].isNil) }         { synths[\j] = Synth(\celesteLead, [\freqRatio, 1.5, \gate, 1]) }
    { (char == $k) && (synths[\k].isNil) }         { synths[\k] = Synth(\celesteLead, [\freqRatio, 1.6, \gate, 1]) }
    { (char == $l) && (synths[\l].isNil) }         { synths[\l] = Synth(\celesteLead, [\freqRatio, 1.875, \gate, 1]) }
    { (unicode == 59) && (synths[\semicolon].isNil) } { synths[\semicolon] = Synth(\celesteLead, [\freqRatio, 2, \gate, 1]) };
};

window.view.keyUpAction = { |view, char, mod, unicode|
    case
    { char == $a }          { synths[\a].set(\gate, 0); synths[\a] = nil }
    { char == $s }          { synths[\s].set(\gate, 0); synths[\s] = nil }
    { char == $d }          { synths[\d].set(\gate, 0); synths[\d] = nil }
    { char == $f }          { synths[\f].set(\gate, 0); synths[\f] = nil }
    { char == $j }          { synths[\j].set(\gate, 0); synths[\j] = nil }
    { char == $k }          { synths[\k].set(\gate, 0); synths[\k] = nil }
    { char == $l }          { synths[\l].set(\gate, 0); synths[\l] = nil }
    { unicode == 59 }       { synths[\semicolon].set(\gate, 0); synths[\semicolon] = nil };
};

window.onClose = {
    synths.do { |synth| synth.set(\gate, 0) };
    "All notes stopped".postln
};
)
