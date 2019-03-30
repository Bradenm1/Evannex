private _ai = _this select 0;

_ai addAction ["Recruit", { 
  [_this select 0] join group (_this select 1);
  (_this select 0) removeAction (_this select 2);
}];

_ai addAction ["Delete", { 
  deleteVehicle (_this select 0) select 0;
}];