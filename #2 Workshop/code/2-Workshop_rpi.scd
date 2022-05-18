


(
s.waitForBoot{

	x = TAPGui();
	s.sync;
	2.wait;

	//start
	~start = {
		x.run;
		1.wait;
		s.sync;
		~source = TAP();
		///~source.path_("D:/gulesz/ZVUK/20200502_Take away/_listening/_exports with gps/200623-2054_52.079579, 4.327901.wav");
		~source.dur = 8;
		~source.source;


		//effects
		~out = TAP(\out);
		~delay = TAP(\delay);
		~reverb = TAP(\reverb);
		~pitch = TAP(\pitch);
		~lfno = TAP(\lfno);
		~warp = TAP(\warp);
		~grain = TAP(\grain);
		~samp = TAP(\samp);
		~writer = TAP(\writer);
		~eq = TAP(\eq);
		s.sync;


		//effects

		(
			~samp.effectB(
				{|bufL, posL|
					var rateL = Lag3.kr(Control.names([\rateL]).kr(1), 0.01);
					var endL = Lag3.kr(Control.names([\endL]).kr(1), 0.01);
					var sigL = BufRd.ar(1, bufL, Phasor.ar(0, BufRateScale.kr(bufL) * rateL, 0, BufFrames.kr(bufL) * endL));
					sigL;
				},

				{|bufR, posL|
					var rateR = Lag3.kr(Control.names([\rateR]).kr(1), 0.01);
					var endR = Lag3.kr(Control.names([\endR]).kr(1), 0.01);
					var sigR = BufRd.ar(1, bufR, Phasor.ar(0, BufRateScale.kr(bufR) * rateR, 0, BufFrames.kr(bufR) * endR));
					sigR;
				}
			);


			~grain.effectB(
				{ |bufL, posL|
					var posRateL = Lag3.kr(Control.names([\posRateL]).kr(1), 1);
					var freqL = Lag3.kr(Control.names([\freqL]).kr(25), 1);
					var durL = Lag3.kr(Control.names([\durL]).kr(1), 0.2);
					var overlapL = Lag3.kr(Control.names([\overlapL]).kr(2), 0.2);
					var rateL = Lag3.kr(Control.names([\rateL]).kr(1), 0.2);
					var positionL = Phasor.ar(0, posRateL * BufRateScale.kr(bufL), 0, BufFrames.kr(bufL));

					var sigL = GrainBuf.ar(1, Impulse.ar(freqL), (freqL.reciprocal * overlapL), bufL, rateL, positionL / BufFrames.kr(bufL)) * overlapL.linexp(0.0,1.0,5,1);
					sigL
				},

				{ |bufR, posR|
					var posRateR = Lag3.kr(Control.names([\posRateR]).kr(1), 1);
					var freqR = Lag3.kr(Control.names([\freqR]).kr(25), 1);
					var durR = Lag3.kr(Control.names([\durR]).kr(0.01), 0.2);
					var overlapR = Lag3.kr(Control.names([\overlapR]).kr(2), 0.2);
					var rateR = Lag3.kr(Control.names([\rateR]).kr(1), 0.2);
					var positionR = Phasor.ar(0, posRateR * BufRateScale.kr(bufR), 0, BufFrames.kr(bufR));

					var sigR = GrainBuf.ar(1, Impulse.ar(freqR), freqR.reciprocal * overlapR, bufR, rateR, positionR / BufFrames.kr(bufR)) * overlapR.linexp(0.0,1.0,5,1);
					sigR
				}

			);


			~warp.effectB(
				{ |bufL, posL|
					var durL = Lag3.kr(Control.names([\durL]).kr(1), 1);
					var pointerL = EnvGen.ar(Env([0.0, 1.0], (~warp.dur)*durL).circle);
					var freqL = Lag3.kr(Control.names([\freqL]).kr(1), 1);
					var sigL = Warp1.ar(1, bufL, pointerL, freqL, windowSize:0.1, overlaps: 8) * 0.5;
					sigL = BPF.ar(sigL, freqL*1000);
				},

				{ |bufR, posR|
					var durR = Lag3.kr(Control.names([\durR]).kr(1), 1);
					var pointerR = EnvGen.ar(Env([0.0, 1.0], (~warp.dur)*durR).circle);
					var freqR = Lag3.kr(Control.names([\freqR]).kr(1), 1);
					var sigR = Warp1.ar(1, bufR, pointerR, freqR, windowSize:0.1, overlaps: 8) * 0.5;
					sigR = BPF.ar(sigR, freqR*1000);
				}
			);


			~lfno.effectA(
				{ |inL|
					var freqL = Lag3.kr(Control.names([\freqL]).kr(0.2), 1);
					var sigL = inL + DelayL.ar(inL, 0.5, Lag.ar(LFNoise0.ar(SinOsc.ar(freqL).range(0.01,5)).range(0.1,1))) * 0.9;
					sigL = DualBandComp.ar(sigL, LFNoise1.ar(0.5).range(30,100), LFNoise2.ar(1).range(0.1,0.5), 0.5, 1.1, 1.5);
					sigL*0.9
				},

				{ |inR|
					var freqR = Lag3.kr(Control.names([\freqR]).kr(0.18), 1);
					var sigR = inR + DelayL.ar(inR, 0.5, Lag.ar(LFNoise0.ar(SinOsc.ar(freqR).range(0.01,5)).range(0.1,1))) * 0.9;
					sigR = DualBandComp.ar(sigR, LFNoise1.ar(0.5).range(30,100), LFNoise2.ar(1).range(0.1,0.5), 0.4, 1.1, 1.5);
					sigR*0.9
				}
			);


			~pitch.effectA(
				{ |inL|
					var freqL = Lag3.kr(Control.names([\freqL]).kr(100), 0.1);
					var delayL = Lag3.kr(Control.names([\delayL]).kr(0.01), 0.01);
					var ffreqL = Tartini.kr(inL)[0];
					var sigL = Decimator.ar(FreqShift.ar(inL, freqL),ffreqL.linlin(0,20000,5000,15000),ffreqL.linlin(20,20000, 16, 2));
					sigL;
				},

				{ |inR|
					var freqR = Lag3.kr(Control.names([\freqR]).kr(100), 0.1);
					var delayR = Lag3.kr(Control.names([\delayR]).kr(0.01), 0.01);
					var ffreqR = Tartini.kr(inR)[0];
					var sigR = Decimator.ar(FreqShift.ar(inR, freqR),ffreqR.linlin(0,20000,5000,15000),ffreqR.linlin(20,20000, 16, 2));
					sigR;
				}
			);


			~reverb.effectA(
				{ |inL|
					var reverbL = Lag3.kr(Control.names([\reverbL]).kr(0.01), 0.1);
					var sizeL = Lag3.kr(Control.names([\sizeL]).kr(0.01), 0.1);
					var sigL = JPverb.ar(inL, t60: reverbL, damp: 0.0, size: sizeL, earlyDiff: 0.707, modDepth: 0.1, modFreq: 2.0, low: 1.0, mid: 1.0, high: 1.0, lowcut: 50.0, highcut: 10000.0);
					sigL * 0.9;
				},

				{ |inR|
					var reverbR = Lag3.kr(Control.names([\reverbR]).kr(0.01), 0.1);
					var sizeR = Lag3.kr(Control.names([\sizeR]).kr(0.01), 0.1);
					var sigR = JPverb.ar(inR, t60: reverbR, damp: 0.0, size: sizeR, earlyDiff: 0.707, modDepth: 0.1, modFreq: 2.0, low: 1.0, mid: 1.0, high: 1.0, lowcut: 50.0, highcut: 10000.0);
					sigR * 0.9;
				},
			);


			~delay.effectA(
				{|inL|
					var delayL = Lag3.kr(Control.names([\delayL]).kr(0.1), 0.1);
					var freqL = Lag3.kr(Control.names([\freqL]).kr(20), 0.01);
					var modL = LFNoise2.ar(0.01);
					var effectL = inL + LocalIn.ar(1);
					effectL = DelayC.ar(effectL, 0.5, delayL);
					LocalOut.ar(effectL * 0.5);
					LPF.ar(LeastChange.ar(GravityGrid.ar(0, 0.5), effectL), freqL, 0.4);
				},

				{|inR|
					var delayR = Lag3.kr(Control.names([\delayR]).kr(0.1), 0.1);
					var freqR = Lag3.kr(Control.names([\freqR]).kr(20), 0.01);
					var modR = LFNoise2.ar(0.01);
					var effectR = inR + LocalIn.ar(1);
					effectR = DelayC.ar(effectR, 0.5, delayR);
					LocalOut.ar(effectR * 0.5);
					LPF.ar(LeastChange.ar(GravityGrid.ar(0, 0.5), effectR), freqR, 0.4);

				};
			);
		);




		//play
		s.sync;
		1.wait;



		(
			~out.play;
			~delay.play;
			~reverb.play;
			~pitch.play;
			~lfno.play;
			~warp.play;
			~grain.play;
			~samp.play;
			~writer.play;
			~eq.play;

			~out.cue(1);
			~delay.cue(0);
			~reverb.cue(0);
			~pitch.cue(0);
			~lfno.cue(0);
			~warp.cue(0);
			~grain.cue(0);
			~samp.cue(0);
			~writer.cue(1);
			~eq.cue(1);

			~delay.set(\wet, 1, \fade, 0.5);
			~reverb.set(\wet, 1, \fade, 0.5);
			~pitch.set(\wet, 1, \fade, 0.1);
			~lfno.set(\wet, 1, \fade, 0.01);
			~warp.set(\wet, 1, \fade, 2);
			~grain.set(\wet, 1, \fade, 2);
			~samp.set(\wet, 1, \fade, 0.5);
			~writer.set(\wet, 1);
			~eq.set(\wet, 1, \fade, 0.5);

			//~playback = Synth.head(s, \playback);
			~mics = Synth.head(s, \mics);

		);


		//gui
		s.sync;

		2.wait;



		(
			//cues
			x.button(0, "EQ",
				{~eq.cue(0); x.slidersVolume},
				{~eq.cue(1); x.slidersVolume}
			);
			~button0.value = 1;

			x.button(9, "Samp", {~samp.cue(0)}, {~samp.cue(1)});
			x.button(18, "Grain", {~grain.cue(0)}, {~grain.cue(1)});
			x.button(27, "Warp", {~warp.cue(0)}, {~warp.cue(1)});
			x.button(36, "Lfno", {~lfno.cue(0)}, {~lfno.cue(1)});
			x.button(45, "Pitch", {~pitch.cue(0)}, {~pitch.cue(1)});
			x.button(54, "Reverb", {~reverb.cue(0)}, {~reverb.cue(1)});
			x.button(63, "Delay", {~delay.cue(0)}, {~delay.cue(1)});

			x.rowButtons(0, \eq, \amp, 1, 0);
			x.rowButtons(1, \samp, \wet, 1, 0);
			x.rowButtons(2, \grain, \wet, 1, 0);
			x.rowButtons(3, \warp, \wet, 1, 0);
			x.rowButtons(4, \lfno, \wet, 1, 0);
			x.rowButtons(5, \pitch, \wet, 1, 0);
			x.rowButtons(6, \reverb, \wet, 1, 0);
			x.rowButtons(7, \delay, \wet, 1, 0);

			//recording button
			~checkRecording = Routine{
				inf.do{
					if(s.isRecording == false,{~button72.value = 0; ~button72.background_(Color.new255(249,221,22));~button72.stringColor_(Color.red)}
					);
					1.wait;
				}
			};

			~checkRecording.play;

			x.button(72, "REC",
				{s.stopRecording; "stop".postln; ~button72.background_(Color.new255(249,221,22)); ~button72.stringColor_(Color.red)},
				{
					s.record(duration: 1200);
					"rec".postln;
					~button72.background_(Color.red);
					~button72.stringColor_(Color.black);
				}
			);


			//effects
			x.button(73, "EQ", {x.slidersVolume; x.slidersAux},
				{
					var amp = [0.0, 1.0, \lin, 0.001];
					var rq = [0.001, 0.5, \exp, 0.001];
					x.slidersAux(\eqGroup, [[\rq, rq]], 1);
					x.slidersProcesses(\eq, [[\amp,amp]]);
				}
			);


			x.button(74, "Samp", {x.slidersVolume; x.slidersAux},
				{
					var end = [0.01,1,\lin,0.01];
					var rate = [0.05,1,\lin, 0.01];
					var wet = [0,1,\lin,0.01];
					x.slidersAux(\sampGroup, [[\wet, wet]], 1);
					x.slidersProcesses(\samp,	[[\endL,end],[\endR,end]]);
				}
			);

			x.button(75, "Grain", {x.slidersVolume; x.slidersAux},
				{
					var freq = [0.1,15000,\exp, 0.1];
					var dur = [0.05, 1.0, \exp, 0.005];
					var overlap = [0.001,1,\exp,0.001];
					var rate = [-1.0,1.0,\lin,0.01];
					var wet = [0.0,1.0,\lin,0.01];
					x.slidersProcesses(\grain,[
						[\freqL,freq],[\freqR,freq],
						[\durL, dur], [\durR, dur],
						[\overlapL, overlap], [\overlapR, overlap],
						[\rateL, rate], [\rateR, rate],
					] );
					x.slidersAux(\grainGroup, [[\wet, wet]], 1);
				}
			);


			x.button(76, "Warp", {x.slidersVolume; x.slidersAux},
				{
					var dur = [1.0,20.0,\exp, 0.1];
					var freq = [1,6,\exp, 0.1];
					var wet = [0,1,\lin,0.01];
					x.slidersProcesses(\warp, [
						[\freqL,freq],[\freqR,freq],
						[\durL,dur],[\durR,dur],
					] );
					x.slidersAux(\warpGroup, [[\wet, wet]], 1);
				}
			);


			x.button(77, "Lfno", {x.slidersVolume; x.slidersAux},
				{
					var wet = [0.0,1.0,\lin,0.01];
					var freq = [0.01, 1, \exp, 0.001];
					x.slidersProcesses(\lfno,	[
						[\freqL,freq],[\freqR,freq],
					] );
					x.slidersAux(\convGroup, [[\wet, wet]], 1);
				}
			);



			x.button(78, "Pitch", {x.slidersVolume; x.slidersAux},
				{
					var wet = [0.0,1.0,\lin,0.01];
					var freq = [20, 1000, \exp, 1];
					x.slidersProcesses(\pitch,	[
						[\freqL,freq],[\freqR,freq],
					], 1);
					x.slidersAux(\pitchGroup, [[\wet, wet]], 1);
				}
			);



			x.button(79, "Reverb", {x.slidersVolume; x.slidersAux},
				{
					var reverb = [0.01, 1, \exp, 0.001];
					var size = [0.01, 1.0, \exp, 0.001];
					var wet = [0.0,1.0,\lin,0.01];
					x.slidersAux(\reverbGroup, [[\wet,wet]], 1);
					x.slidersProcesses(\reverb,[
						[\reverbL,reverb],[\reverbR,reverb],
						[\sizeL, size], [\sizeR, size]
					]);
				}
			);


			x.button(80, "Delay", {x.slidersVolume; x.slidersAux},
				{
					var freq = [200,4000,\exp,0.1];
					var delay = [0.1,1.0,\exp,0.01];
					var wet = [0.0,1.0,\lin,0.01];
					x.slidersAux(\delayGroup, [[\wet, wet]], 1);
					x.slidersProcesses(\delay,[ [\delayL,delay],[\delayR,delay],
						[\freqL, freq], [\freqR, freq]
					]);
			});

		);






	};

	~start.fork
}
)
