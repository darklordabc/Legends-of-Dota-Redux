if spell_lab_survivor_mana_burn == nil then
	spell_lab_survivor_mana_burn = class({})
end

LinkLuaModifier("spell_lab_survivor_mana_burn_modifier", "abilities/spell_lab/survivor/mana_burn.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_mana_burn:GetIntrinsicModifierName() return "spell_lab_survivor_mana_burn_modifier" end


if spell_lab_survivor_mana_burn_modifier == nil then
	spell_lab_survivor_mana_burn_modifier = class({})
end

function spell_lab_survivor_mana_burn_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function spell_lab_survivor_mana_burn_modifier:OnAttackLanded(keys)
	if IsServer() then
		local hAbility = self:GetAbility()
		if self:GetParent():PassivesDisabled() then return 0 end
		if hAbility:GetLevel() < 1 then return end
		if keys.attacker == self:GetParent() then
			local mana = keys.target:GetMana()
			keys.target:ReduceMana(self:GetStackCount())
			mana = mana-keys.target:GetMana()

			if (mana > 1) then
				local damage = {
					victim = keys.target,
					attacker = keys.attacker,
					damage = mana*hAbility:GetSpecialValueFor("damage_pct")*0.01,
					damage_type = DAMAGE_TYPE_PHYSICAL,
					ability = hAbility
				}
				EmitSoundOnLocationWithCaster( keys.target:GetAbsOrigin(), "Hero_Antimage.ManaBreak", self:GetParent() )
				local nFXIndex = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ROOTBONE_FOLLOW, keys.target)
				ParticleManager:ReleaseParticleIndex(nFXIndex)
				ApplyDamage(damage)
			end
		end
	end
end

function spell_lab_survivor_mana_burn_modifier:OnDeath(kv)
  if IsServer() then
	  if kv.unit == self:GetParent() and not kv.unit:IsAlive() and not kv.unit:IsReincarnating() then
      self.lastdeath = GameRules:GetGameTime()
    end
  end
end

function spell_lab_survivor_mana_burn_modifier:IsHidden()
	return self:GetStackCount() < 1
end

function spell_lab_survivor_mana_burn_modifier:AllowIllusionDuplicate ()
  return true
end
function spell_lab_survivor_mana_burn_modifier:IsPurgable()
	return false
end

function spell_lab_survivor_mana_burn_modifier:OnCreated()
	if IsServer() then
		self.lastdeath = GameRules:GetGameTime()
			if not self:GetParent():IsRealHero() then
				local hOwner = self:GetParent():GetOwner()
				if hOwner ~= nil then
					local hOriginModifier = hOwner:GetAssignedHero():FindModifierByName("spell_lab_survivor_mana_burn_modifier")
					if hOriginModifier ~= nil then
						self:SetStackCount(hOriginModifier:GetStackCount())
					end
				end
			end
		--self:SetStackCount(0)
		self:StartIntervalThink( 1 )
	end
end

function spell_lab_survivor_mana_burn_modifier:OnIntervalThink()
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

function spell_lab_survivor_mana_burn_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
