if spell_lab_way_of_hel == nil then
	spell_lab_way_of_hel = class({})
end

modifier_basic_mana_bonus = class({})
LinkLuaModifier("spell_lab_way_of_hel_modifier","abilities/spell_lab/own/flip.lua",LUA_MODIFIER_MOTION_NONE)

function spell_lab_way_of_hel:GetIntrinsicModifierName()
 return "spell_lab_way_of_hel_modifier"
end

function spell_lab_way_of_hel:OnSpellStart()
	local nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/one_with_nothing.vpcf", PATTACH_ABSORIGIN, self:GetCaster() )
	ParticleManager:SetParticleControl( nFXIndex, 0,self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl( nFXIndex, 3,self:GetCaster():GetAbsOrigin())
  EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "n_creep_SatyrTrickster.Cast", self:GetCaster())
  local hMod = self:GetCaster():FindModifierByName("spell_lab_way_of_hel_modifier")
  if hMod ~= nil and hMod.Flip ~= nil then
     hMod:Flip()
  end
end

if spell_lab_way_of_hel_modifier == nil then
	spell_lab_way_of_hel_modifier = class({})
end

function spell_lab_way_of_hel_modifier:OnCreated(kv)
  self.positive = true
	self.flipped = false
  self:SetStackCount(0)
end

function spell_lab_way_of_hel_modifier:Flip()
	local hParent = self:GetParent()
	local fHealth = hParent:GetHealth()
	local fMana = hParent:GetMana()
	if (self.flipped) then
		self.flipped = false
		self:SetStackCount(0)
	  hParent:CalculateStatBonus()
	else
		self.flipped = true
	  local fMaxHealth = hParent:GetMaxHealth()
	  local fMaxMana= hParent:GetMaxMana()
	  self.positive = (fMaxHealth > fMaxMana)
	  if self.positive then
	    self:SetStackCount(fMaxMana-fMaxHealth)
	  else
	    self:SetStackCount(fMaxHealth-fMaxMana)
	  end
	  hParent:CalculateStatBonus()
	end
	hParent:SetHealth(fMana)
	hParent:SetMana(fHealth)
	if (fMana <= 0) then
		hParent:Kill(self:GetAbility(),hParent)
	end
end



function spell_lab_way_of_hel_modifier:IsPermanent() return true end
function spell_lab_way_of_hel_modifier:IsHidden() return true end

function spell_lab_way_of_hel_modifier:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_HEALTH_BONUS}
end

function spell_lab_way_of_hel_modifier:GetModifierManaBonus()
  if self.positive then
  	return self:GetStackCount()*-1
  end
  return self:GetStackCount()
end

function spell_lab_way_of_hel_modifier:GetModifierHealthBonus()
  if self.positive then
  	return self:GetStackCount()
  end
  return self:GetStackCount()*-1
end

function spell_lab_way_of_hel_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function spell_lab_way_of_hel_modifier:AllowIllusionDuplicate()
  return true
end
function spell_lab_way_of_hel_modifier:IsPurgable()
	return false
end
