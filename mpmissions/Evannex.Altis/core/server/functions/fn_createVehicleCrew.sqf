private _vehicle = _this select 0;
private _group = _this select 1;

// Create its crew
createVehicleCrew _vehicle;
private _temp = group ((crew _vehicle) select 0);
// If vehicle is another faction it can spawn people on the wrong side, we need them to be on our side.
(units _temp) joinSilent _group;
{ _x setBehaviour "AWARE"; _x setSkill br_ai_skill; } forEach (units _group);
// Apply the zone AI to the vehicle
//br_friendly_ai_groups pushBack _attackVehicleGroup;
_group;