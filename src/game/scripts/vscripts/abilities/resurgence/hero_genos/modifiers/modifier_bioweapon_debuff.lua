--[[Author: TheGreatGimmick
    Date: May 16, 2017
    Modifier that switches dummy items for the real one]]

modifier_bioweapon_debuff = class({}) 


function modifier_bioweapon_debuff:DeclareFunctions()
	local funcs = {
         MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, 
    }

	return funcs
end

function modifier_bioweapon_debuff:OnCreated( kv )   
    if IsServer() then
        print("")
    	print('Leap vision modifier begun')
        self:StartIntervalThink(1)
    end
end

function modifier_bioweapon_debuff:OnIntervalThink()
    if IsServer() then
    	local unit = self:GetParent()
        local ability = self:GetAbility()
        local caster = ability:GetCaster()

        local ability_level = ability:GetLevel() - 1

        --local dmg = ability:GetLevelSpecialValueFor("damage", ability_level) + (caster:FindModifierByName("modifier_bioweapon_adaptations"):GetStackCount())*40
        local dmg = ability:GetLevelSpecialValueFor("damage", ability_level) + caster.bioweapon_adaptations*30

        local damageTable = {
                victim = unit,
                attacker = caster,
                damage = dmg,
                damage_type = DAMAGE_TYPE_MAGICAL,
                }
        if not unit:IsMagicImmune() then
            ApplyDamage(damageTable)
            unit:EmitSound("Hero_Brewmaster.ThunderClap.Target")
        end
    end
end

function modifier_bioweapon_debuff:GetModifierMoveSpeedBonus_Percentage ()
    return self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_bioweapon_debuff:IsHidden() 
	return false
end