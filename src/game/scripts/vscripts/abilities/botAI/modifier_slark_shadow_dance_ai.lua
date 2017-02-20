--Taken from the spelllibrary, credits go to valve

modifier_slark_shadow_dance_ai = class({})


--------------------------------------------------------------------------------

function modifier_slark_shadow_dance_ai:IsHidden()
    return true
end

--------------------------------------------------------------------------------

function modifier_slark_shadow_dance_ai:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function modifier_slark_shadow_dance_ai:DeclareFunctions()
local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_slark_shadow_dance_ai:OnTakeDamage()
	local caster = self:GetParent()
	local ability = caster:FindAbilityByName("slark_shadow_dance")
	
	if caster:GetHealth() < 400 and ability and ability:IsFullyCastable() and caster:IsRealHero() and not (caster:IsStunned() or caster:IsSilenced())  then
		local cooldown = ability:GetCooldown( ability:GetLevel() )
		caster:CastAbilityImmediately(ability, caster:GetPlayerOwnerID())
		ability:StartCooldown( cooldown )
		caster:EmitSound("Hero_Slark.ShadowDance")
	end
end

