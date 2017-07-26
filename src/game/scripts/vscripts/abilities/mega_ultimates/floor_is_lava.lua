function StartLava(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster.lava_unit = CreateUnitByName("npc_lava", caster:GetAbsOrigin(), true, caster, nil, caster:GetTeam())
	local lava_unit = caster.lava_unit
	lava_unit:SetControllableByPlayer(caster:GetPlayerOwnerID(),false)
	lava_unit:SetOwner(caster)

	local lava_ability = lava_unit:FindAbilityByName("mega_macropyre")
	lava_ability:UpgradeAbility(true)

	local time = 0
	local interval = 1/30
	local duration = 1.5


	lava_unit:AddNewModifier(caster, nil, "modifier_kill", {Duration = 2})
	lava_unit:AddNewModifier(caster, nil, "modifier_invulnerable", {})

	Timers:CreateTimer(0, function()
		time = time + interval
		if time < duration then
			local newLocation = caster:GetAbsOrigin()
			lava_unit:SetAbsOrigin(newLocation + caster:GetForwardVector() * 200 + RandomVector(200))
			lava_unit:SetCursorPosition(newLocation + caster:GetForwardVector() * 1200 + RandomVector(600))
			lava_ability:OnSpellStart()
			return interval
		else 
			return nil
		end
	end)
end 


