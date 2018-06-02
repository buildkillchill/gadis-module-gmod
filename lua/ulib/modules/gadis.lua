if CLIENT then return end
include("gadis_config.lua")

gameevent.Listen( "player_disconnect" )
function GadisPlayerDisconnect( data )
	if not data.networkid:lower():find("bot") then
		local gadisPly = ULib.getPlyByID(data.networkid)
		local s64 = util.SteamIDTo64(data.networkid)
		GadisMySQLQuery("UPDATE `metrics` SET `disconnect`=NOW() WHERE `disconnect` IS NULL AND `id`=" .. s64)
		GadisMySQLQuery("DELETE FROM `active` WHERE `id`=" .. s64)
		local time = gadisPly:GetUTimeTotalTime()
		local grp = ULib.ucl.getUserInfoFromID(data.networkid).group
		local hours = math.floor(time / 60 / 60)
		local linked = GadisMySQLQuery("SELECT * FROM `accounts` WHERE `sid`=" .. s64)
		if linked then
			local rankid = GadisMySQLGetResult("SELECT `id` FROM `ranks` WHERE `name`='" .. grp .. "'")
			if rankid ~= nil and rankid[1].id >= 1 then
				local don = "FALSE"
				if grp:lower():find("donator") then
					don = "TRUE"
				end
				GadisMySQLQuery("UPDATE `accounts` SET `donated`=" .. don .. ",`hours`=" .. hours .. ",`rank`=" .. rankid[1].id .. " WHERE `sid`=" .. s64)
			end
		end
	else
		print("A BOT DISCONNECTED!")
	end
end
hook.Add( "player_disconnect", "GadisPlayerDisconnect", GadisPlayerDisconnect )

gameevent.Listen( "player_connect" )
function GadisPlayerConnect( data )
	if not data.networkid:lower():find("bot") then
		local s64 = util.SteamIDTo64(data.networkid)
		GadisMySQLQuery("REPLACE INTO `metrics` (id) VALUES (" .. s64 .. ")")
		GadisMySQLQuery("INSERT INTO `active` (id) VALUES (" .. s64 .. ")")
	else
		print("A BOT CONNECTED!")
	end
end
hook.Add( "player_connect", "GadisPlayerConnect", GadisPlayerConnect )

local function BKCShuttingDown()
	for k, v in pairs(player.GetHumans()) do
		local s64 = v:SteamID64()
		GadisMySQLQuery("UPDATE `metrics` SET `disconnect`=NOW() WHERE `disconnect` IS NULL AND `id`=" .. s64)
	end
	GadisMySQLQuery("DELETE FROM `active` WHERE TRUE")
end
hook.Add( "ShutDown", "BKCShuttingDown", BKCShuttingDown )
