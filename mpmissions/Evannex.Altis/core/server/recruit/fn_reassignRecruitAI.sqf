While {TRUE} do {
	{ 
		private _group = group _x;
		if ((leader _group) == _x) then { // Check no-under player control, if not then add to AI control
			br_recruits deleteAt (br_recruits find _x);
			_x groupChat "This group is now under AI control.";
			br_friendly_ground_groups pushBack _group; // This will either delete if they're too far from the zone or add them as another group unit within the zone
			br_friendly_ai_groups pushBack _group;
		};
	} forEach br_recruits;
	sleep 45;
};