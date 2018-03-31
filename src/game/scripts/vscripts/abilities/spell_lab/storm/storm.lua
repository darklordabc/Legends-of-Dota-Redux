if spell_lab_storm_modifier == nil then
	spell_lab_storm_modifier = class({})
end

function spell_lab_storm_modifier:OnCreated(kv)
		if IsServer() then
      self.stacks = {}
      self.storm = 0
		end
end

function spell_lab_storm_modifier:IsPermanent() return true end
function spell_lab_storm_modifier:IsHidden() return self:GetStackCount() < 1 end

function spell_lab_storm_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
	return funcs
end

function spell_lab_storm_modifier:OnAbilityExecuted (kv)
	if IsServer() then
    if kv.ability:GetCaster() ~= self:GetParent() then return end
    if kv.ability:IsItem() then return end
    if kv.ability:IsToggle() then return end
    if kv.ability:GetCooldown(kv.ability:GetLevel()) < 0.5 then return end
    if kv.ability == self:GetAbility() then
      self.storm = self:GetStackCount()
      self.target = kv.ability:GetCursorTarget()
      self.point = kv.ability:GetCursorPosition()
    end
    table.insert(self.stacks,GameRules:GetGameTime()+3)
		self:SetDuration( 3, true )
    local bStart = self:GetStackCount() < 1
    self:IncrementStackCount()
    if bStart then self:StartIntervalThink(0.25) end
  end
end

function spell_lab_storm_modifier:OnIntervalThink()
	if IsServer() then
    if self.storm > 0 then
      self.storm = self.storm - 1
      if self.target ~= nil then
        self:GetParent():SetCursorCastTarget(self.target)
      else
        self:GetParent():SetCursorPosition(self.point)
      end
      self:GetAbility():OnSpellStart()
    end
    if #self.stacks > 0 then
      if self.stacks[1] ~= nil and self.stacks[1] < GameRules:GetGameTime() then
        table.remove(self.stacks,1)
        self:DecrementStackCount()
      end
    end
    if self:GetStackCount() < 1 and self.storm < 1 then self:StartIntervalThink(-1) end
	end
end

function spell_lab_storm_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE
end

function spell_lab_storm_modifier:DestroyOnExpire()
	return false
end
