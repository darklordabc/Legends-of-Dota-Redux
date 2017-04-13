require('lib/physics')
function PursuitAttack (keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local baseDamage = ability:GetLevelSpecialValueFor("base_damage", ability:GetLevel() - 1)
	local movementDamage = ability:GetLevelSpecialValueFor("movement_damage", ability:GetLevel() - 1) / 100

	pursuitMovementDamage = (caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed()) - caster:GetBaseMoveSpeed()) * movementDamage
	if pursuitMovementDamage < 0 then pursuitMovementDamage = 0 end
	pursuitDamage = baseDamage + pursuitMovementDamage
	pursuitTarget = target
end

function CheckOrb(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if ability:IsCooldownReady() then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_pursuit_orb", {Duration = 0.9})
	end
end

function CheckPursuit( keys )
	local caster = keys.caster
	local target = pursuitTarget
	local ability = keys.ability

	local caster_loc = caster:GetAbsOrigin()
	local target_loc = target:GetAbsOrigin()
	local distance = (caster_loc - target_loc):Length2D()

	ability:CreateVisibilityNode(target_loc, 30, 0.15)

	if distance < 300 then
		if caster:IsDisarmed() or target:IsUnselectable() or target:IsAttackImmune() or target:IsInvulnerable() or not target:IsAlive() then
			caster:RemoveModifierByName("modifier_pursuit_buff")
			pursuitTarget:RemoveModifierByName("modifier_pursuit_vision")
		end
	end
end

function SetPursuitDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local duration = ability:GetSpecialValueFor("duration")
	local creepDuration = ability:GetSpecialValueFor("creep_duration")

	local baseDamage = ability:GetLevelSpecialValueFor("base_damage", ability:GetLevel() - 1)
	local movementDamage = ability:GetLevelSpecialValueFor("movement_damage", ability:GetLevel() - 1) / 100

	if target:IsHero() then
		ability:ApplyDataDrivenModifier(caster,target,"modifier_pursuit_debuff",{Duration = duration})
	else
		ability:ApplyDataDrivenModifier(caster,target,"modifier_pursuit_debuff",{Duration = creepDuration})
	end

	pursuitMovementDamage = (caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed()) - caster:GetBaseMoveSpeed()) * movementDamage
	if pursuitMovementDamage < 0 then pursuitMovementDamage = 0 end
	target.pursuitDamage = baseDamage + pursuitMovementDamage
end

function PursuitDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target.pursuitDamage == nil then target.pursuitDamage = 20 end

	DamageTable = {}
    
        DamageTable.victim = target
        DamageTable.attacker = caster
        DamageTable.damage = target.pursuitDamage
        DamageTable.damage_type = ability:GetAbilityDamageType()
        DamageTable.ability = ability

    ApplyDamage(DamageTable)

--[[local amount = target.pursuitDamage

    local armor = target:GetPhysicalArmorValue()
    local damageReduction = ((0.02 * armor) / (1 + 0.02 * armor))
    amount = amount - (amount * damageReduction)

    local lens_count = 0
    for i=0,5 do
        local item = caster:GetItemInSlot(i)
        if item ~= nil and item:GetName() == "item_aether_lens" then
            lens_count = lens_count + 1
        end
    end
    
    amount = amount * (1 + (.08 * lens_count) + (.01 * caster:GetIntellect()/16) )

    amount = math.floor(amount)

    PopupNumbers(target, "crit", Vector(204, 0, 0), 2.0, amount, nil, POPUP_SYMBOL_POST_DROP)]]
end


function RollInitiate( keys )
	local caster = keys.caster
	local ability = keys.ability
	local leap_speed = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed()) + 150
	local casterAngles = caster:GetAngles()

	-- Clears any current command
	caster:Stop()
	caster:SetForceAttackTarget(nil)
	local start_position = GetGroundPosition(caster:GetAbsOrigin() , caster)

	-- Physics
	local direction = caster:GetForwardVector()
	local velocity = leap_speed * 3.0
	local end_time = 0.6
	local time_elapsed = 0
	local time = 0.3
	local jump = 48
	local flip = 360

	Physics:Unit(caster)

	caster:PreventDI(true)
	caster:SetAutoUnstuck(false)
	caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	caster:FollowNavMesh(false)
	caster:SetPhysicsVelocity(-direction * velocity)
	
	-- Dodge projectiles


	-- Move the unit
	Timers:CreateTimer(0, function()
		local ground_position = GetGroundPosition(caster:GetAbsOrigin() , caster)
		time_elapsed = time_elapsed + 0.03
		local yaw = casterAngles.x - ((time_elapsed * 3) * flip)
		GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), 150, false)
		caster:SetAngles(yaw, casterAngles.y, casterAngles.z ) 
		if flip > 0 then flip = flip - 9 else flip = 0 end

		if time_elapsed < 0.3 then
			caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,jump))
			ProjectileManager:ProjectileDodge(caster)
			jump = jump - 2.4
		else
			caster:SetAbsOrigin(caster:GetAbsOrigin() - Vector(0,0,jump)) -- Going down
			jump = jump * 1.06
		end
		
		
		if caster:GetAbsOrigin().z - ground_position.z <= 0 then
			caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin() , caster))

		end
		if time_elapsed > end_time and caster:GetAbsOrigin().z - ground_position.z <= 0 then 
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), false)
			caster:SetAngles(0, casterAngles.y, casterAngles.z )
			caster:SetPhysicsAcceleration(Vector(0,0,0))
			caster:SetPhysicsVelocity(Vector(0,0,0))
			caster:OnPhysicsFrame(nil)
			caster:PreventDI(false)
			caster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
			caster:SetAutoUnstuck(true)
			caster:FollowNavMesh(true)
			caster:SetPhysicsFriction(.05)	
			return nil
		end

		return 0.03
	end)
end

function RemoveForceAttack( keys )
	keys.caster:SetForceAttackTarget(nil)
end

function StartCooldown(keys)
	local caster = keys.caster
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local mana = ability:GetManaCost(ability:GetLevel() - 1)
	if caster:HasModifier("modifier_thrill_active") then 
		local cooldownReduction = 1 - (caster:FindAbilityByName("veera_thrill_of_the_hunt"):GetSpecialValueFor("cooldown_reduction") / 100)
		cooldown = cooldown * cooldownReduction
	end
	ability:StartCooldown(cooldown)
	caster:SpendMana(mana, ability)
end