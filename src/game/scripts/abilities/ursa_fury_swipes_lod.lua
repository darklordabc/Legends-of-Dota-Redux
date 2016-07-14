--[[
	Author: kritth (modified by SwordBacon)
	Date: 7.1.2015.
	Increasing stack after each hit
]]

LinkLuaModifier( "modifier_fury_swipes_bonus_damage", "scripts/vscripts/../abilities/ursa_fury_swipes_lod.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_fury_swipes_bonus_damage_ranged", "scripts/vscripts/../abilities/ursa_fury_swipes_lod.lua" ,LUA_MODIFIER_MOTION_NONE )

function fury_swipes_preattack_ranged( keys )
	local caster = keys.attacker
	local target = keys.target
	local ability = keys.ability
	local projectileSpeed = caster:GetProjectileSpeed()

	if caster:IsRangedAttacker() then
		local projTable = {
			Target = target,
			Source = caster,
			Ability = ability,
			EffectName = "", -- "particles/holdout_lina/wildfire_projectile.vpcf" used for testing
			bDodgeable = false,
			bProvidesVision = false,
			iMoveSpeed = projectileSpeed, 
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, 
			vSpawnOrigin = caster:GetAbsOrigin()
		}
		ProjectileManager:CreateTrackingProjectile( projTable )
	else
		fury_swipes_check_stacks(keys)
	end

end

function fury_swipes_check_stacks( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierName = "modifier_fury_swipes_target_lod"
	local modifierNameB = "modifier_fury_swipes_bonus_damage"

	if caster:IsRangedAttacker() then 
		modifierNameB = "modifier_fury_swipes_bonus_damage_ranged"
	end

	target.stacks = target:GetModifierStackCount( modifierName, ability )
	ability:ApplyDataDrivenModifier( caster, caster, modifierNameB, {} )
	caster:SetModifierStackCount( modifierNameB, ability, target.stacks )
end

function fury_swipes_attack( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierName = "modifier_fury_swipes_target_lod"
	local modifierNameB = "modifier_fury_swipes_bonus_damage"
	local damageType = ability:GetAbilityDamageType()
	local exceptionName = "npc_dota_roshan"

	if target:IsBuilding() then return end
	if not caster:IsRealHero() then return end
	
	-- Necessary value from KV
	local duration = ability:GetLevelSpecialValueFor( "bonus_reset_time", ability:GetLevel() - 1 )
	-- Modifies damage bonus if ranged attacker
	if caster:IsRangedAttacker() then 
		modifierNameB = "modifier_fury_swipes_bonus_damage_ranged"
	end

	if target:GetName() == exceptionName then   -- Put exception here
		duration = ability:GetLevelSpecialValueFor( "bonus_reset_time_roshan", ability:GetLevel() - 1 )
	end
	
	local current_stack = target.stacks or 0
	print(current_stack)

	-- Check if unit already have stack
	if target:HasModifier( modifierName ) then
		-- Check stacks from local variable
		
		-- Apply modifier to target
		ability:ApplyDataDrivenModifier( caster, target, modifierName, { Duration = duration } )
		target:SetModifierStackCount( modifierName, ability, current_stack + 1 )

		-- Apply modifier to caster (bonus damage)
		ability:ApplyDataDrivenModifier( caster, caster, modifierNameB, {} )
		caster:SetModifierStackCount( modifierNameB, ability, current_stack + 1 )
	else
		-- Apply modifier to target
		ability:ApplyDataDrivenModifier( caster, target, modifierName, { Duration = duration } )
		target:SetModifierStackCount( modifierName, ability, 1 )
		
		-- Apply modifier to caster (bonus damage)
		ability:ApplyDataDrivenModifier( caster, caster, modifierNameB, {} )
		caster:SetModifierStackCount( modifierNameB, ability, 1 )
	end
	target.stacks = 0
	caster:RemoveModifierByName(modifierNameB)
end

-- FURY SWIPES DAMAGE MODIFIERS
-- Melee
if modifier_fury_swipes_bonus_damage == nil then
	modifier_fury_swipes_bonus_damage = class({})
end

function modifier_fury_swipes_bonus_damage:DeclareFunctions()
	return 
	{ 
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end

function modifier_fury_swipes_bonus_damage:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_fury_swipes_bonus_damage:IsHidden()
	return true
end

function modifier_fury_swipes_bonus_damage:GetModifierProcAttack_BonusDamage_Physical()
	return (self:GetStackCount() * self:GetAbility():GetLevelSpecialValueFor("damage_per_stack", self:GetAbility():GetLevel() - 1))
end


-- RANGED
if modifier_fury_swipes_bonus_damage_ranged == nil then
	modifier_fury_swipes_bonus_damage_ranged = class({})
end

function modifier_fury_swipes_bonus_damage_ranged:DeclareFunctions()
	return 
	{ 
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
end

function modifier_fury_swipes_bonus_damage_ranged:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_fury_swipes_bonus_damage_ranged:IsHidden()
	return true
end

function modifier_fury_swipes_bonus_damage_ranged:GetModifierProcAttack_BonusDamage_Physical()
	return self:GetStackCount() * (self:GetAbility():GetLevelSpecialValueFor("damage_per_stack_ranged", self:GetAbility():GetLevel() - 1))
end
