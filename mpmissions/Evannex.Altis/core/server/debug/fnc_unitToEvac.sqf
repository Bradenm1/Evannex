private _pad = _this select 0; // The position where the AI will spawn
private _index = _this select 1; // The index of the helictoper given other helicopters

private _group = createGroup WEST;
"C_man_p_beggar_F" createUnit [getMarkerPos _pad, _group];
br_friendly_groups_wating_for_evac pushBack _group;