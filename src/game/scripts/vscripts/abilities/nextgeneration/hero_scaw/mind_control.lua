function MindControlAdd( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if target:TriggerSpellAbsorb(ability) then
		RemoveLinkens(target)
		return
	end

	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1)
	enemyTeam = target:GetTeamNumber()
	friendlyPlayer = caster:GetPlayerID()
	enemyPlayer = target:GetPlayerID()

	if not target:HasModifier("modifier_mind_control") then
		target:SetTeam(15)
		target:SetOwner(caster)
		ability:ApplyDataDrivenModifier(caster, target, "modifier_mind_control", {Duration = duration})
		target:SetControllableByPlayer(0, false)
        target:MoveToNPC(caster)
	end
end

function MindControlThink( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	target:MoveToNPC(caster)
end

function MindControlRemove( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	target:SetTeam(enemyTeam)
	target:SetOwner(PlayerResource:GetPlayer( enemyPlayer ) )
	target:SetControllableByPlayer(enemyPlayer, true)
	target:StopSound("Hero_Enigma.Midnight_Pulse")

	target:Stop()
end

function MindControlDamageCheck( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.unit
	
	if target.damage == nil then target.damage = 0 end
	
	local threshold = ability:GetLevelSpecialValueFor("damage_threshold", ability:GetLevel() - 1)
	target.damage = target.damage + keys.DamageTaken
	
	if target.damage > threshold or target.damage > target:GetHealth() then
		target:RemoveModifierByName("modifier_mind_control")
		target.damage = 0
	end
	
end

function CheckAghs( keys )
	
	-- Variables
	local caster = keys.caster
	local ability = keys.ability

	local modifierName = "modifier_mesmerize_charges"
	local maximum_charges = ability:GetLevelSpecialValueFor("scepter_maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	if caster:HasScepter() and not caster:HasModifier(modifierName) then
		MesmerizeStartCharge( keys )
	elseif not caster:HasScepter() and caster:HasModifier(modifierName) then
		caster:RemoveModifierByName(modifierName)
	end
end

function MesmerizeStartCharge( keys )

	-- Variables
	local caster = keys.caster
	local ability = keys.ability

	local modifierName = "modifier_mesmerize_charges"
	local maximum_charges = ability:GetLevelSpecialValueFor("scepter_maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "scepter_cooldown", ( ability:GetLevel() - 1 ) )
	
	-- Initialize stack
	caster:SetModifierStackCount( modifierName, caster, 0 )
	if ability:IsCooldownReady() then
		caster.ulti_charges = 1
	else
		caster.ulti_charges = 0
	end
	caster.start_charge = false
	caster.ulti_cooldown = 0.0
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	caster:SetModifierStackCount( modifierName, caster, 1 )
	
	local level = ability:GetLevel()
	Timers:CreateTimer( function()
		if ability:IsNull() or ability:GetLevel() > level or not caster:HasScepter() then return end

		charge_replenish_time = ability:GetLevelSpecialValueFor("scepter_cooldown", ability:GetLevel() - 1)

		if caster.start_charge and caster.ulti_charges < maximum_charges then
			-- Calculate stacks
			local next_charge = caster.ulti_charges + 1
			caster:RemoveModifierByName( modifierName )
			if next_charge ~= maximum_charges then
				ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
				MesmerizeStartCooldown( caster, charge_replenish_time )
			else
				ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
				caster.start_charge = false
			end
			caster:SetModifierStackCount( modifierName, caster, next_charge )
			
			-- Update stack
			caster.ulti_charges = next_charge
		end
		
		-- Check if max is reached then check every 0.5 seconds if the charge is used
		if caster.ulti_charges ~= maximum_charges then
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
function MesmerizeStartCooldown( caster, charge_replenish_time )
	caster.ulti_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.ulti_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.ulti_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end

function Mesmerize( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_mesmerize_charges"
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )


	if caster:HasScepter() then
		charge_replenish_time = ability:GetLevelSpecialValueFor("scepter_cooldown", ability:GetLevel() - 1)

		-- Deplete charge
		local next_charge = caster.ulti_charges - 1
		if caster.ulti_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
			MesmerizeStartCooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.ulti_charges = next_charge
			
		-- Check if stack is 0, display ability cooldown
		if caster.ulti_charges == 0 then
			ability:StartCooldown( caster.ulti_cooldown )
		else
			ability:EndCooldown()
		end
	end
end