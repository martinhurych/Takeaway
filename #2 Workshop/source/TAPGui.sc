
TAPGui {

	var w;
	classvar num = 9;
	classvar <>widthButton = 0.105;
	var <>heightButton = 0.055;
	var <>widthSlider = 0.105;
	var <>heightSlider = 0.20;
	var <>nameHz;

	run{
		var button = [];
		var slider = [];
		var row =[];
		var column = [];
		var resetButton;
		var array = [];

		Routine{
			w.free;
			Server.default.sync;
			0.5.wait;
			w = WsWindow.new("takeaway", 8000, true);
			w.background_(Color.black);
			Server.default.sync;

			//////////////////////   text   //////////////////////////
			(num-1).do{|i|
				var wsText = WsStaticText(w, Rect(0.153+(i*widthButton), 0.02, 0.04, 0.001));
				nameHz = ["1/8","1/4","1/2","1","2","4","8","16"];
				array = array ++ wsText;
				array[i].string_(nameHz[i]).stringColor_(Color.white).font_(Font.new(\Arial).size_(13)).align_(\center);

				~textHz = WsStaticText(w, Rect(0.05, 0.02, 0.04, 0.001));
				~textHz.string_("kHz").stringColor_(Color.white).font_(Font.new(\Arial).size_(13)).align_(\center);

				~textWet = WsStaticText(w, Rect(0.05, 0.60, 0.04, 0.001));
				~textWet.string_("˙\˛").stringColor_(Color.white).font_(Font.new(\Arial).size_(13)).align_(\center);
			};

			~textVol = WsStaticText(w, Rect(0.04, 0.89, 0.04, 0.001));
			~textVol.string_("^Vol").stringColor_(Color.white).font_(Font.new(\Arial).size_(13)).align_(\center);

			~textMic = WsStaticText(w, Rect(0.5, 0.93, 0.04, 0.001));
			~textMic.string_("~Mic").stringColor_(Color.white).font_(Font.new(\Arial).size_(13)).align_(\center);

			//////////////////////   buttons   ////////////////////////
			//create_~button0..~button80
			num.do{|vert|
				num.do{|horiz|
					button = button ++ WsButton.new(w, Rect(0.02+(horiz*widthButton), 0.06+(vert*heightButton), widthButton, heightButton));
				};
			};

			//create_~button0..~button80, [row, column]
			(num*num).do{|i|
				var globalButton = (\button ++ (i)).asSymbol;
				currentEnvironment[globalButton] = button[i];

				row = row ++ currentEnvironment[globalButton];
				column = column ++ currentEnvironment[globalButton];
			};

			//create_~row1..~column8
			num.do{|i|
				var whichButtonsForRow = ( Array.fill(num, {|i| i}) + (i*num) );
				var whichButtonsForColumn = ( Array.fill(num, {|i| i*(num)}) + i );

				currentEnvironment[(\row++(i)).asSymbol] = row[whichButtonsForRow];
				currentEnvironment[(\column++(i)).asSymbol] = column[whichButtonsForColumn];
			};

			//~resetButton = WsSimpleButton.new(w, Rect(0.035, 0.0125, 0.08, 0.04));

			/////////////////////   sliders   /////////////////////////
			//create_~slider0..~slider8
			num.do{|i|
				var globalSlider = (\slider ++ (i)).asSymbol;
				slider = slider ++ WsEZSlider.new(w, Rect(0.02+(i*widthSlider), 0.65, (widthSlider-0.01), heightSlider));
				currentEnvironment[globalSlider] = slider[i];
				currentEnvironment[globalSlider].valueAction_(1.0)
			};

			~slider10 = WsEZSlider.new(w, Rect(0.12, 0.57, 0.72, 0.05) );
			~slider11 = WsEZSlider.new(w, Rect(0.12, 0.9, 0.36, 0.05) );


			////////////// SETTINGS
			/*~resetButton.font_(Font.new(\Arial).size_(12)).align_(\center);
			~resetButton.background_(Color.red);
			~resetButton.stringColor(Color.black);
			~resetButton.action_({~start.value});*/

			~slider10.background_(Color.new255(58,117,196));
			~slider10.controlSpec_([0.0,1.0,\lin,0.001].asSpec);
			~slider10.valueAction_(1.0);

			~slider11.background_(Color.new255(249,221,22));
			~slider11.controlSpec_([0.0,2.0,\lin,0.001].asSpec);
			~slider11.action_({|i| ~mics.set(\amp, i.value)});
			~slider11.value = 0.6;


			~slider0.background_(Color.new255(249,221,22));
			~slider0.controlSpec_([0.0,2.0,\lin,0.01].asSpec);
			~slider0.action_({|i| ~outGroup.set(\amp, i.value)});
			~slider0.value = 0.6;


			(num).do{|i| ~column0[i].background = Color.new255(249,221,22)};
			(num).do{|i| ~row8[i].background = Color.new255(58,117,196)};

		}.play
	}


	//FUNCTIONS
	button {|whichButton, title, func1, func2|
		var color, chosenButton, effectButtons, restButtons;
		color = if(whichButton <= 72,
			{[title.asString, Color.black, Color.new255(249,221,22)]},
			{[title.asString, Color.black, Color.new255(58,117,196)]}
			//Color.new255(255,100+((whichButton%8)*15), 235)
			//Color.new255(180-((whichButton%8)*15), 215, 230)
		);

		chosenButton = currentEnvironment[(\button++(whichButton)).asSymbol];

		if ( whichButton <= 72,

			{chosenButton.action_({|i| if ( i.value == 0, func1, func2)})},

			{chosenButton.action_({|i|
				if ( i.value == 0, func1,
					{
						{ effectButtons = Array.fill(8, {|i| (73+i)});
							effectButtons.remove(whichButton);
							effectButtons.do{|number| currentEnvironment[(\button++number).asSymbol].value=0};
						}.value;
						//{"yes".postln}.value;
						func2.value;

					}
				);
			});

			}
		);

		chosenButton.states_([color, [title.asString, Color.red, Color.white] ]);
		chosenButton.font_(Font.new(\Arial).size_(10)).align_(\center);
	}


	rowButtons {|whichRow, name, argument, valueOn, valueOff|
		var chosenRow = currentEnvironment[(\row++(whichRow)).asSymbol];
		var chosenButton = Array.fill((num-1), {|i| 1+i}) + (whichRow+(whichRow*(num-1)));
		chosenButton.do{|number, i|
			var synthEq = (\eq++(i+1)).asSymbol;
			var synthName = (name++(i+1)).asSymbol;
			var chosenArgument = (argument++(i+1)).asSymbol;
			chosenRow[(i+1)].states_([  //button state/action
				["O",Color.black,Color.new255(240,240,240)],
				["", Color.black,Color.new255(240,240,240)] ]);
			chosenRow[(i+1)].action_({|i|
				if (i.value == 0,
					{currentEnvironment[synthEq].set(chosenArgument, valueOn); currentEnvironment[synthName].set(argument, valueOn)},
					{currentEnvironment[synthName].set(chosenArgument, valueOff); currentEnvironment[synthName].set(argument, valueOff)}
				);
			});
		};
	}

	slidersVolume {
		(num-1).do{|number|
			var synthName = currentEnvironment[(\out++(number+1)).asSymbol];
			var chosenSlider = currentEnvironment[(\slider++(number+1)).asSymbol];
			var volume = [0.0, 1.0, \lin];
			chosenSlider.action_({|i|
				chosenSlider.controlSpec_(volume.asSpec);
				synthName.set(\amp, i.value);
			});
		};
	}

	slidersProcesses {|name, array, multi=0|
		var arraySliders = [];

		(num-1).do{|number|
			var synthName = currentEnvironment[(name++(number+1)).asSymbol];
			var chosenSlider = currentEnvironment[(\slider++(number+1)).asSymbol];
			chosenSlider.action_({|i|
				array.do{|val|
					chosenSlider.controlSpec_(val[1].asSpec);
					synthName.set(val[0], i.value);
				}
			});

		}
	}


	slidersAux {|name, array, whichSlider=1|
		var synthName = currentEnvironment[name.asSymbol];
		var chosenSlider = currentEnvironment[(\slider++(whichSlider+9)).asSymbol];
		chosenSlider.action_({|i|
			array.do{|val|
				chosenSlider.controlSpec_(val[1].asSpec);
				synthName.set(val[0], i.value);
			};
		})
	}

}




