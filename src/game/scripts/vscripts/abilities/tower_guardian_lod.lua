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
		local guardianUnit = CreateUnitByName(guardian, tower:GetAbsOrigin()+tower:GetForwardVector():Normalized()*200, false, nil, nil, tower:GetTeam())
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
	ability:ApplyDataDrivenModifier(tower, unit, "modifier_guardian_teleport", {duration = 3})
				Timers:CreateTimer(3.1, function()
						unit:AddNoDraw()
						unit:ForceKill(false)
					end
				)
	
end

function GuardianScalingHandler(keys)
	local tower = keys.caster
	local target = keys.target
	local ability = keys.ability
	target:SetPhysicalArmorBaseValue(target:GetPhysicalArmorBaseValue() * FindTowerTier(tower))
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
	keys.target:RemoveNoDraw()
end

function FindTowerTier(tower)
	local iteration = tower:GetName()
	if tower:GetTeam() == DOTA_TEAM_GOODGUYS then
		iteration = string.gsub(iteration, "dota_goodguys_tower", "")
	elseif tower:GetTeam() == DOTA_TEAM_BADGUYS then
		iteration = string.gsub(iteration, "dota_badguys_tower", "")
	end
	iteration = string.gsub(iteration, "_bot", "")
	iteration = string.gsub(iteration, "_mid", "")
	iteration = string.gsub(iteration, "_top", "")
	local number = tonumber(iteration) or 1
	return tonumber(iteration)
end