--Taken from the spelllibrary, credits go to valve

modifier_alchemist_chemical_rage_ai = class({})


--------------------------------------------------------------------------------

function modifier_alchemist_chemical_rage_ai:IsHidden()
    return true
end

--------------------------------------------------------------------------------

function modifier_alchemist_chemical_rage_ai:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function modifier_alchemist_chemical_rage_ai:DeclareFunctions()
local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
    return funcs
end

function modifier_alchemist_chemical_rage_ai:OnTakeDamage()
	local caster = self:GetParent()
	local ability = caster:FindAbilityByName("alchemist_chemical_rage")
	
	if caster:GetHealthPercent() < 90 and ability and ability:IsFullyCastable() and not caster:IsChanneling() and caster:IsRealHero() and not (caster:IsStunned() or caster:IsSilenced()) then
		local cooldown = ability:GetCooldown( ability:GetLevel() )
		caster:CastAbilityImmediately(ability, caster:GetPlayerOwnerID())
		ability:StartCooldown( cooldown )
		caster:EmitSound("Hero_Alchemist.ChemicalRage.Cast")
	end
end

