# Evannex Gamemode
---
Arma 3 - AI vs AI Gamemode. Zones are randomly generated around the map you need to capture these zones by completing objectives and killing the AI within the zone. This game mode does not require any players input. AI will command themselves leaving players to do without having to micro manage the AI.

Note: This is my first ArmA 3 mod. This gamemode is also based off Invade & Annex and is very similar. I did not use their framework or code because I wanted to learn the SQF language and thought it would be fun to make my own version. This is why it does not include the same things.

![alt text](http://www.bradenmckewen.com/img/projects/arma-3-mods/evannexstuff.jpg "Gamemode Header Image")

## Features:
---
- Customizeable & dynamic systems (Includes mission parameters)
- Mini central intelligences controlling both enemy & friendly AI
- Friendies can mark enemies on the map 
- Friendly transport & evac (Includes helicopters & vehicles)
- Friendly vehicles & helictopers & jets
- Friendly units respawn as a different unit
- Friendly squads which do the objectives (Includes side missions)
- Enemies can garrison structures
- Recruitable friendly units
- Randomly generated enemy zones (Includes the objectives)
- Randomly generated side missions
- Randomly generated enemy & friendly units
- Randomly generated Base Defences
- Randomly generated mines within the zone
- Random enemy group formations, combat styles & speed
- Utilizes compositions
- Spawnable vehicles
- Easy to add support for custom maps
- Teleport to zone button
- Virutal support
- Virutal Arsenal
- Networked tasks
- DLC support
- Co-op support

## Server Params:
---
Currently not listed...

## Markers:
---
Note: 'n' refers to some number.
##### "zone_spawn_n":
Location where zones can potentially spawn
##### "marker_ai_spawn_friendly_ground_units":
Friendly ground units spawn.
##### "recruit_n":
Friendly recruits spawn.
##### "defence_spawn_n":
Friendly base defences spawn
##### "helicopter_transport_n":
Friendly transport helicopter spawn
##### "helicopter_evac_n":
Friendly evac helicopter spawn
##### "vehicle_spawn_n":
Friendly vehicle spawn
##### "vehicle_evac_spawn_n":
Friendly evac helicopter spawn
##### "vehicle_transport_spawn_n":
Friendly vehicle spawn
##### "jet_spawn_n":
Friendly jet spawn
##### "objective_squad_n":
Friendly Objetive squad spawn

## Adding Custom Faction:
---
1. Clone a one of the directories within 'core/spawnlists'.
2. Name the cloned directory according to the custom faction being added. e.g 'FOOBAR'.
3. Add the custom faction to the 'Description.ext' file within the one or both classes 'FriendlyFaction' & 'EnemyFaction' as a text and value. E.G:
⋅⋅⋅values[] = {0,1,2,3,4};⋅⋅
⋅⋅⋅texts[] = {"BLU_F", "OPF_F", "RHSUSAF", "RHSAFRF", "FOOBAR"};⋅⋅
6. Add the custom faction to the switch statement as a case in the function 'br_fnc_get_faction' within 'core/server/zone/zoneCreation.sqf' file. E.G: 'case 4: { _faction = "FOOBAR" };'.
7. Lastly change the asset classes held within the 'FOOBAR' directory to spawn the custom faction units. E.G: changing the class names within 'friendly_jets.sqf' would change what type of jets spawn at the "jet_spawn_n" marker.

See other included factions for examples.

## Credits:
---
- J.Shock - Shock's Building Garrison Function - Garrisons units into buildings
- Quiksilver - Soldier Tracker - Shows units on the map.
- Quiksilver (Again) - Invade & Annex gamemode which this was inspired from