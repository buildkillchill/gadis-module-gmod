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
	http.Fetch("https://bkcapi.w0lfr.net/metrics.php?id="..data.networkid.."&acc=0&act=1")
	local ply = player.GetBySteamID(data.networkid)
	if !data.bot and ply != false then
		local hours = math.floor((ply:GetUTime() + CurTime() - ply:GetUTimeStart())/60/60)
		http.Fetch("https://bkcapi.w0lfr.net/player.php?id="..ply:SteamID64().."&rank="..ply:GetUserGroup().."&hours="..hours)
	end
end
hook.Add( "player_disconnect", "GadisOnDisconnect", GadisOnDisconnect )

function GadisPlayerInitialSpawn( ply )
	if ply:SteamID() != "BOT" then
		http.Fetch("https://bkcapi.w0lfr.net/metrics.php?id="..ply:SteamID().."&acc=0&act=0")
	end
end
hook.Add( "PlayerInitialSpawn", "GadisPlayerInitialSpawn", GadisPlayerInitialSpawn )
