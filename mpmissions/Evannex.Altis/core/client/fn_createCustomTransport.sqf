{
	_x addAction ["Transport AI", { 
		if (!(isNull vehicle (_this select 0))) then {
			[_this select 0, vehicle (_this select 0)] remoteExec ["MP_create_custom_transport", 2];
		}
	}];
} foreach thisList;