--[[Author: YOLOSPAGHETTI
	Date: March 15, 2016
	Creates the death ward]]
if IsServer() then
	require('lib/timers')
end

function CreateWard(keys)
	local caster = keys.caster
	local ability = keys.ability
	local position = ability:GetCursorPosition()
	local ability_level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor( "duration" , ability_level )
	print (ability_level)
	-- Creates the death ward (There is no way to control the default ward, so this is a custom one)
	if ability_level == 0 then
		caster.death_ward = CreateUnitByName("npc_dota_armoured_centipede_ward_1", position, true, caster, nil, caster:GetTeam())
	elseif ability_level == 1 then
		caster.death_ward = CreateUnitByName("npc_dota_armoured_centipede_ward_2", position, true, caster, nil, caster:GetTeam())
	elseif ability_level == 2 then
		caster.death_ward = CreateUnitByName("npc_dota_armoured_centipede_ward_3", position, true, caster, nil, caster:GetTeam())
	end
	
	caster.death_ward:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})		
	caster.death_ward:SetControllableByPlayer(caster:GetPlayerID(), true)
	caster.death_ward:SetOwner(caster)
	Timers:CreateTimer(.5, function()
		caster:EmitSound("RoshanDT.Scream")
	end)
	
	
end

--[[Author: YOLOSPAGHETTI
	Date: March 15, 2016
	Removes the death ward entity from the game and stops its sound]]
function DestroyWard(keys)
	local caster = keys.caster
	caster.death_ward:ForceKill(true)
	--UTIL_Remove(caster.death_ward)
end
