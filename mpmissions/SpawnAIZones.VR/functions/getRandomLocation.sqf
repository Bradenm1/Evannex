// Gets the zone location
_location = br_zones select br_current_zone;
// Gets a random location within the zone radius
_location getPos [br_zone_radius * sqrt random br_min_radius_distance, random br_max_radius_distance];