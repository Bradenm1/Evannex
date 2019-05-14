params["_vehicle", "_group"];

waitUntil { sleep br_garbage_collection_interval; !alive _vehicle};

// Remove the AI from the vehicle groups
br_friendly_ai_groups deleteAt (br_friendly_ai_groups find _group);
br_friendly_vehicles deleteAt (br_friendly_vehicles find _group);

// Append the units as normal ground units
br_friendly_ground_groups pushBack _group;
br_friendly_ai_groups pushBack _group;