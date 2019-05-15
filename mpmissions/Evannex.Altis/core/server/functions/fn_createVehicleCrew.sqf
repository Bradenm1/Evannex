private _vehicle = _this select 0;

// Create its crew
createVehicleCrew _vehicle;
// Get the vehicle commander
private _commander = driver _vehicle;
// Get the group from the commander
private _temp = group _commander;
// If vehicle is another faction it can spawn people on the wrong side, we need them to be on our side.
_newVehicleGroup = createGroup WEST;
(units _temp) joinSilent _newVehicleGroup;
{ _x setBehaviour "AWARE"; _x setSkill br_ai_skill; } forEach (units _newVehicleGroup);
// Apply the zone AI to the vehicle
//br_friendly_ai_groups pushBack _attackVehicleGroup;
_newVehicleGroup;
