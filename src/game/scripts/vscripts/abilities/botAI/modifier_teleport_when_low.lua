modifier_teleport_when_low = class({})
local Timers = require('easytimers')

--------------------------------------------------------------------------------

function modifier_teleport_when_low:IsHidden()
    return false
end

--------------------------------------------------------------------------------

function modifier_teleport_when_low:RemoveOnDeath()
    return true
end
-------------------------------------------------------------------------------------------
function modifier_teleport_when_low:GetTexture()
	return "sven_warcry"
end
--------------------------------------------------------------------------------------------------------
function modifier_teleport_when_low:IsPurgable()
	return false
end
--------------------------------------------------------------------------------
function modifier_teleport_when_low:DeclareFunctions()
local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_teleport_when_low:OnTakeDamage()
	local caster = self:GetParent()
	
	if caster:GetHealth() < 200 and caster:IsRealHero() and not caster:HasModifier("modifier_chen_test_of_faith_teleport") then
		caster:AddNewModifier(caster, ability, "modifier_chen_test_of_faith_teleport", {duration = 5})
		Timers:CreateTimer(function ()
			if IsValidEntity(caster) and caster:IsAlive() then
            	caster:SetHealth(caster:GetMaxHealth())
				caster:SetMana(caster:GetMaxMana())
           	end
        end, DoUniqueString('regen'), 5.5)

        
	end
		
		

end

