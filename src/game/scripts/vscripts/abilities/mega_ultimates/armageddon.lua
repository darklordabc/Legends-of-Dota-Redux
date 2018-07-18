--local timers = require('easytimers')

function StartArmageddon(keys)
	local caster = keys.caster
	local ability = keys.ability

	local armageddon_unit = CreateUnitByName("npc_armageddon", caster:GetAbsOrigin(), true, caster, nil, caster:GetTeam())
	armageddon_unit:SetControllableByPlayer(caster:GetPlayerOwnerID(),false)
	armageddon_unit:SetOwner(caster)

	local armageddon_ability = armageddon_unit:FindAbilityByName("armageddon_chaos_meteor")
	armageddon_ability:UpgradeAbility(true)

	local duration = ability:GetSpecialValueFor("duration")
	local interval = 1 / ability:GetSpecialValueFor("meteors_per_second")
	
	local time = 0

	armageddon_unit:AddNewModifier(caster, nil, "modifier_kill", {Duration = duration})
	armageddon_unit:AddNewModifier(caster,nil,"modifier_invulnerable", {})

	Timers:CreateTimer(function()
		time = time + interval
		if time < duration then
			local randomLocation = RandomVector(RandomInt(1500, 9000))

			armageddon_unit:SetAbsOrigin(randomLocation)
			armageddon_unit:SetCursorPosition(randomLocation + RandomVector(1400))
			armageddon_ability:OnSpellStart()
			return interval
		else 
			return nil
		end
	end, DoUniqueString('zulf_typhhoon'), interval)
end 


