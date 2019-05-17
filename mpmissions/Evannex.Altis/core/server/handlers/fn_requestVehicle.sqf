MP_request_vehicle = {
	params ["_vehType", "_marker", "_textures", "_aiControlled"];

	private _new_veh = createVehicle [ _vehType, getMarkerPos _marker, [], 0, "CAN_COLLIDE" ];
	private _vehDir = markerDir _marker;
	_new_veh setPosATL [ ( position _new_veh select 0 ), ( position _new_veh select 1 ), 0.25 ];
	_new_veh setDir _vehDir;
	
	private _count = 0;
	{
		_new_veh setObjectTextureGlobal [ _count, _x ];
		_count = _count + 1;
	} forEach _textures;

	br_spawned_vehicles pushBack _new_veh;

	// If crew has AI
	if (_aiControlled) then {
		// Create its crew
		createVehicleCrew _new_veh;
		// Get the vehicle commander
		private _commander = driver _new_veh;
		// Get the group from the commander
		private _temp = group _commander;
		// If vehicle is another faction it can spawn people on the wrong side, we need them to be on our side.
		_attackVehicleGroup = createGroup WEST;
		(units _temp) joinSilent _attackVehicleGroup;
		{ _x setBehaviour "AWARE"; _x setSkill br_ai_skill; } forEach (units _attackVehicleGroup);
		// Apply the zone AI to the vehicle
		br_friendly_ai_groups pushBack _attackVehicleGroup;
		br_friendly_vehicles pushBack _attackVehicleGroup;
		// Removes the AI from the above groups when vehicle is not alive anymore
		[_new_veh, _attackVehicleGroup] execVM "core\server\functions\fn_removeDeadAIRequestedVehicle.sqf";
	};

	// Deletes vehicles if there's too much spawned given the param
	{ if (!alive _x) then { br_spawned_vehicles deleteAt (br_spawned_vehicles find _x); deleteVehicle _x; }; } forEach br_spawned_vehicles;
	while {count br_spawned_vehicles > br_max_user_vehicles} do {
		private _toDelete = br_spawned_vehicles select 0;
		format ["The server has hit the spawnable vehicles limit: %1. Deleting one.", count br_spawned_vehicles, getText (configFile >>  "CfgVehicles" >> (typeof _new_veh) >> "displayName")] remoteExec ["systemChat"]; 
		br_spawned_vehicles deleteAt (br_spawned_vehicles find _toDelete);
		deleteVehicle _toDelete;
	};
};