function BloodCrossRise( keys )
	local target = keys.target
	local ability = keys.ability

	local jump = 9
	local targetLoc = target:GetAbsOrigin()
	local ground_position = GetGroundPosition(targetLoc, target)

	Timers:CreateTimer(0, function()
		local targetLoc = target:GetAbsOrigin()
		if target and target:HasModifier("modifier_cross_effect") then
			target:SetAbsOrigin(targetLoc + Vector(0,0,jump) )
			jump = jump - 0.15
			return 0.03
		elseif target:HasModifier("modifier_cross_fall") then
			target:SetAbsOrigin(targetLoc - Vector(0,0,jump) )
			jump = jump + 4

			if target:GetAbsOrigin().z - ground_position.z <= 0 then 
				FindClearSpaceForUnit(target, ground_position, false)
				target:RemoveModifierByName("modifier_cross_fall")
				return nil
			end
			return 0.03
		else 
			return nil
		end

	end)
end

function BloodCrossInitiate(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	else 
		ability:ApplyDataDrivenModifier(caster, target, "modifier_cross_effect", {})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_cross_effect_2", {})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_cross_fall", {})
	end
end

--[[function BloodCrossFall( keys )
	local target = keys.target
	local targetLoc = target:GetAbsOrigin()
	local ground_position = GetGroundPosition(targetLoc, target)

	if target:IsInvulnerable() then target.jump = 9 return end

	target:SetAbsOrigin(targetLoc - Vector(0,0,target.jump) )
	target.jump = target.jump + 4

	if target:GetAbsOrigin().z - ground_position.z <= 0 then 
		FindClearSpaceForUnit(target, ground_position, false)
		target.jump = 9
		target:RemoveModifierByName("modifier_cross_fall")
	end
end]]

function BloodCrossProjectile(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = keys.Radius
	local projectile = "particles/bellatrix_blood_cross_projectile.vpcf"

	local target_location = target:GetAbsOrigin()
	sourceTarget = target

	local nearby_units = FindUnitsInRadius(caster:GetTeam(), target_location, nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	target:EmitSound("Hero_Nevermore.ROS_Flames")

	for  _,v in ipairs(nearby_units) do  --Restore mana and play a particle effect for every found ally.
		local projectile_info = 
		{
			EffectName = projectile,
			Ability = ability,
			vSpawnOrigin = target_location,
			Target = v,
			Source = target,
			bHasFrontalCone = false,
			iMoveSpeed = 650,
			bReplaceExisting = false,
			bProvidesVision = true,
			iVisionRadius = 100,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		if v ~= target then 
			ProjectileManager:CreateTrackingProjectile(projectile_info)
		end
	end
end

function BloodCrossHeal( keys )
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability:GetAbilityDamage()
	local lifesteal_amount = ability:GetLevelSpecialValueFor("lifesteal", ability:GetLevel() - 1) / 100

	heal_amount = damage * lifesteal_amount

	sourceTarget:Heal(heal_amount, ability)

	if sourceTarget:IsAlive() then
		ability:ApplyDataDrivenModifier(caster, sourceTarget, "modifier_blood_cross_heal", {})
		PopupNumbers(sourceTarget, "heal", Vector(0, 255, 0), 2.0, heal_amount, POPUP_SYMBOL_PRE_PLUS, nil)
	end
end