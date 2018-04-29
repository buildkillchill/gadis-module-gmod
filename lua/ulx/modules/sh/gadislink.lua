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

