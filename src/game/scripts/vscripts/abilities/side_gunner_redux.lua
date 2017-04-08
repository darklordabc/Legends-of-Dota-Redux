if IsServer() then
	require('lib/timers')
end

function Impact( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if caster:IsNull() then return end

	caster:PerformAttack(target, false, true, true, false, false, false, true)
end

function Shot( keys )
	local caster = keys.caster
	local ability = keys.ability

	if caster:PassivesDisabled() or caster:IsInvisible() or caster:IsIllusion() then
		return false
	end

	local attackRange = ability:GetSpecialValueFor("range")
	local projectileSpeed = caster:GetProjectileSpeed()
	local interval = ability:GetSpecialValueFor("interval")
	if caster:HasScepter() then
       interval = ability:GetSpecialValueFor("interval_scepter")
   	end

	local units = FindUnitsInRadius(caster:GetTeamNumber(),caster:GetAbsOrigin(),nil,attackRange,DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	for k,v in pairs(units) do
	if v and caster:CanEntityBeSeenByMyTeam(v) and not v:IsInvulnerable() then
			local projectileInfo = 
		    {
		        EffectName = "particles/units/heroes/hero_gyrocopter/gyro_base_attack.vpcf",
		        Ability = ability,
		        Target = v,
		        Source = caster,
		        bHasFrontalCone = false,
		        iMoveSpeed = 3000,
		        bReplaceExisting = false,
		        bProvidesVision = false,
		        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		    }

		    caster:EmitSound("Hero_Gyrocopter.Attack")

			ProjectileManager:CreateTrackingProjectile(projectileInfo)

			caster:RemoveModifierByName("modifier_side_gunner_redux")

			ability:ApplyDataDrivenModifier(caster,caster,"modifier_side_gunner_redux_cd",{duration = interval})
			ability:StartCooldown(interval)

		    Timers:CreateTimer( interval, function()
		    	if caster:IsNull() then return end
		    	if caster:HasAbility("side_gunner_redux") and caster:IsAlive() then
		    		ability:ApplyDataDrivenModifier(caster,caster,"modifier_side_gunner_redux",{})
		    	end
		    end)
			return
		end
	end
end