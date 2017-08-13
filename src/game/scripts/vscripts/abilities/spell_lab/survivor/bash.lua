if spell_lab_survivor_bash == nil then
	spell_lab_survivor_bash = class({})
end

LinkLuaModifier("spell_lab_survivor_bash_modifier", "abilities/spell_lab/survivor/bash.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "generic_lua_stun", "abilities/overflow/generic_stun.lua", LUA_MODIFIER_MOTION_NONE )

function spell_lab_survivor_bash:GetIntrinsicModifierName() return "spell_lab_survivor_bash_modifier" end


if spell_lab_survivor_bash_modifier == nil then
	spell_lab_survivor_bash_modifier = class({})
end

function spell_lab_survivor_bash_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_bash_modifier:OnAttackLanded(keys)
		if IsServer() then
			local hAbility = self:GetAbility()
			if self:GetParent():PassivesDisabled() then return end
			if hAbility:GetLevel() < 1 then return end
			if keys.attacker == self:GetParent() and not keys.target:IsBuilding() and not keys.target:IsOther() and not self:GetParent():IsIllusion() and hAbility:IsCooldownReady() then
					local chance = self:GetStackCount()
					if (math.random(0,100) > chance) then return end
	 	 			local stun_dur = hAbility:GetSpecialValueFor("duration")
					keys.target:AddNewModifier( self:GetCaster(), self, "generic_lua_stun", { duration = stun_dur , stacking = 0 } )
					EmitSoundOnLocationWithCaster( self:GetParent():GetAbsOrigin(), "DOTA_Item.SkullBasher", self:GetParent() )
					hAbility:StartCooldown(hAbility:GetTrueCooldown(hAbility:GetLevel()))
			end
		end
--return self:GetStackCount()
end

function spell_lab_survivor_bash_modifier:OnDeath(kv)
  if IsServer() then
	  if kv.unit == self:GetParent() and not kv.unit:IsAlive() and not kv.unit:IsReincarnating() then
      self.lastdeath = GameRules:GetGameTime()
    end
  end
end

function spell_lab_survivor_bash_modifier:IsHidden()
	return self:GetStackCount() < 1
end

function spell_lab_survivor_bash_modifier:AllowIllusionDuplicate ()
  return false
end
function spell_lab_survivor_bash_modifier:IsPurgable()
	return false
end

function spell_lab_survivor_bash_modifier:OnCreated()
	if IsServer() then
		self.lastdeath = GameRules:GetGameTime()
		if not self:GetParent():IsRealHero() then
  local hOwner = self:GetParent():GetOwner()
  if hOwner ~= nil then
    local hOriginModifier = hOwner:GetAssignedHero():FindModifierByName("spell_lab_survivor_bash_modifier")
    if hOriginModifier ~= nil then
      self:SetStackCount(hOriginModifier:GetStackCount())
    end
  end
end
		self:StartIntervalThink( 1 )
	end
end

function spell_lab_survivor_bash_modifier:OnIntervalThink()
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

function spell_lab_survivor_bash_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
