--[[
	Author: kritth (modified by SwordBacon)
	Date: 7.1.2015.
	Increasing stack after each hit
]]

function fury_swipes_attack( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierName = "modifier_fury_swipes_target_lod"
	local damageType = ability:GetAbilityDamageType()
	local exceptionName = "npc_dota_roshan"

	if target:IsBuilding() then return end
	if caster:IsIllusion() then return end
	
	-- Necessary value from KV
	local duration = ability:GetLevelSpecialValueFor( "bonus_reset_time", ability:GetLevel() - 1 )
	local damage_per_stack = ability:GetLevelSpecialValueFor( "damage_per_stack", ability:GetLevel() - 1 )
	-- Modifies damage bonus if ranged attacker
	if caster:IsRangedAttacker() then damage_per_stack = ability:GetLevelSpecialValueFor( "damage_per_stack_ranged", ability:GetLevel() - 1 ) end
	-- Filters out int scaling
	damage_per_stack = damage_per_stack/(1+caster:GetIntellect()/1600)

	if target:GetName() == exceptionName then	-- Put exception here
		duration = ability:GetLevelSpecialValueFor( "bonus_reset_time_roshan", ability:GetLevel() - 1 )
	end
	
	-- Check for current stacks
	local current_stack = target:GetModifierStackCount( modifierName, ability )
	if current_stack == nil then current_stack = 0 end
		
	-- Reset duration
	target:RemoveModifierByName(modifierName)
	ability:ApplyDataDrivenModifier( caster, target, modifierName, { Duration = duration } )
	
	-- Update current stacks
	current_stack = current_stack + 1
	target:SetModifierStackCount( modifierName, ability, current_stack)
		
	-- Deal damage
	local damage_table = {
		victim = target,
		attacker = caster,
		damage = damage_per_stack * current_stack,
		damage_type = damageType
		}
	ApplyDamage( damage_table )
end
