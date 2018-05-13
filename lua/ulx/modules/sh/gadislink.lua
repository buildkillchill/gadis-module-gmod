function ulx.link(ply, linkCode)
  local steamid = ply:SteamID64()
  http.Fetch("http://bkcservice.zenforic.com/link.php?id=" .. steamid .. "&code=" .. linkCode,
	function( body, len, headers, code )
		ULib.tsay( ply, "You are now linked " .. ply:Nick() .. ", thank you." )
	end,
	function( error )
		ULib.tsayError( ply, "Link failed, error: " .. error, true )
	end
 )
end
local link = ulx.command("Utility", "ulx link", ulx.link, "!link")
link:defaultAccess(ULib.ACCESS_ALL)

link:addParam{ type = ULib.cmds.NumArg, min = 10000, max = 99999, hint = "Link Code from Gadis", ULib.cmds.round }


link:help("Used to confirm the linking process for the Gadis bot.")

function ulx.gadistime(Admin, ply)
	local uid = ply:UniqueID()
	local row = sql.QueryRow("SELECT totaltime FROM utime WHERE player = " .. uid .. ";")
	local time = row and row.totaltime
	time = math.floor(time / 60 / 60)
	ULib.tsay(Admin, ply:Nick() .. "'s UTime is: " .. time, true)
end
local gadistime = ulx.command("Utility", "ulx gadistime", ulx.gadistime, "!gadistime")
gadistime:defaultAccess(ULib.ACCESS_ADMIN)
gadistime:addParam{ type = ULib.cmds.PlayerArg }
gadistime:help("Prints the UTime in hours of the player.")
