if CLIENT then return end

function BKCServicesHalfHour()
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

function BKCServicesInit()
	timer.Create( "BKCServicesHalfHour", 1800, 0, BKCServicesHalfHour )
end
hook.Add( "Initialize", "BKCServicesInit", BKCServicesInit )

function BKCServicesOnDisconnect( ply )
	if ply:SteamID() != "BOT" then
		local hours = math.floor((ply:GetUTime() + CurTime() - ply:GetUTimeStart())/60/60)
		http.Fetch("http://bkcservice.zenforic.com/player.php?id="..ply:SteamID64().."&rank="..ply:GetUserGroup().."&hours="..hours)
	end
end
hook.Add( "PlayerDisconnected", "BKCServicesOnDisconnect", BKCServicesOnDisconnect )
