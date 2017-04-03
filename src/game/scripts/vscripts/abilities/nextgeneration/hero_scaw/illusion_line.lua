function CreateIllusions( keys )
	local caster = keys.caster
	local ability = keys.ability
	local player = caster:GetPlayerID()
	local point = keys.target_points[1]
	
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )
	local delay = ability:GetLevelSpecialValueFor("illusion_delay", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor("incoming_damage", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor("outgoing_damage", ability:GetLevel() - 1 )
	
	local origin = caster:GetAbsOrigin()
	local forwardVec = caster:GetForwardVector()
	local distance = (point - origin):Length2D()
	local location = origin + forwardVec * distance
	local sideVec = caster:GetRightVector()

	local randomPos = RandomInt(1,5)
	if caster:HasModifier("modifier_spirit_realm") then randomPos = 0 end

	local vec = {}

	vec[0] = origin
	vec[1] = location + sideVec * 350
	vec[2] = location + sideVec * 175
	vec[3] = location
	vec[4] = location + sideVec * -175
	vec[5] = location + sideVec * -350

	local casterVec = vec[randomPos]

	ProjectileManager:ProjectileDodge(caster)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_fire_spawn", {})

	local projectiles = {}

	for i = 1, 5 do
		distance = (vec[i] - origin):Length2D() + 0.1
		vector = (vec[i] - origin):Normalized()
		speed = distance / delay
		local projectileTable =
		{
			EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
			Ability = ability,
			vSpawnOrigin = origin,
			vVelocity = Vector( vector.x * speed, vector.y * speed, 0 ),
			fDistance = distance,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
		}

		projectiles[i] = ProjectileManager:CreateLinearProjectile(projectileTable)

	end


	caster:AddNoDraw()
	caster:AddNewModifier(caster, ability, "modifier_disabled_invulnerable", {Duration = delay})
	caster:AddNewModifier(caster, ability, "modifier_disarmed", {Duration = delay})

	FindClearSpaceForUnit(caster, casterVec, false) 

	local illusion = {}

	Timers:CreateTimer(delay, function()
		caster:RemoveNoDraw()
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_fire_spawn", {})
		if not caster:IsChanneling() then
			caster:MoveToPositionAggressive(casterVec)
		end
		
		for j = 1, 5 do
			if randomPos ~= j then
				illusion[j] = CreateUnitByName(caster:GetName(), vec[j], true, caster, nil, caster:GetTeamNumber())
				illusion[j]:SetPlayerID(caster:GetPlayerID())
				illusion[j]:SetControllableByPlayer(player, true)
				FindClearSpaceForUnit(illusion[j], vec[j], false) 
				illusion[j]:SetForwardVector(forwardVec)
				ability:ApplyDataDrivenModifier(caster, illusion[j], "modifier_fire_spawn", {})
				local casterLevel = caster:GetLevel()
				for i=1,casterLevel-1 do
					illusion[j]:HeroLevelUp(false)
				end

				-- Set the skill points to 0 and learn the skills of the caster
				illusion[j]:SetAbilityPoints(0)
				for abilitySlot=0,15 do
					local illusionAbility = caster:GetAbilityByIndex(abilitySlot)
					if illusionAbility ~= nil then 
						local abilityLevel = illusionAbility:GetLevel()
						local abilityName = illusionAbility:GetAbilityName()
						illusion[j].illusionAbility = illusion[j]:FindAbilityByName(abilityName)
						illusion[j].illusionAbility:SetLevel(abilityLevel)
					end
				end
				-- Recreate the items of the caster
				for itemSlot=0,5 do
					local item = caster:GetItemInSlot(itemSlot)
					if item ~= nil then
						local itemName = item:GetName()
						local newItem = CreateItem(itemName, illusion, illusion)
						illusion[j]:AddItem(newItem)
					end
				end
				illusion[j]:SetHealth(caster:GetHealth())		
				illusion[j]:SetOwner(caster)
				illusion[j]:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
				ability:ApplyDataDrivenModifier(caster, illusion[j], "modifier_fire_spawn", {})
				illusion[j]:MakeIllusion()
				illusion[j]:EmitSound("Hero_Jakiro.LiquidFire")
			end
		end
	end)
end
--[[
function CheckDeath( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local target = keys.unit
	local ability = keys.ability

	if target:GetHealth() < 2 then
		
		local projTable = {
            EffectName = "particles/scawmar_illusion_line_fireball.vpcf",
            Ability = ability,
            Target = attacker,
            Source = target,
            bDodgeable = true,
            bProvidesVision = false,
            vSpawnOrigin = target:GetAbsOrigin(),
            iMoveSpeed = 700,
            iVisionRadius = 0,
            iVisionTeamNumber = caster:GetTeamNumber(),
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
        }
        ProjectileManager:CreateTrackingProjectile(projTable)
        target:ForceKill(false)
	end

end]]--