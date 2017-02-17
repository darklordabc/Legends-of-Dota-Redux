if spell_lab_symbiotic_target == nil then
	spell_lab_symbiotic_target = class({})
end

function spell_lab_symbiotic_target:OnCreated( kv )
	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle("particles/spell_lab/symbiotic_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
		self:AddParticle( self.nFXIndex, false, false, -1, false, true )

	end
end

function spell_lab_symbiotic_target:OnDestroy()
	if IsServer() then
	end
end

function spell_lab_symbiotic_target:InitSymbiot (hModifier,hSymbiot)
	if IsServer() then
		self.hSymbiot = hSymbiot
		self.hMod = hModifier
	end
end

function spell_lab_symbiotic_target:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_DEATH--[[]]--
		,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
		--]]--
	}
	return funcs
end

function spell_lab_symbiotic_target:IsHidden()
	return false
end

function spell_lab_symbiotic_target:OnDeath (kv)
	if IsServer() then
  if kv.unit ~= self:GetParent() then return end
  if self.hMod ~= nil then
    self.hMod:Terminate(kv.attacker)
  end
end
end
function spell_lab_symbiotic_target:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function spell_lab_symbiotic_target:AllowIllusionDuplicate()
	return false
end

function spell_lab_symbiotic_target:GetModifierBonusStats_Strength()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus")
	end
end
function spell_lab_symbiotic_target:GetModifierBonusStats_Agility()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus")
	end
end
function spell_lab_symbiotic_target:GetModifierBonusStats_Intellect()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("bonus")
	end
end
