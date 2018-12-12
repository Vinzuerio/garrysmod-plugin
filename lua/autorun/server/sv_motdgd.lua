MOTDgd = MOTDgd or {}
MOTDgd.Version = "2.07"

util.AddNetworkString("MOTDgdShow")
util.AddNetworkString("MOTDgdUpdate")

include("motdgd_config.lua")
AddCSLuaFile("motdgd_config.lua")

if SERVER then
	MOTDgd.CvarPluginVersion = CreateConVar("sm_motdgd_version", "2.07-gm", FCVAR_NOTIFY + FCVAR_DONTRECORD, "MOTDgd LUA Plugin Version")
end

function MOTDgd.GetServerInfo()
	local SvAddress = string.Explode(':',game.GetIPAddress())
	
	local HostIP = SvAddress[1]
	MOTDgd.Port = SvAddress[2]
	
	MOTDgd.IP = HostIP
end

function MOTDgd.Show(ply, Forced, WaitTime, isAdRetry)
	if !ply.MOTDgdCached then
		net.Start( "MOTDgdUpdate" )
			net.WriteDouble( MOTDgd.UserID )
			net.WriteString( MOTDgd.IP )
			net.WriteDouble( MOTDgd.Port )
			net.WriteString( MOTDgd.Version )
			net.WriteDouble( WaitTime )
			net.WriteBit( Forced )
			net.WriteString( ply:SteamID() )
		net.Send( ply )
		ply.MOTDgdCached = true
	else
		net.Start("MOTDgdShow")
			net.WriteBit( Forced )
		net.Send( ply )
	end
end

hook.Add("OnGamemodeLoaded", "MOTDgdOnGamemodeLoadedHook", function()
	MOTDgd.GetServerInfo()
end)

hook.Add("PlayerInitialSpawn", "MOTDgdPlayerInitialSpawnHook", function(ply)
	ply.MOTDgdSkipNextSpawn = true
	if MOTDgd.ShowOnJoin then
		MOTDgd.Show(ply, MOTDgd.Forced, MOTDgd.WaitTime, false)
	end
end)

hook.Add("PlayerSpawn", "MOTDgdPlayerSpawnHook", function(ply)
	if MOTDgd.OnPlayerSpawn then
		if !ply.MOTDgdSkipNextSpawn then
			MOTDgd.Show( ply, MOTDgd.OnPlayerSpawnForced, MOTDgd.OnPlayerSpawnWaitTime, false )
		else
			ply.MOTDgdSkipNextSpawn = false
		end
	end
end)

hook.Add("PlayerDeath", "MOTDgdPlayerDeathHook", function(ply)
	if MOTDgd.OnPlayerDeath then
		MOTDgd.Show( ply, MOTDgd.OnPlayerDeathForced, MOTDgd.OnPlayerDeathWaitTime, false )
	end
end)

hook.Add("TTTEndRound", "MOTDgdTTTEndRoundHook", function(ply)
	if MOTDgd.OnTTTEndRound then
		for k, v in pairs( player.GetAll() ) do
			MOTDgd.Show( v, MOTDgd.OnTTTEndRoundForced, MOTDgd.OnTTTEndRoundWaitTime, false )
		end
	end
end)
