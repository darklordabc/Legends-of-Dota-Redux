if IsServer() then
	require('lib/timers')
end

function SpawnHawk( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	local ability_level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor( "duration" , ability_level )
	local point = caster:GetAbsOrigin() 
	local team = caster:GetTeamNumber()
	
	PrecacheUnitByNameAsync("npc_custom_unit_hawk", function(...)
		local cr = CreateUnitByName("npc_custom_unit_hawk", point + RandomVector(RandomFloat(100, 100)), true, caster, caster, team)
		Timers:CreateTimer(.04, function()
     		cr:SetControllableByPlayer(caster:GetPlayerID(), true)
  		end)
		
		print("Script spawner: " .. cr:GetUnitName())
		
		cr:AddAbility("angel_arena_hawk_passive")
        local ab = cr:FindAbilityByName("angel_arena_hawk_passive")
        if ab then
            ab:SetLevel(ability_level+1)
        end
		cr:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
	end)
end
