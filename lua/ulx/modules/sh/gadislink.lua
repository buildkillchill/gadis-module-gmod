require("mysqloo")
include("../../../ulib/modules/gadis_config.lua")

function ulx.link(ply, linkCode)
	local steamid = ply:SteamID64()
	local res = GadisMySQLGetResult("SELECT `id` FROM `link` WHERE `code`='" .. linkCode .. "' AND `used`=FALSE")
	local num = 0
	for _ in pairs(res) do
		num = num + 1
	end
	if num == 1 then
		local did = res[1].id
		GadisMySQLQuery("INSERT INTO `linked` (`sid`, `did`) VALUES (" .. steamid .. "," .. did .. ") ON DUPLICATE KEY UPDATE `did`=" .. did .. ",`sid`=" .. steamid)
		GadisMySQLQuery("UPDATE `link` SET `used`=TRUE WHERE `code`='" .. linkCode .. "'")
		ULib.tsay( ply, "You are now linked " .. ply:Nick() .. ", thank you." )
	else
		ULib.tsayError( ply, "Link failed, error: Invalid Link Code", true )
	end
end
local link = ulx.command("Utility", "ulx link", ulx.link, "!link")
link:defaultAccess(ULib.ACCESS_ALL)

link:addParam{ type = ULib.cmds.NumArg, min = 10000, max = 99999, hint = "Link Code from Gadis", ULib.cmds.round }


link:help("Used to confirm the linking process for the Gadis bot.")

function ulx.gadistime(Admin, ply)
	local time = ply:GetUTimeTotalTime()
	time = math.floor(time / 60 / 60)
	ULib.tsay(Admin, ply:Nick() .. "'s UTime is: " .. time, true)
end
local gadistime = ulx.command("Utility", "ulx gadistime", ulx.gadistime, "!gadistime")
gadistime:defaultAccess(ULib.ACCESS_ADMIN)
gadistime:addParam{ type = ULib.cmds.PlayerArg }
gadistime:help("Prints the UTime in hours of the player.")
