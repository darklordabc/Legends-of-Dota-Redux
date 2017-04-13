--[[function ToxicDartsApplyRandomEffect( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local target_loc = target:GetAbsOrigin()
	
	local random_effect = RandomInt(1,4) 
	if not target:IsMagicImmune() then
		if random_effect == 1 then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_toxic_1", {})
		elseif random_effect == 2 then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_toxic_2", {})
		elseif random_effect == 3 then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_toxic_3", {})
		elseif random_effect == 4 then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_toxic_4", {})
		end
	end

	ability:CreateVisibilityNode(target_loc, 150, 1.5)
end]]

function ToxicDartsApplyToxicEffect( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local target_loc = target:GetAbsOrigin()

	local modifierName = "modifier_toxic_dart_effect"
	local duration = ability:GetSpecialValueFor("duration")
	local durationDecrease = ability:GetSpecialValueFor("duration_decrease")

	if target:IsMagicImmune() or not target:IsAlive() then return end
	
	if not target:HasModifier(modifierName) then
		ability:ApplyDataDrivenModifier(caster,target,modifierName,{Duration = duration})
		target:SetModifierStackCount(modifierName,ability,1)
		target.toxicStacks = 1
	else
		local modifier = target:FindModifierByName(modifierName)
		local modifierTime = modifier:GetRemainingTime()
		local stacks = target:GetModifierStackCount(modifierName,ability) + 1

		target:SetModifierStackCount(modifierName,ability,stacks)
		target.toxicStacks = stacks

		if modifierTime > durationDecrease then
			modifier:SetDuration(modifierTime - durationDecrease,true)
		else
			target:RemoveModifierByName(modifierName)
		end
	end
	ability:CreateVisibilityNode(target_loc, 150, 1.5)
end

function ToxicDartsApplyEndEffect( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	local modifierName = "modifier_toxic_dart_stun"
	local stunDuration = ability:GetSpecialValueFor("stun_duration")

	if target and target.toxicStacks then
		ability:ApplyDataDrivenModifier(caster,target,modifierName,{Duration = stunDuration * target.toxicStacks})
		target:SetModifierStackCount(modifierName,ability,target.toxicStacks)
		target.toxicStacks = nil
	end
end

function ToxicDartsStartCharge( keys )

	-- Variables
	local caster = keys.caster
	if not caster:IsRealHero() then return end
	local ability = keys.ability
	local thrill = caster:FindAbilityByName("veera_thrill_of_the_hunt")

	local modifierName = "modifier_toxic_dart_stack_count"
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	-- Initialize stack
	caster:SetModifierStackCount( modifierName, caster, 0 )
	caster.toxic_dart_charges = maximum_charges
	caster.start_charge = false
	caster.toxic_dart_cooldown = 0.0
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	caster:SetModifierStackCount( modifierName, caster, maximum_charges )
	
	local level = ability:GetLevel()
	Timers:CreateTimer( function()
		if ability:GetLevel() > level then return end

		if caster:HasModifier("modifier_thrill_active") and thrill then
			local cooldownReduction = 1 - (thrill:GetSpecialValueFor("cooldown_reduction") / 100)
			charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) ) * cooldownReduction
		else 
			charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
		end

		if caster.start_charge and caster.toxic_dart_charges < maximum_charges then
			-- Calculate stacks
			local next_charge = caster.toxic_dart_charges + 1
			caster:RemoveModifierByName( modifierName )
			if next_charge ~= maximum_charges then
				ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
				ToxicDartsStartCooldown( caster, charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
				caster.start_charge = false
			end
			caster:SetModifierStackCount( modifierName, caster, next_charge )
			
			-- Update stack
			caster.toxic_dart_charges = next_charge
		end
		
		-- Check if max is reached then check every 0.5 seconds if the charge is used
		if caster.toxic_dart_charges ~= maximum_charges then
			caster.start_charge = true
			return charge_replenish_time
		else
			return 0.5
		end 
	end 
	)
end
--[[
	Author: kritth
	Date: 6.1.2015.
	Helper: Create timer to track cooldown
]]
function ToxicDartsStartCooldown( caster, charge_replenish_time )
	caster.toxic_dart_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.toxic_dart_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.toxic_dart_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end

function ShootDart( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_toxic_dart_stack_count"
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	local thrill = caster:FindAbilityByName("veera_thrill_of_the_hunt")

	-- Check Thrill
	if caster:HasModifier("modifier_thrill_active") and thrill then
		local cooldownReduction = 1 - (thrill:GetSpecialValueFor("cooldown_reduction") / 100)
		charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) ) * cooldownReduction
	else 
		charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	end
	
	-- Deplete charge
	local next_charge = caster.toxic_dart_charges - 1
	if caster.toxic_dart_charges == maximum_charges then
		caster:RemoveModifierByName( modifierName )
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
		ToxicDartsStartCooldown( caster, charge_replenish_time )
	end
	caster:SetModifierStackCount( modifierName, caster, next_charge )
	caster.toxic_dart_charges = next_charge
		
	-- Check if stack is 0, display ability cooldown
	if caster.toxic_dart_charges == 0 then
		-- Start Cooldown from caster.shrapnel_cooldown
		ability:StartCooldown( caster.toxic_dart_cooldown )
	else
		ability:EndCooldown()
	end
end

--[[
	Author: Noya, Pizzalol
	Date: 05.02.2015.
	Shows the dazzle friendly armor particle
]]
function AcidDartParticle( event )
	local target = event.target
	local location = target:GetAbsOrigin()
	local particleName = event.particle_name
	local modifier = event.modifier

	-- Count the number of weave modifiers
	local count = 0

	for i = 0, target:GetModifierCount() do
		if target:GetModifierNameByIndex(i) == modifier then
			count = count + 1
		end
	end

	-- If its the first one then apply the particle
	if count == 1 then 
		target.AcidDartParticle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, target)
		ParticleManager:SetParticleControl(target.AcidDartParticle, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(target.AcidDartParticle, 1, target:GetAbsOrigin())

		ParticleManager:SetParticleControlEnt(target.AcidDartParticle, 1, target, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", target:GetAbsOrigin(), true)
	end
end

-- Destroys the particle when the modifier is destroyed, only when the target doesnt have the modifier
function EndAcidDartParticle( event )
	local target = event.target
	local particleName = event.particle_name
	local modifier = event.modifier

	if not target:HasModifier(modifier) then
		ParticleManager:DestroyParticle(target.AcidDartParticle,false)
	end
end
