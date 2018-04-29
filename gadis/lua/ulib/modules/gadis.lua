if CLIENT then return end

function GadisHalfHour()
	local count = #player.GetHumans()
	if count > 0 then
		for k,v in pairs(player.GetHumans()) do
			if v:IsAdmin() then
				return
			end
		end
		http.Fetch("http://bkcservice.zenforic.com/call.php?serv="..engine.ActiveGamemode())
	end
end

function GadisInit()
	timer.Create( "GadisHalfHour", 1800, 0, GadisHalfHour )
end
hook.Add( "Initialize", "GadisInit", GadisInit )

function GadisOnDisconnect( ply )
	if ply:SteamID() != "BOT" then
		local hours = math.floor((ply:GetUTime() + CurTime() - ply:GetUTimeStart())/60/60)
		http.Fetch("http://bkcservice.zenforic.com/player.php?id="..ply:SteamID64().."&rank="..ply:GetUserGroup().."&hours="..hours)
		http.Fetch("http://bkcservice.zenforic.com/metrics.php?id="..ply:SteamID64().."&acc=0&act=1")
	end
end
hook.Add( "PlayerDisconnected", "GadisOnDisconnect", GadisOnDisconnect )

function GadisOnConnect( ply )
	if ply:SteamID() != "BOT" then
		http.Fetch("http://bkcservice.zenforic.com/metrics.php?id="..ply:SteamID64().."&acc=0&act=0")
	end
end
hook.Add( "PlayerConnected", "GadisOnConnect", GadisOnConnect )
