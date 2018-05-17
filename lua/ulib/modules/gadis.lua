if CLIENT then return end
require("mysqloo")
include("config.lua")

local function GetMySQLResult(query)
	local db = mysqloo.connect(Gadis.host, Gadis.user, Gadis.pass, Gadis.name, Gadis.port)
	db:connect()
	db:wait()
	local q = db:query(query)
	q:start()
	q:wait(true)
	return q:getData()
end

local function QueryMySQL(query)
	local num = 0
	for i, v in GetMySQLResult(query) do
		num = num + 1
	end
	return num
end

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
		print("A HUMAN HAS DISCONNECTED! ID: " .. data.networkid)
		QueryMySQL("UPDATE `metrics` SET `disconnect`=NOW() WHERE `disconnect` IS NULL AND `id`=" .. data.networkid)
		QueryMySQL("DELETE FROM `active` WHERE `id`=" .. data.networkid)
		local uid = util.CRC("gm_" .. data.networkid .. "_gm")
		local row = sql.QueryRow("SELECT totaltime FROM utime WHERE player = " .. uid .. ";")
		local time = row and row.totaltime
		local grp = ucl.getUserInfoFromID(uid)["group"]
		local hours = math.floor(time / 60 / 60)
		local s64 = util.SteamIDTo64(data.networkid)
		local linked = QueryMySQL("SELECT * FROM `linked` WHERE `sid`=" .. s64)
		if linked then
			local rankid = GetMySQLResult("SELECT `id` FROM `ranks` WHERE `name`='" .. grp .. "'")
			if rankid ~= nil then
				local don = "FALSE"
				if grp:lower():find("donated") then
					don = "TRUE"
				end
				QueryMySQL("UPDATE `linked` SET `donated`=" .. don .. ",`hours`=" .. hours .. ",`rank`=" .. rankid .. " WHERE `id`=" .. s64)
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
		print("A HUMAN HAS CONNECTED! ID: " .. data.networkid)
		local s64 = util.SteamIDTo64(data.networkid)
		QueryMySQL("INSERT INTO `metrics` (id) VALUES (" .. data.networkid .. ")")
		QueryMySQL("INSERT INTO `active` (id) VALUES (" .. data.networkid .. ")")
	else
		print("A BOT CONNECTED!")
	end
end
hook.Add( "player_connect", "GadisPlayerConnect", GadisPlayerConnect )
