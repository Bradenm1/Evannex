/*
	Author: 		Sil Carmikas
	Script Title: 	setRandomWeather.sqf
	Version:		1.0 Final

	This is a bit of a mashup using manage_weather.sqf files from the original Liberation 0.924 mission from [GREUH]zBug and [GREUH]McKeewa. The below code will execute within the mission to add random weather pattern generation making use of the newer selectRandom command (Arma 3 Version:
	1.56) This does not offer parameter selection for servers, the only customization that can be done is within this SQF file. Script is originally intended for accelerated time missions, so if you want to update this run like an actual 24 hour day setup, then you will need to increase the sleep 300; command to an appropriate value. This is a very basic script I am working with to learn scripting for Arma 3. Anyone is welcome to use this as they see fit.

	Instructions:

	1)	Place both SQF files anywhere you see fit, preferrably in the root directory of your mission. Doesn't matter where as long as you path them 			correctly and init.sqf can find them.

	2)	In your init.sqf, make sure to type in the following making note of its order:

		 [] spawn compileFinal preprocessFileLineNumbers "setRandomWeather.sqf";

	3)	Save your init.sqf, load Arma 3, load the mission and test using setTimeMultiplier. You can decrease the "sleep 900;" command to observe the random 		changes more frequently for debugging and testing.

	4)  If you have no bother over FPS issues, continue using script as is. The only FPS controller I put in was the setFog function, which I have now taken out as well. Otherwise, to control rain amounts and such, copy and paste the following in Random Weather section below the setOvercast setting:

			        if ( overcast < 0.7 ) then { 2 setRain 0 };

        			if ( overcast >= 0.7 && overcast < 0.9 ) then { 2 setRain 0.2 };

        			if ( overcast >= 0.9 ) then { 2 setRain 0.4 }; // Prevents heavy rain to help with FPS!

    5)  To use setFog function to control fog, just put 0 setFog 0; in Random Weather section below setOverCast setting.
*/

if (!isServer) exitWith {};

_setRandom = [0,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1.0];

// Initial Weather
skipTime -24;

0 setOvercast selectRandom _setRandom; // Initial Weather Set  Values: 0 = Sunny, clear skies   1 = Stormy, complete overcast

skipTime 24;

sleep 0.1; // Keep this at or above 0.1, or else simulWeatherSync command will not work properly.

simulWeatherSync; // This command will sync the selected weather pattern to appear as it should right away instead of having to wait.


// Random Weather
while { true } do {

    300 setOvercast selectRandom _setRandom; // selectRandom is the new engine solution to BIS_fnc_selectRandom. This will select a random weather pattern from the array. Values: 0 = Sunny, clear skies   1 = Stormy, complete overcast.

	sleep 0.1;

};

sleep 900; // Rests for 10 minutes real-life time before selecting new weather pattern. For 24 hour day cycles (1 in-game second = 1 real life second) or 				  whichever you prefer, you will want to update this to make sure weather shifts as appropriate.