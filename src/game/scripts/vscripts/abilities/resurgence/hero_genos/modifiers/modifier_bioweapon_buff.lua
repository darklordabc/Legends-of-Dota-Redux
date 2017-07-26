--[[Author: TheGreatGimmick
    Date: May 16, 2017
    Modifier that switches dummy items for the real one]]

modifier_bioweapon_buff = class({}) 


function modifier_bioweapon_buff:DeclareFunctions()
	local funcs = {
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    }

	return funcs
end

function modifier_bioweapon_buff:OnCreated( kv )   
    --if IsServer() then
        print("")
        
        local caster = self:GetParent()
        local ability = self:GetAbility()--caster:FindAbilityByName("genos_aquired_immunity")
        local ability_level = ability:GetLevel() - 1

        --self.attksp = ability:GetLevelSpecialValueFor("attksp", ability_level) + (caster:FindModifierByName("modifier_bioweapon_adaptations"):GetStackCount())*20
        self.attksp = ability:GetLevelSpecialValueFor("attksp", ability_level) + caster.bioweapon_adaptations*20
        print("Attack Speed: "..self.attksp)
    --end
end

function modifier_bioweapon_buff:GetModifierAttackSpeedBonus_Constant ()
    return self.attksp
end

function modifier_bioweapon_buff:IsHidden() 
	return false
end