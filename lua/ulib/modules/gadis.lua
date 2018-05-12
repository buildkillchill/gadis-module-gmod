if CLIENT then return end

function GadisHalfHour()
	local count = #player.GetHumans()
	if count > 0 then
		for k,v in pairs(player.GetHumans()) do
			if v:IsAdmin() then
				return
			end
		end
		http.Fetch("https://bkcapi.w0lfr.net/call.php?serv="..engine.ActiveGamemode())
	end
end

function GadisInit()
	timer.Create( "GadisHalfHour", 1800, 0, GadisHalfHour )
end
hook.Add( "Initialize", "GadisInit", GadisInit )

gameevent.Listen( "player_disconnect" )
function GadisOnDisconnect( data )
	if !data.bot then
		http.Fetch("https://bkcapi.w0lfr.net/metrics.php?id="..data.networkid.."&acc=0&act=1")
		local uid = util.CRC("gm_" .. data.networkid .. "_gm")
		local row = sql.QueryRow("SELECT totaltime FROM utime WHERE player = " .. uid .. ";")
		local time = row and row.totaltime
		local grp = ucl.getUserInfoFromID(uid)["group"]
		local hours = math.floor(time/60/60)
		local s64 = util.SteamIDTo64(data.networkid)
		http.Fetch("https://bkcapi.w0lfr.net/player.php?id="..s64.."&rank="..grp.."&hours="..hours)
	end
end
hook.Add( "player_disconnect", "GadisOnDisconnect", GadisOnDisconnect )

function GadisPlayerInitialSpawn( ply )
	if ply:SteamID() != "BOT" then
		http.Fetch("https://bkcapi.w0lfr.net/metrics.php?id="..ply:SteamID().."&acc=0&act=0")
	end
end
hook.Add( "PlayerInitialSpawn", "GadisPlayerInitialSpawn", GadisPlayerInitialSpawn )
