if CLIENT then return end

function GadisHalfHour()
	local count = #player.GetHumans()
	if count > 0 then
		for k,v in pairs(player.GetHumans()) do
			if v:IsAdmin() then
				return
			end
		end
		http.Fetch("https://bkcapi.w0lfr.net:7860/call.php?serv="..engine.ActiveGamemode())
	end
end

function GadisInit()
	timer.Create( "GadisHalfHour", 1800, 0, GadisHalfHour )
end
hook.Add( "Initialize", "GadisInit", GadisInit )

gameevent.Listen( "player_disconnect" )
function GadisPlayerDisconnect( data )
	print("Player with ID " .. data.networkid .. " has disconnected.")
	if not data.bot then
		print("ID " .. data.networkid .. " was determined to be human, so disconnect will be logged")
		http.Fetch("https://bkcapi.w0lfr.net:7860/metrics.php?id="..data.networkid.."&acc=0&act=1")
		local uid = util.CRC("gm_" .. data.networkid .. "_gm")
		local row = sql.QueryRow("SELECT totaltime FROM utime WHERE player = " .. uid .. ";")
		local time = row and row.totaltime
		local grp = ucl.getUserInfoFromID(uid)["group"]
		local hours = math.floor(time/60/60)
		local s64 = util.SteamIDTo64(data.networkid)
		http.Fetch("https://bkcapi.w0lfr.net:7860/player.php?id="..s64.."&rank="..grp.."&hours="..hours)
	else
		print("ID " .. data.networkid .. " was determined to be a bot, ignoring connection")
	end
end
hook.Add( "player_disconnect", "GadisPlayerDisconnect", GadisPlayerDisconnect )

gameevent.Listen( "player_connect" )
function GadisPlayerConnect( data )
	print("Player with ID " .. data.networkid .. " has connected.")
	if not data.bot then
		print("ID " .. data.networkid .. " was determined to be human, so connection will be logged")
		local s64 = util.SteamIDTo64(data.networkid)
		http.Fetch("https://bkcapi.w0lfr.net:7860/metrics.php?id="..s64.."&acc=0&act=0")
	else
		print("ID " .. data.networkid .. " was determined to be a bot, ignoring connection")
	end
end
hook.Add( "player_connect", "GadisPlayerConnect", GadisPlayerConnect )
