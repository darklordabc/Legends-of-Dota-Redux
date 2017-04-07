function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

function CheckForDeath( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local damage = keys.Damage

	if target:GetHealth() < 2 then
		respawnPoint = target:GetAbsOrigin()
		respawnHero = target
		local time = target:GetRespawnTime() / 2
		if time > 1 then
			target:RemoveModifierByName("modifier_dead_man")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_dead_man_contain", {Duration = time})
			target:Kill(ability, caster)
			target:SetTimeUntilRespawn(time)
			caster:SwapAbilities("suna_dead_mans_chest", "suna_kyonshi", false, true)
		else
			target:RemoveModifierByName("modifier_dead_man")
			target:Kill(ability, caster)
		end
	end
end

function KyonshiSwap( keys )
	local caster = keys.caster
	local target = keys.target
	print("respawned")

	target:RemoveModifierByName("modifier_dead_man_contain")
	caster:SwapAbilities("suna_kyonshi", "suna_dead_mans_chest", false, true)
end

function KyonshiRevive( keys )
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)

	local target = respawnHero
	local point = respawnPoint

	local time = target:GetTimeUntilRespawn()
	target:SetRespawnPosition(point)
	target:SetControllableByPlayer( caster:GetPlayerOwnerID(), true )
	target:RespawnUnit()
	ability:ApplyDataDrivenModifier(caster, target, "modifier_kyonshi", {Duration = duration})
	target:RemoveModifierByName("modifier_dead_man_contain")

	if caster:HasScepter() then
		target:AddNewModifier(caster, nil, "modifier_rune_haste", {duration = -1})
		target:AddNewModifier(caster, nil, "modifier_omniknight_repel", {duration = -1})
	end

	Timers:CreateTimer(duration, function()
		target:SetControllableByPlayer( target:GetPlayerID(), true )
		target:ForceKill(false)
		target:SetTimeUntilRespawn(time)
	end)

	caster:SwapAbilities("suna_kyonshi", "suna_dead_mans_chest", false, true)
end