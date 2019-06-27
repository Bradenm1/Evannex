private _aim = 0.3;

br_fnc_Fatigue = {
	if ("Fatigue" call BIS_fnc_getParamValue == 1) then { TRUE } else { FALSE };
};

br_fnc_Stamina = {
	if ("Stamina" call BIS_fnc_getParamValue == 1) then { TRUE } else { FALSE };
};

br_fnc_CustomAim = {
	if ("CustomAim" call BIS_fnc_getParamValue == 1) then { TRUE } else { FALSE };
};

// Disable annoying crap
player enableFatigue ([] call br_fnc_Fatigue);
player enableStamina ([] call br_fnc_Stamina);
if ([] call br_fnc_CustomAim) then {player setCustomAimCoef _aim};