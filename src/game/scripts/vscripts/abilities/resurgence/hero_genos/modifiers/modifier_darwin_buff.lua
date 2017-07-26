--[[Author: TheGreatGimmick
    Date: May 16, 2017
    Modifier that switches dummy items for the real one]]

modifier_darwin_buff = class({}) 


function modifier_darwin_buff:DeclareFunctions()
	local funcs = {
            --MODIFIER_PROPERTY_BASE_MANA_REGEN,
            MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
            --MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, 
    }

	return funcs
end

function modifier_darwin_buff:OnCreated( kv )   
    --if IsServer() then
        print("")
        print("Calculating Darwin Bonuses")
        
        local caster = self:GetParent()
        local ability = self:GetAbility()
        local ability_level = ability:GetLevel() - 1

        if not caster.last_death_time then
            caster.last_death_time = GameRules:GetGameTime()
        end
        local current_time = GameRules:GetGameTime()
        local survival_time = (current_time - caster.last_death_time)/60
        if IsServer() then

            if caster:PassivesDisabled() then
                self.darwin_regen = 0
            else
                self.darwin_regen =(ability:GetLevelSpecialValueFor("regen", ability_level))*survival_time
            end
            
            local mod = caster:FindModifierByName("modifier_darwin_buff")
            if mod then
                mod:SetStackCount(self.darwin_regen)
            end

            print("Regen: "..self.darwin_regen)
        end
    --end
end

--[[
function modifier_darwin_buff:GetModifierBaseRegen ()
    return self.darwin_mana
end
]]

function modifier_darwin_buff:GetModifierConstantManaRegen ()
    return self.darwin_regen/2
end

function modifier_darwin_buff:GetModifierConstantHealthRegen ()
    return self.darwin_regen
end

--function modifier_darwin_buff:GetModifierMoveSpeedBonus_Constant ()
--    return self.darwin_speed
--end

function modifier_darwin_buff:IsHidden() 
	return false
end