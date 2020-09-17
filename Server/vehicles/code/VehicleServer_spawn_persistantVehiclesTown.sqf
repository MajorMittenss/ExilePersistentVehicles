/*
 * Vehicles Server VehicleServer_spawn_PersistantVehiclesTown
 *
 * Spawns Vehicles randomly in towns, will spawn within a 200m radius of each town center, 400m on big towns.
 *
 * Made by Andrew_S90
 */

private ["_main", "_type", "_dbID", "_currentVeh", "_targetVeh", "_center", "_classnames", "_damageMin", "_damageMax", "_bigTowns", "_towns", "_blacklistPos", "_classname", "_found", "_count", "_spawnPos", "_town", "_radius"];

_main = _this select 0;
_type = _this select 1;
_dbID = _this select 2;
_currentVeh = _this select 3;
_targetVeh = _this select 4;

try 
{
	if (_type isEqualTo "") then
	{
		throw "Error in the class called, No type found";
	};
	if (_dbID isEqualTo "") then
	{
		throw "Database ID is wrong, vehicles can't spawn without this!";
	};
	if (_targetVeh isEqualTo 0) then
	{
		throw "Target number of vehicles was not properly found...";
	};
	if (_currentVeh > _targetVeh) then
	{
		throw "You already have more vehicles then allowed to spawn...";
	};
	

	_center = getArray(configfile >> "CfgSettings" >> "SpawnSettings" >> worldName);
	if(count _center < 1) then
	{
		_center = [[worldSize/2,worldSize/2,0],5000];
	};
	_classnames = getArray(configfile >> "CfgSettings" >> _main >> _type >> "Classnames");
	_damageMin = getNumber(configfile >> "CfgSettings" >> _main >> _type >> "DamageMin");
	_damageMax = getNumber(configfile >> "CfgSettings" >> _main >> _type >> "DamageMax");
	_bigTowns = getArray(configfile >> "CfgSettings" >> _main >> _type >> "BigTowns");
	_towns = nearestLocations [(_center select 0), ["NameVillage","NameCity","NameCityCapital"], ((_center select 1)+4000)];
	
	_blacklistPos = [];
	
	for "_i" from _currentVeh to (_targetVeh-1) do
	{
		_classname = selectRandom _classnames;
		_found = false;
		_count = 0;
		_spawnPos = [];
		
		while {!_found || _count > 200} do
		{
			_town = selectRandom _towns;
			_radius = 200;
			if(text _town in _bigTowns) then
			{
				_radius = 400;
			};
			
			_spawnPos = [locationPosition _town, 0, _radius, 7, 0, 0.25, 0, _blacklistPos,[0,0,0]] call BIS_fnc_findSafePos;
			
			if((_spawnPos isEqualTo [0,0,0]) || (_spawnPos isEqualTo 0)) then
			{
				_count = _count+1;
			}
			else
			{
				_spawnPos pushBack 0;
				_blacklistPos pushBack [_spawnPos,15];
				_found = true;
				[_dbID,_classname,_spawnPos,_damageMin,_damageMax] call VehicleServer_world_createPersistantVehicle;
			};
		};
	};
}
catch
{
	format ["VehicleServer_spawn_PersistantVehiclesTown: %1", _exception] call ExileServer_util_log;
};