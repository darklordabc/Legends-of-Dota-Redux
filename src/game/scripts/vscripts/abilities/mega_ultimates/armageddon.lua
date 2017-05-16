function StartArmageddon(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster.armageddon = CreateUnitByName("npc_armageddon", caster:GetAbsOrigin(), true, caster, nil, caster:GetTeam())
	local armageddon_unit = caster.armageddon
	armageddon_unit:SetControllableByPlayer(caster:GetPlayerOwnerID(),false)
	armageddon_unit:SetOwner(caster)

	local armageddon_ability = armageddon_unit:FindAbilityByName("armageddon_chaos_meteor")
	armageddon_ability:UpgradeAbility(true)

	local duration = 10
	local time = 0

	armageddon_unit:AddNewModifier(caster, nil, "modifier_kill", {Duration = duration})
	armageddon_unit:AddNewModifier(caster,nil,"modifier_invulnerable", {})

	Timers:CreateTimer(0, function()
		time = time + (1/20)
		if time < duration then
			local randomLocation = RandomVector(math.random(1500, 9000))

			armageddon_unit:SetAbsOrigin(randomLocation)
			armageddon_unit:SetCursorPosition(randomLocation + RandomVector(1400))
			armageddon_ability:OnSpellStart()
			return 1/20
		else 
			return nil
		end
	end)
end 


