

TAP {

	var <>in, <>path, <>dur = 8;
	classvar <>num = 8;

	*new { arg name;
		^super.new.init(name);
	}

	init {arg name;
		this.in = name.asSymbol;
	}

	source{
		~srcL = Bus.audio(Server.default);
		~srcR = Bus.audio(Server.default);
		~eqL = ();
		~eqR = ();
		num.do{|i| ~eqL[i+1] = Bus.audio(Server.default)};
		num.do{|i| ~eqR[i+1] = Bus.audio(Server.default)};
		~bufL = ();
		~bufR = ();
		~writerBusL = ();
		~writerBusR = ();

		num.do{|i| ~bufL[i+1] = Buffer.alloc(Server.default, Server.default.sampleRate * dur)};
		num.do{|i| ~bufR[i+1] = Buffer.alloc(Server.default, Server.default.sampleRate * dur)};
		num.do{|i| ~writerBusL[i+1] = Bus.audio(Server.default)};
		num.do{|i| ~writerBusR[i+1] = Bus.audio(Server.default)};

		~bufferL = Buffer.readChannel(Server.default, path, -0.9, -0.89, channels: 0);
		~bufferR = Buffer.readChannel(Server.default, path, -0.9, -0.89, channels: 1);

		SynthDef(\mics, {|amp=0.6|
			var sigL = SoundIn.ar(0);
			var sigR = SoundIn.ar(1);
			Out.ar(~srcL, Limiter.ar(sigL * amp));
			Out.ar(~srcR, Limiter.ar(sigR * amp));
		}).add;

		SynthDef(\playback, {|amp=0.5|
			var start = BufSampleRate.kr(~bufferL);
			var end = BufSampleRate.kr(~bufferL);
			var sigL = BufRd.ar(1, ~bufferL, Phasor.ar(0, BufRateScale.kr(~bufferL), start * 55, end * 180), 1);
			var sigR = BufRd.ar(1, ~bufferR, Phasor.ar(0, BufRateScale.kr(~bufferR), start * 55, end * 180), 1);
			Out.ar(~srcL, sigL * amp);
			Out.ar(~srcR, sigR * amp);
		}).add;

		num.do{|i|
			SynthDef(\writer++(i+1).asSymbol, {
				var posL, posR, writerL, writerR, outL, outR;
				posL = Phasor.ar(0, 1, 0, BufFrames.kr(~bufL[i+1]));
				posR = Phasor.ar(0, 1, 0, BufFrames.kr(~bufR[i+1]));
				writerL = In.ar(~eqL[i+1], 1);
				writerR = In.ar(~eqR[i+1], 1);
				outL = ~writerBusL[i+1];
				outR = ~writerBusR[i+1];
				BufWr.ar(writerL, ~bufL[i+1], posL);
				BufWr.ar(writerR, ~bufR[i+1], posR);
				Out.ar(outL, posL);
				Out.ar(outR, posR)
			}).add;

			SynthDef(\out++(i+1).asSymbol, {|amp=0.6|
				var panL = Lag3.kr(Control.names([\panL]).kr(-1), 10);
				var panR = Lag3.kr(Control.names([\panR]).kr(1), 10);
				var inL = In.ar(~eqL[i+1]);
				var inR = In.ar(~eqR[i+1]);
				Out.ar(0, Limiter.ar(inL * amp));
				Out.ar(1, Limiter.ar(inR * amp));
			}).add;

			SynthDef(\eq++(i+1).asSymbol, {|fade=0.5|
				var inL, inR, outL, outR, sigL, sigR;  // sends
				var amp, freq, rq;                     // filter controls
				var thresh=0.5, clamp=0.1, relax=0.1;  //compressor controls

				inL = In.ar(~srcL);
				inR = In.ar(~srcR);
				outL = ~eqL[i+1];
				outR = ~eqR[i+1];

				amp = Control.names([\amp]).kr(1);
				rq = Control.names([\rq]).kr(0.5);
				clamp = Control.names([\clamp]).kr(0.01);
				relax = Control.names([\relax]).kr(0.01);

				freq = 125 * (2.pow(i));
				sigL = BPF.ar(inL, freq.postln, rq, (rq.value).linexp(0.0,0.5,5,1));
				sigR = BPF.ar(inR, freq, rq, (rq.value).linexp(0.0,0.5,5,1));

				sigL = Compander.ar(sigL, sigL, thresh, 1, 1, clamp, relax);
				sigR = Compander.ar(sigR, sigR, thresh, 1, 1, clamp, relax);

				//sig = SynthDef.wrap(func, prependArgs: [in, fade]);
				Out.ar(outL, sigL * Lag3.kr(amp,fade));
				Out.ar(outR, sigR * Lag3.kr(amp,fade));

			}).add;
		}
	}

	//print { in.postln }

	play {
		var groupName = (in++"Group").asSymbol;
		currentEnvironment[groupName] = Group.new;
		^(num.do{|i|
			var name = (in++(i+1)).asSymbol;
			currentEnvironment[name] = Synth.tail(currentEnvironment[groupName], name);
		})

	}

	cue { |cue|
		^(num.do{|i|
			var name = (in++(i+1)).asSymbol;
			if (cue == 0,
				{currentEnvironment[name].run(false); "stop"},
				{currentEnvironment[name].run(true); "play"}
			)
		})
	}

	set {|argument, value|
		^(num.do{|i|
			var name = (in++(i+1)).asSymbol;
			currentEnvironment[name].set(argument.asSymbol, value);
		})
	}



	effectA {
		arg func1, func2;

		^(num.do{|i|
			SynthDef((in++(i+1)).asSymbol, { |fade=0.01, wet=1|
				var inL, inR, env, sigL, sigR, outL, outR;
				env = Linen.kr(1, 2, 1, 2, 2);
				inL = In.ar(~eqL[i+1]);
				inR = In.ar(~eqR[i+1]);
				outL = ~eqL[i+1];
				outR = ~eqR[i+1];
				sigL = SynthDef.wrap(func1, prependArgs: inL);
				sigR = SynthDef.wrap(func2, prependArgs: inR);
				XOut.ar(outL, Lag3.kr(wet,fade) * env, sigL);
				XOut.ar(outR, Lag3.kr(wet,fade) * env, sigR);

			}).add;
		})
	}


	effectB {
		arg func1, func2;

		^(num.do{|i|
			SynthDef((in++(i+1)).asSymbol, { |fade=0.01, wet=1|
				var env, bufL, bufR, posL, posR, sigL, sigR, outL, outR;
				env = Linen.kr(1, 2, 1, 2, 2);
				bufL = ~bufL[i+1];
				bufR = ~bufR[i+1];
				outL = ~eqL[i+1];
				outR = ~eqR[i+1];
				posL = In.ar(~writerBusL[i+1]);
				posL = posL / BufFrames.kr(bufL);
				posL = posL - 0.02;
				posL = posL.wrap(0,1);
				posR = In.ar(~writerBusR[i+1]);
				posR = posR / BufFrames.kr(bufR);
				posR = posR - 0.02;
				posR = posR.wrap(0,1);
				sigL = SynthDef.wrap(func1, prependArgs: [bufL, posL]);
				sigR = SynthDef.wrap(func2, prependArgs: [bufR, posR]);
				XOut.ar(outL, Lag3.kr(wet,fade) * env, sigL);
				XOut.ar(outR, Lag3.kr(wet,fade) * env, sigR);
				//Out.ar(outL, sigL * (Lag3.kr(wet,fade) * env));
				//Out.ar(outR, sigR * (Lag3.kr(wet,fade) * env));
			}).add;
		})
	}

}


