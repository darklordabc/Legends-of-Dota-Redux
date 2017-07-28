--[[Author: TheGreatGimmick
    Date: May 15, 2017
    Modifier that switches dummy items for the real one]]

modifier_exoskeleton = class({}) 


function modifier_exoskeleton:DeclareFunctions()
	local funcs = {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
            MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    }

	return funcs
end

function modifier_exoskeleton:OnCreated( kv )   
    --if IsServer() then
        print("")
        print('Initializing Exoskeleton Modifier')
   --[[     
        local caster = self:GetParent()
        local ability = self:GetAbility()--caster:FindAbilityByName("genos_aquired_immunity")
        local ability_level = ability:GetLevel() - 1
--[[
        self.resist = ability:GetLevelSpecialValueFor("magicresist", ability_level) + (caster:FindModifierByName("modifier_aquired_immunity_adaptations"):GetStackCount())*5
        self.armor = ability:GetLevelSpecialValueFor("armor", ability_level) + (caster:FindModifierByName("modifier_aquired_immunity_adaptations"):GetStackCount())*2
  

        self.resist = ability:GetLevelSpecialValueFor("magicresist", ability_level) + caster.aquired_immunity_adaptations*5
        self.armor = ability:GetLevelSpecialValueFor("armor", ability_level) + caster.aquired_immunity_adaptations*2
    ]]
        --local caster = self:GetParent()
        self.resist = kv.R --caster.exoskeleton_magic_resistance
        self.armor = kv.A --caster.exoskeleton_armor

        print(self.resist)
        print(self.armor)
        self:StartIntervalThink(0.01)
    --end
end

function modifier_exoskeleton:OnIntervalThink()
    if IsServer() then
            --print("shell following")
            local caster = self:GetParent()
            local ability = self:GetAbility()

        if not caster.shell:IsNull() then
            local point = caster:GetAbsOrigin() 
            local fv = (caster:GetForwardVector())
            caster.shell:SetAbsOrigin((point + Vector(0,0,25))-fv*1)
            caster.shell:SetForwardVector(-(fv-(Vector(0,-10,0):Normalized())))--Vector(-fv.x, -fv.y,0))

            if not caster.vision_checker then
                local team = caster:GetTeamNumber()
                local panic = 0
                --set vision dummy to the opposite team. If there are more than two teams, do not spawn a vision dummy. 
                if team == 2 then
                    team = 3
                else
                    if team == 3 then
                        team = 2
                    else
                        panic = 1
                    end
                end
                --create vision dummy if there are just two teams. 
                if panic == 0 then
                    caster.vision_checker = CreateUnitByName("eye_of_the_moon_dummy", Vector(0, 0, 0), false, caster, caster, team)
                    print("Vision checker made by "..caster:GetName().." created on team "..team..".")
                else
                    print("Vision checker has failed due to the team being '"..team.."'.")
                end
            end
            local see_caster = caster.vision_checker:CanEntityBeSeenByMyTeam(caster)
            if not see_caster then
                ability:ApplyDataDrivenModifier(caster, caster.shell, "modifier_invisible_broom", { duration = 0.01 })
            end

        end
    end
end

function modifier_exoskeleton:GetModifierMoveSpeedBonus_Constant ()
    return self:GetAbility():GetSpecialValueFor("slow")
end

function modifier_exoskeleton:GetModifierTurnRate_Percentage ()
    return self:GetAbility():GetSpecialValueFor("turn")

end

function modifier_exoskeleton:GetModifierMagicalResistanceBonus ()
    return self.resist
end

function modifier_exoskeleton:GetModifierPhysicalArmorBonus ()
    return self.armor
end


function modifier_exoskeleton:OnDestroy( kv )   
    if IsServer() then
        local RemovePositiveBuffs = false
        local RemoveDebuffs = true
        local BuffsCreatedThisFrameOnly = false
        local RemoveStuns = true
        local RemoveExceptions = false
        self:GetParent():Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
        --self:GetParent():RemoveModifierByName("modifier_exoskeleton_shell")
    end
end

function modifier_exoskeleton:IsHidden() 
	return false
end