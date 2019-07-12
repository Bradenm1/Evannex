// Events
fn_objectInitEvents = compileFinal preprocessFileLineNumbers "core\server\handlers\fn_objectInitEvents.sqf";

// Map markers
fn_createTextMarker = compileFinal preprocessFileLineNumbers "core\server\markers\fn_createTextMarker.sqf";
fn_createRadiusMarker = compileFinal preprocessFileLineNumbers "core\server\markers\fn_createRadiusMarker.sqf";

// Assets
radio_towers = compileFinal preprocessFileLineNumbers "core\savedassets\radio_towers.sqf";
zone_objectives = compileFinal preprocessFileLineNumbers "core\savedassets\zone_objectives.sqf";

// Vehicles
fn_createVehicleCrew = compileFinal preprocessFileLineNumbers "core\server\functions\fn_createVehicleCrew.sqf";
fn_commandGroupIntoVehicle = compileFinal preprocessFileLineNumbers "core\server\functions\fn_commandGroupIntoVehicle.sqf";
fn_ejectUnits = compileFinal preprocessFileLineNumbers "core\server\functions\fn_ejectUnits.sqf";
fn_ejectGroup = compileFinal preprocessFileLineNumbers "core\server\functions\fn_ejectGroup.sqf";
fn_getUnitsInVehicle = compileFinal preprocessFileLineNumbers "core\server\functions\fn_getUnitsInVehicle.sqf";
fn_getPlayersInVehicle = compileFinal preprocessFileLineNumbers "core\server\functions\fn_getPlayersInVehicle.sqf";
fn_waitForGroupToEnterVehicle = compileFinal preprocessFileLineNumbers "core\server\functions\fn_waitForGroupToEnterVehicle.sqf";
fn_checkVehicleAndCrewAlive = compileFinal preprocessFileLineNumbers "core\server\functions\fn_checkVehicleAndCrewAlive.sqf";
fn_createLandingNearZoneOnRoad = compileFinal preprocessFileLineNumbers "core\server\functions\vehicles\fn_createLandingNearZoneOnRoad.sqf";
fn_waitUntillArrived = compileFinal preprocessFileLineNumbers "core\server\functions\vehicles\fn_waitUntillArrived.sqf";
fn_getWaitingGroups = compileFinal preprocessFileLineNumbers "core\server\functions\vehicles\fn_getWaitingGroups.sqf";
fn_getWatingEvacGroups = compileFinal preprocessFileLineNumbers "core\server\functions\vehicles\fn_getWatingEvacGroups.sqf";

// Helicopters
fn_createHelicopterCrew = compileFinal preprocessFileLineNumbers "core\server\functions\helicopters\fn_createHelicopterCrew.sqf";
fn_waitUntillLanded = compileFinal preprocessFileLineNumbers "core\server\functions\helicopters\fn_waitUntillLanded.sqf";
fn_landHelicopter = compileFinal preprocessFileLineNumbers "core\server\functions\helicopters\fn_landHelicopter.sqf";
fn_createLandingNearZone = compileFinal preprocessFileLineNumbers "core\server\functions\helicopters\fn_createLandingNearZone.sqf";
fn_dropEvacedUnitsAtBase = compileFinal preprocessFileLineNumbers "core\server\functions\helicopters\fn_dropEvacedUnitsAtBase.sqf";

// Groups 
fn_findGroupsInQueue = compileFinal preprocessFileLineNumbers "core\server\functions\fn_findGroupsInQueue.sqf";
fn_selectRandomGroupToSpawn = compileFinal preprocessFileLineNumbers "core\server\functions\fn_selectRandomGroupToSpawn.sqf";
fn_deleteGroup = compileFinal preprocessFileLineNumbers "core\server\functions\fn_deleteGroup.sqf";
fn_getUnitAliveCount = compile preprocessFileLineNumbers "core\server\functions\fn_getUnitAliveCount.sqf";
fn_spawnGroup = compileFinal preprocessFileLineNumbers "core\server\functions\fn_spawnGroup.sqf";

// Units 
fn_getGroundUnitsLocation = compileFinal preprocessFileLineNumbers "core\server\functions\fn_getGroundUnitsLocation.sqf";

// Directions 
fn_setRandomDirection = compileFinal preprocessFileLineNumbers "core\server\functions\fn_setRandomDirection.sqf";
fn_setDirectionOfMarker = compileFinal preprocessFileLineNumbers "core\server\functions\fn_setDirectionOfMarker.sqf";

// Players
fn_createLandingNearObject = compileFinal preprocessFileLineNumbers "core\server\functions\helicopters\fn_createLandingNearObject.sqf";
fn_checkPlayersAround = compileFinal preprocessFileLineNumbers "core\server\functions\fn_checkPlayersAround.sqf";

// Random
fn_getRandomVector = compileFinal preprocessFileLineNumbers "core\server\functions\fn_getRandomVector.sqf";
fn_addToZeus = compileFinal preprocessFileLineNumbers "core\server\functions\fn_addToZeus.sqf";
fn_checkPosition = compileFinal preprocessFileLineNumbers "core\server\functions\fn_checkPosition.sqf";