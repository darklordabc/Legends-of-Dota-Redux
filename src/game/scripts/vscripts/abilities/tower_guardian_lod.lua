require("lib/timers")

function SummonGuardian(keys)
	local tower = keys.caster
	local ability = keys.ability
	local guardian = string.gsub(ability:GetName(), "tower_guardian_", "npc_dota_tower_guardian_")
	print(guardian, tower:GetName())
	Timers:CreateTimer(function()
      if tower:IsInvulnerable() then
		return 1
	  else
		local guardianUnit = CreateUnitByName(guardian, tower:GetAbsOrigin()+tower:GetForwardVector():Normalized()*200, false, tower, tower, tower:GetTeam())
		guardianUnit:SetOwner(tower)
		if tower:GetName() ~= 'npc_dota_tower' then
			guardianUnit:SetControllableByPlayer(tower:GetPlayerID(), true)
		end
		tower.guardianUnit = guardianUnit
		ability:ApplyDataDrivenModifier(tower, guardianUnit, "modifier_guardian_health_handler", {})
	  end
    end
  )
end

function KillGuardian(keys)
	local tower = keys.caster
	local ability = keys.ability
	local unit = tower.guardianUnit
	GameRules.deadTowers = GameRules.deadTowers or {}
	GameRules.deadTowers[tower:GetTeam()] = GameRules.deadTowers[tower:GetTeam()] or 0
	GameRules.deadTowers[tower:GetTeam()] = GameRules.deadTowers[tower:GetTeam()] + 1
	if tower:GetName() == 'npc_dota_tower' then
		ability:ApplyDataDrivenModifier(tower, unit, "modifier_guardian_teleport", {duration = 3})
					Timers:CreateTimer(3.1, function()
							unit:AddNoDraw()
							unit:ForceKill(false)
						end
					)
	else
		unit:ForceKill(false)
	end
end

function GuardianScalingHandler(keys)
	local tower = keys.caster
	local target = keys.target
	local ability = keys.ability
	if tower:GetName() == 'npc_dota_tower' then
		print("a tower")
		GameRules.deadTowers = GameRules.deadTowers or {}
		GameRules.deadTowers[tower:GetTeam()] = GameRules.deadTowers[tower:GetTeam()] or 0
		local deadTowers = GameRules.deadTowers[tower:GetTeam()]
		target:SetMaxHealth(target:GetMaxHealth() + 75*deadTowers)
		target:SetBaseMaxHealth(target:GetBaseMaxHealth() + 75*deadTowers)
		target:SetHealth(target:GetMaxHealth())
		target:SetBaseDamageMax(target:GetBaseDamageMax() + 7.5*deadTowers)
		target:SetBaseDamageMin(target:GetBaseDamageMin() + 7.5*deadTowers)
		target:SetPhysicalArmorBaseValue(target:GetPhysicalArmorBaseValue() + tower:GetPhysicalArmorBaseValue())
		for i = 0, 16 do
			local guardianAb = target:GetAbilityByIndex(i)
			if guardianAb then
				guardianAb:SetLevel(deadTowers)
			end
		end
	else
		print("not a tower")
		local level = tower:GetLevel()
		target:SetMaxHealth(target:GetMaxHealth() + 50*level)
		target:SetBaseMaxHealth(target:GetBaseMaxHealth() + 50*level)
		target:SetHealth(target:GetMaxHealth())
		target:SetBaseDamageMax(target:GetBaseDamageMax() + 5*level)
		target:SetBaseDamageMin(target:GetBaseDamageMin() + 5*level)
		target:SetPhysicalArmorBaseValue(target:GetPhysicalArmorBaseValue() + tower:GetPhysicalArmorBaseValue())
		for i = 0, 16 do
			local guardianAb = target:GetAbilityByIndex(i)
			if guardianAb then
				guardianAb:SetLevel(level)
			end
		end
	end
end

function GuardianDamageHandler(keys)
	local tower = keys.caster
	local ability = keys.ability
	local unit = keys.unit

	if keys.dmgtaken < unit:GetHealth() then return
	else
		if not unit:HasModifier("modifier_guardian_teleport") then
			if ability then
				ability:ApplyDataDrivenModifier(tower, unit, "modifier_guardian_teleport", {duration = 3})
				Timers:CreateTimer(3.1, function()
						unit:AddNoDraw()
					end
				)
			else unit:ForceKill(false) -- double check
			end
		end
	end
end

function ResetGuardian(keys)
	FindClearSpaceForUnit(keys.target, keys.caster:GetAbsOrigin()+keys.caster:GetForwardVector():Normalized()*200, true)
	keys.target:RemoveNoDraw()
end