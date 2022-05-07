
(
Buffer.freeAll;
~recordingDuration = 1;
s = Server.local;
c = Buffer.alloc(s, 44100 * ~recordingDuration, 2, bufnum: 2);

(

SynthDef(\playRaw, { |amp = 1, left = 0, right = 1, gate = 1|
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);
	var sig = SoundIn.ar([left,right]);
	Out.ar(0, sig * amp * env)
}).add;


SynthDef(\play1, { |amp = 1, left = 0, right = 1, gate = 1|
	var env = Linen.kr(gate, 5, 1, 5, 2);
	var sig = SoundIn.ar([left,right]);
	Out.ar(0, sig * amp * env)
}).add;

SynthDef(\play2, { |amp = 1, left = 0, right = 1, gate = 1|
	var env = Linen.kr(gate, 3, 1, 1, 2);
	var sig = SoundIn.ar([left,right]);
	Out.ar(0, sig * amp * env)
}).add;

(
SynthDef(\playback, {|start = 0, length = 44100, amp = 1, atk 0.05, rel = 0.05, pitchRange = 0.3, min = 300, max = 5000|

	var sustain = ~recordingDuration;
	var playRate = LFNoise0.ar(0.5, pitchRange, 1);
	var phasor = Phasor.ar(0, BufRateScale.ir(c) * playRate, 0, length * ~recordingDuration) + start;
	var env = EnvGen.ar(Env([0, amp, amp, 0], [atk, sustain, rel]), doneAction:2);
	var snd = BufRd.ar(2, c, phasor) * env;
	Out.ar(0, snd * amp)

}).add
);

SynthDef(\play3, { |amp = 1, left = 0, gate = 1|
	var right = (left - 1).abs;
	var env = Linen.kr(gate, 0.7, 1, 0.7, 2);
	var sig = SoundIn.ar([left, right]);
	XOut.ar(0, Lag3.kr(1, 4) * env, sig * amp)
}).add;

SynthDef(\play4, { |amp = 1, left = 0, right = 1, gate = 1|
	var env = Linen.kr(gate, 3, 1, 5, 2);
	var sig = SoundIn.ar([left,right]);
	Out.ar(0, sig * amp * env)
}).add;


///////////   EFFECTS   ///////////


e = { |name, func|
SynthDef(name, { |gate = 1, wet = 1, lag = 5|
	var in, sig, env;
	in = In.ar(0, 2);
	env = Linen.kr(gate, 2, 1, 2, 2);
	sig = SynthDef.wrap(func, prependArgs: [in, env, lag]);

	XOut.ar(0, Lag3.kr(wet, lag) * env, sig);
}).add;
};


e.value(\lpf, { |in, env, lag, lpfFreq = 350|

	var lpf = LPF.ar(in, lpfFreq);
	lpf*3.7;
});


e.value(\rlpf, { |in, env, lag, lpfFreq = 100|

	var rlpf = RLPF.ar(in, lpfFreq, 0.1);
	rlpf;
});


e.value(\lpfFreqShift, { |in, env, lag, lpfFreq = 300|

	var shift = lpfFreq + Array.linrand(12, lpfFreq, lpfFreq * 3);
	var freqShift = FreqShift.ar(in, Mix.ar(shift));
	freqShift * 0.75
});


e.value(\reverb, {|in, env, lag|

	var sound = in;
	6.do {sound = AllpassN.ar(sound, 0.040, [0.040.rand,0.040.rand], 2)};
	sound

});


// for 2
e.value(\bpf, { |in, env, lag, freq = 300, freq2 = 800, rq = 1.5|

	var bpf = BPF.ar(in, [freq2, freq], rq, 1, rrand(0.1,0.8), rrand(0.4,1));
	bpf

});

// for 4

e.value(\rlpf2, { |in, env, lag, freq = 570|

	var rlpf = RLPF.ar(in, freq, 0.1);
	var car = Pitch.kr(in, 2);
	var pitch = in * PMOsc.ar(car, LFDClipNoise.ar(50).range(555,565), 1);
	pitch*0.3 + rlpf*SinOsc.ar(0.05).range(0.5,1.2);
});

);



//////     1    //////

(

~routine = {Tdef(\1, {

	"stage0".postln;
	(~play1 = Synth(\play1);
		~lpf = Synth(\lpf);
		~lpf.moveAfter(~play1);
		~reverb = Synth(\reverb);
		~reverb.moveAfter(~lpf)
	);

	45.wait;

	"stage1".postln;
	(~rlpf = Synth(\rlpf);
		~rlpf.moveAfter(~lpf);
	);

	35.wait;

	"stage2".postln;

	(~lpfFreqShift = Synth(\lpfFreqShift);
		~lpfFreqShift.moveAfter(~lpf);
		~lpfFreqShift.set(\lpfFreq, 2);
	);

	25.wait;

	"stage3".postln;

	~lpfFreqShift.release(5);
	~rlpf.release(10);

})}
);



//////   2   //////

(

~set2 = {

Tdef(\td, {

	inf.do{|i|
		SynthDef(\recordBuf, {|out = 0|
		var in = SoundIn.ar([0,1]);
		RecordBuf.ar(in, c.bufnum, doneAction: Done.freeSelf, loop:0);
	}).play(s, [\out, 0, \bufnum, c.bufnum]);

	~recordingDuration.wait;

	s.sync;

	}

}).play;


(
Tdef(\tplayback, {

	inf.do{|i|

		~playback = Synth(\playback);

		(~recordingDuration / rrand(2,8)).wait;

		~playback = Synth(\playback);

		(~recordingDuration / rrand(2,8)).wait;

		~playback = Synth(\playback);

		(~recordingDuration / rrand(2,8)).wait;

		~playback = Synth(\playback);

		(~recordingDuration / rrand(2,8)).wait;

		~playback = Synth(\playback);

		(~recordingDuration / rrand(2,8)).wait;


	s.sync;

	}

}).play;
);

~play2 = Synth(\play2);
~bpf = Synth(\bpf);
~bpf.moveAfter(~playback);

}

);

///////  3   ///////

(
Tdef(\3, {

	loop{

		~play3.set(\left, 1);

		rrand(30,60).wait;

		~play3.set(\left, 0);

		rrand(30,60).wait;

	};


})
)


)















