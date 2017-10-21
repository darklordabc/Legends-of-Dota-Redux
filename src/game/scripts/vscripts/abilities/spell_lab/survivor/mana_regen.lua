if spell_lab_survivor_mana_regen == nil then
	spell_lab_survivor_mana_regen = class({})
end

LinkLuaModifier("spell_lab_survivor_mana_regen_modifier", "abilities/spell_lab/survivor/mana_regen.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_mana_regen:GetIntrinsicModifierName() return "spell_lab_survivor_mana_regen_modifier" end


if spell_lab_survivor_mana_regen_modifier == nil then
	spell_lab_survivor_mana_regen_modifier = class({})
end

function spell_lab_survivor_mana_regen_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_mana_regen_modifier:GetModifierConstantManaRegen()
if self:GetParent():PassivesDisabled() then return 0 end
return self:GetStackCount()
end

function spell_lab_survivor_mana_regen_modifier:OnDeath(kv)
  if IsServer() then
	  if kv.unit == self:GetParent() and not kv.unit:IsAlive() and not kv.unit:IsReincarnating() then
      self.lastdeath = GameRules:GetGameTime()
    end
  end
end

function spell_lab_survivor_mana_regen_modifier:IsHidden()
	return self:GetStackCount() < 1
end

function spell_lab_survivor_mana_regen_modifier:AllowIllusionDuplicate ()
  return false
end
function spell_lab_survivor_mana_regen_modifier:IsPurgable()
	return false
end

function spell_lab_survivor_mana_regen_modifier:OnCreated()
	if IsServer() then
		self.lastdeath = GameRules:GetGameTime()
		if not self:GetParent():IsRealHero() then
  local hOwner = self:GetParent():GetOwner()
  if hOwner ~= nil then
    local hOriginModifier = hOwner:GetAssignedHero():FindModifierByName("spell_lab_survivor_mana_regen_modifier")
    if hOriginModifier ~= nil then
      self:SetStackCount(hOriginModifier:GetStackCount())
    end
  end
end
		self:StartIntervalThink( 1 )
	end
end

function spell_lab_survivor_mana_regen_modifier:OnIntervalThink()
	if IsServer() then
		if not self:GetParent():IsRealHero() then
			self:StartIntervalThink( -1 )
			return
		end
    if not self:GetParent():IsAlive() and not self:GetParent():IsReincarnating() then
  		self.lastdeath = GameRules:GetGameTime()
  		self:SetStackCount(0)
      return
    end
  	if self:GetAbility():GetLevel() > 0 then
      local stacks = (GameRules:GetGameTime() - self.lastdeath)*self:GetAbility():GetSpecialValueFor("bonus")*0.0166667
  		self:SetStackCount(stacks)
  	end
	end
end

function spell_lab_survivor_mana_regen_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
