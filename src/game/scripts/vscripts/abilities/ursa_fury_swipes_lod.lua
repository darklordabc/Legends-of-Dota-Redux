--[[
	Author: kritth (modified by SwordBacon)
	Date: 7.1.2015.
	Increasing stack after each hit
]]

LinkLuaModifier( "modifier_fury_swipes_bonus_damage", "abilities/ursa_fury_swipes_lod.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[
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
			EffectName = "particles/holdout_lina/wildfire_projectile.vpcf",
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
]]

function fury_swipes_check_stacks( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierName = "modifier_fury_swipes_target_lod"
	local modifierNameB = "modifier_fury_swipes_bonus_damage"
	
	target.stacks = target:GetModifierStackCount( modifierName, ability )
	ability:ApplyDataDrivenModifier( caster, caster, modifierNameB, {} )

end

function fury_swipes_attack( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierName = "modifier_fury_swipes_target_lod"
	local damageType = ability:GetAbilityDamageType()
	local exceptionName = "npc_dota_roshan"

	if target:IsBuilding() then return end
	if not caster:IsRealHero() then return end
	
	if caster:PassivesDisabled() then return end
	
	-- Necessary value from KV
	local duration = ability:GetLevelSpecialValueFor( "bonus_reset_time", ability:GetLevel() - 1 )
	-- Modifies damage bonus if ranged attacker

	if target:GetName() == exceptionName then   -- Put exception here
		duration = ability:GetLevelSpecialValueFor( "bonus_reset_time_roshan", ability:GetLevel() - 1 )
	end
	
	local current_stack = target.stacks or 1

	-- Check if unit already have stack
	-- Apply modifier to target
	ability:ApplyDataDrivenModifier( caster, target, modifierName, { Duration = duration } )
	target:SetModifierStackCount( modifierName, ability, current_stack )

end

-- FURY SWIPES DAMAGE MODIFIERS
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

function modifier_fury_swipes_bonus_damage:GetModifierProcAttack_BonusDamage_Physical(params)
    local caster = params.attacker
    local target = params.target
    if not caster:IsRealHero() then return 0 end
	if caster:PassivesDisabled() then return 0 end
	
    if not target.stacks then 
    	target.stacks = 0 
    end
    local nFurySwipes
    
    if caster:IsRangedAttacker() then
        nFurySwipes = ( target.stacks + 1) * (self:GetAbility():GetLevelSpecialValueFor("damage_per_stack_ranged", self:GetAbility():GetLevel() - 1))
    else
    	nFurySwipes = ( target.stacks + 1) * (self:GetAbility():GetLevelSpecialValueFor("damage_per_stack", self:GetAbility():GetLevel() - 1))
    end
    
    target.stacks = target.stacks + 1
    return nFurySwipes
end
