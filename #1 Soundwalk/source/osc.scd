


https://hexler.net/touchosc#_    // website for download the app



// test of OSC communication

NetAddr.localAddr;

(
OSCdef.new(
	\toggle,
	{
		arg msg, time, addr, port;
		[msg, time, addr, port].postln;
	},
	'/1/toggle5'
);
)



//////////////// OSC settings

(

(
OSCdef.new(
	\toggle1,
	{
		arg msg, time, addr, port;

		if(msg[1] == 1,

			{~routine.value.play},

			{~routine.value.stop;
				~play1.set(\gate, 0);
				~lpf.release(5);
				~lpfFreqShift.release(5);
				~reverb.release(5);
				~rlpf.release(5);
		});

	},
	'/1/toggle1'
);
);

(
OSCdef.new(
	\toggle2,
	{
		arg msg, time, addr, port;

		if(msg[1] == 1,

			{~set2.value},

			{
				Tdef(\td).clear;
				Tdef(\tplayback).clear;
				~playback.release;
				~recordBuf.release;
				~bpf.release;
				~play2.set(\gate, 0);

		});

	},
	'/1/toggle2'
);
);

(
OSCdef.new(
	\toggle3,
	{
		arg msg, time, addr, port;

			(
		if(msg[1] == 1,
			{~play3 = Synth(\play3)},
			{~play3.set(\gate,0)});
	);

		(
		if(msg[1] == 1,
				{Tdef(\3).play},
				{Tdef(\3).stop}
			)
		);

	},
	'/1/toggle3'
);
);


(
OSCdef.new(
	\toggle4,
	{
		arg msg, time, addr, port;

		if(msg[1] == 1, {

			~play4 = Synth(\play4);
			~rlpf2 = Synth(\rlpf2);
			~rlpf2.moveAfter(~play4);

		},

			{

			~play4.release;
			~rlpf2.release;

		}

	)},
	'/1/toggle4'
);
);


(
OSCdef.new(
	\slider,
	{
		arg msg, time, addr, port;

		var mul = msg[1].range(0,1.4);

		~play1.set(\amp, mul);
		~play2.set(\amp, mul);
		~play3.set(\amp, mul);
		~play4.set(\amp, mul);
		~playRaw.set(\amp, mul);
		~playback.set(\amp, mul);
	},

	'/1/fader1'
);
);


(
OSCdef.new(
	\toggle5,
	{
		arg msg, time, addr, port;

		if(msg[1] == 1,
			{~playRaw = Synth(\playRaw)},
			{~playRaw.set(\gate,0)}
		)

	},

	'/1/toggle5'
);
);


(
OSCdef.new(
	\toggle6,
	{
		arg msg, time, addr, port;

		if(msg[1] == 1,
			{s.record}.postln,
			{s.stopRecording.postln}
		)

	},

	'/1/toggle6'
);
)



)




