if CLIENT then return end
include("gadis_config.lua")

function GadisHalfHour()
	local count = #player.GetHumans()
	if count > 0 then
		for k, v in pairs(player.GetHumans()) do
			if v:IsAdmin() then
				return
			end
		end
		http.Fetch("https://bkcapi.w0lfr.net:7860/call.php?serv=" .. engine.ActiveGamemode())
	end
end

function GadisInit()
	timer.Create( "GadisHalfHour", 1800, 0, GadisHalfHour )
end
hook.Add( "Initialize", "GadisInit", GadisInit )

gameevent.Listen( "player_disconnect" )
function GadisPlayerDisconnect( data )
	if not data.networkid:lower():find("bot") then
		local gadisPly = ULib.getPlyByID(data.networkid)
		local s64 = gadisPly:SteamID64()
		GadisMySQLQuery("UPDATE `metrics` SET `disconnect`=NOW() WHERE `disconnect` IS NULL AND `id`=" .. s64)
		GadisMySQLQuery("DELETE FROM `active` WHERE `id`=" .. s64)
		local time = gadisPly:GetUTimeTotalTime()
		local grp = ULib.ucl.getUserInfoFromID(data.networkid).group
		local hours = math.floor(time / 60 / 60)
		local linked = GadisMySQLQuery("SELECT * FROM `linked` WHERE `sid`=" .. s64)
		if linked then
			local rankid = GadisMySQLGetResult("SELECT `id` FROM `ranks` WHERE `name`='" .. grp .. "'")
			if rankid ~= nil and rankid[1].id >= 1 then
				local don = "FALSE"
				if grp:lower():find("donator") then
					don = "TRUE"
				end
				GadisMySQLQuery("UPDATE `linked` SET `donated`=" .. don .. ",`hours`=" .. hours .. ",`rank`=" .. rankid[1].id .. " WHERE `sid`=" .. s64)
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
		GadisMySQLQuery("INSERT INTO `metrics` (id) VALUES (" .. s64 .. ")")
		GadisMySQLQuery("INSERT INTO `active` (id) VALUES (" .. s64 .. ")")
	else
		print("A BOT CONNECTED!")
	end
end
hook.Add( "player_connect", "GadisPlayerConnect", GadisPlayerConnect )

function GadisPlayerDisconnectViaShutdown( gadisPly )
	local s64 = gadisPly:SteamID64()
	GadisMySQLQuery("UPDATE `metrics` SET `disconnect`=NOW() WHERE `disconnect` IS NULL AND `id`=" .. s64)
	GadisMySQLQuery("DELETE FROM `active` WHERE `id`=" .. s64)
	local time = gadisPly:GetUTimeTotalTime()
	local grp = ULib.ucl.getUserInfoFromID(gadisPly:SteamID()).group
	local hours = math.floor(time / 60 / 60)
	local linked = GadisMySQLQuery("SELECT * FROM `linked` WHERE `sid`=" .. s64)
	if linked then
		local rankid = GadisMySQLGetResult("SELECT `id` FROM `ranks` WHERE `name`='" .. grp .. "'")
		if rankid ~= nil and rankid[1].id >= 1 then
			local don = "FALSE"
			if grp:lower():find("donator") then
				don = "TRUE"
			end
			GadisMySQLQuery("UPDATE `linked` SET `donated`=" .. don .. ",`hours`=" .. hours .. ",`rank`=" .. rankid[1].id .. " WHERE `sid`=" .. s64)
		end
	end
end

local function BKCShuttingDown()
		for k, v in pairs(player.GetHumans()) do
			GadisPlayerDisconnectViaShutdown(v)
		end
end
hook.Add( "ShutDown", "BKCShuttingDown", BKCShuttingDown )
