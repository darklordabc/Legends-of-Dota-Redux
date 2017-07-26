if spell_lab_survivor_int_survival == nil then
	spell_lab_survivor_int_survival = class({})
end

LinkLuaModifier("spell_lab_survivor_int_survival_modifier", "abilities/spell_lab/survivor/int_survival.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_int_survival:GetIntrinsicModifierName() return "spell_lab_survivor_int_survival_modifier" end


if spell_lab_survivor_int_survival_modifier == nil then
	spell_lab_survivor_int_survival_modifier = class({})
end

function spell_lab_survivor_int_survival_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_int_survival_modifier:GetModifierBonusStats_Intellect()
return self:GetStackCount()
end

function spell_lab_survivor_int_survival_modifier:OnDeath(kv)
  if IsServer() then
	  if kv.unit == self:GetParent() and not kv.unit:IsAlive() and not kv.unit:IsReincarnating() then
      self.lastdeath = GameRules:GetGameTime()
    end
  end
end

function spell_lab_survivor_int_survival_modifier:IsHidden()
	if self:GetAbility():GetLevel() > 0 then
	   return false
	end
	return true
end

function spell_lab_survivor_int_survival_modifier:AllowIllusionDuplicate ()
  return false
end
function spell_lab_survivor_int_survival_modifier:IsPurgable()
	return false
end

function spell_lab_survivor_int_survival_modifier:OnCreated()
	if IsServer() then
		self.lastdeath = GameRules:GetGameTime()
		self:SetStackCount(0)
		self:StartIntervalThink( 1 )
	end
end

function spell_lab_survivor_int_survival_modifier:OnIntervalThink()
	if IsServer() then
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

function spell_lab_survivor_int_survival_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
