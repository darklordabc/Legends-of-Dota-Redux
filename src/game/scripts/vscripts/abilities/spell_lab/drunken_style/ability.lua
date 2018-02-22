if spell_lab_drunken_style == nil then
	spell_lab_drunken_style = class({})
end

LinkLuaModifier("spell_lab_drunken_style_modifier", "abilities/spell_lab/drunken_style/ability.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_drunken_style:GetIntrinsicModifierName() return "spell_lab_drunken_style_modifier" end

function spell_lab_drunken_style:OnUpgrade()
  if self.loaded == nil then
    self.stages = {}
    self.stages[1] = self.DoBash
    self.stages[2] = self.DoBackBlink
    self.stages[3] = self.DoRandomBlink
    self.stages[4] = self.DoTrueStrike
    self.textures[1] = "spell_lab_drunken_style_bash"
    self.textures[2] = "spell_lab_drunken_style_back_blink"
    self.textures[3] = "spell_lab_drunken_style_rand_blink"
    self.textures[4] = "spell_lab_drunken_style_true_strike"
    self.stage = RandomInt(1,#self.stages)
    self.loaded = true
  end
end

function spell_lab_drunken_style:DoAttackEffect(target)
  if (self:IsCooldownReady()) then
    if (self.loaded == nil) then
      print("drunken_style debug: settings were not loaded by OnUpgrade")
      self:LoadSettings()
    end
    self.stages[self.stage](target)
    self.stage = RandomInt(1,#self.stages)
  end
end

function spell_lab_drunken_style:GetAbilityTextureName()
  return self.textures[self.stages]
end


if spell_lab_drunken_style_modifier == nil then
	spell_lab_drunken_style_modifier = class({})
end

function spell_lab_drunken_style_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}
	return funcs
end

function spell_lab_drunken_style_modifierOnAttack(keys)
	if IsServer() then
		local hAbility = self:GetAbility()
		if self:GetParent():PassivesDisabled() then return end
		if hAbility:GetLevel() < 1 then return end
		if keys.attacker == self:GetParent() and not self:GetParent():IsIllusion() then
      hAbility:DoAttackEffect(keys.unit)
		end
	end
end

function spell_lab_drunken_style_modifier:IsHidden()
	return true
end

function spell_lab_drunken_style_modifier:AllowIllusionDuplicate ()
  return false
end
function spell_lab_drunken_style_modifier:IsPurgable()
	return false
end

function spell_lab_drunken_style_modifier:OnCreated()
	if IsServer() then
	end
end

function spell_lab_drunken_style_modifier:OnIntervalThink()
	if IsServer() then
	end
end

function spell_lab_drunken_style_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
