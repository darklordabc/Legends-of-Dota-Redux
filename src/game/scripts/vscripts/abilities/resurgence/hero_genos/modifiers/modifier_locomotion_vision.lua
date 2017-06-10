--[[Author: TheGreatGimmick
    Date: May 15, 2017
    Modifier that switches dummy items for the real one]]

modifier_locomotion_vision = class({}) 

--[[
function modifier_locomotion_vision:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, 
    }

	return funcs
end
]]

function modifier_locomotion_vision:OnCreated( kv )   
    if IsServer() then
        print("")
    	print('Leap vision modifier begun')
        self:StartIntervalThink(0.01)
    end
end

function modifier_locomotion_vision:OnIntervalThink()
    if IsServer() then
    	local caster = self:GetParent()
        local ability = caster:FindAbilityByName("genos_flight_instinct")

        local ability_level = ability:GetLevel() - 1

        local direction = caster:GetForwardVector()
        local point = caster:GetAbsOrigin()
        --local length = ability:GetLevelSpecialValueFor("visiond", ability_level) + (caster:FindModifierByName("modifier_flight_instinct_adaptations"):GetStackCount())*500
        local length = ability:GetLevelSpecialValueFor("visiond", ability_level) + caster.flight_instinct_adaptations*500
        local width = ability:GetLevelSpecialValueFor("visionw", ability_level)

        local separation = 50

        for i = 0, length, separation do 
            local vision_point = point + i*direction
            AddFOWViewer(caster:GetTeamNumber(), vision_point, width, 0.01, false)
        end

    end
end

function modifier_locomotion_vision:OnDestroy( kv )   
    if IsServer() then
        print("")
        print('Leap vision modifier ended')
        local caster = self:GetParent()
        local ability = caster:FindAbilityByName("genos_flight_instinct")

        local ability_level = ability:GetLevel() - 1

        local direction = caster:GetForwardVector()
        local point = caster:GetAbsOrigin()
        local length = ability:GetLevelSpecialValueFor("visiond", ability_level) + (caster:FindModifierByName("modifier_flight_instinct_adaptations"):GetStackCount())*500
        local width = ability:GetLevelSpecialValueFor("visionw", ability_level)

        local separation = 50

        for i = 0, length, separation do 
            local vision_point = point + i*direction
            AddFOWViewer(caster:GetTeamNumber(), vision_point, width, 0.3, false)
        end

    end
end

function modifier_locomotion_vision:IsHidden() 
	return true
end