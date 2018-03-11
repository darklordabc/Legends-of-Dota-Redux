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

function spell_lab_symbiotic_target:InitSymbiot (hModifier)
	if IsServer() then
		self.symbiot = hModifier
		self.maxdistance = hModifier:GetAbility():GetSpecialValueFor("range_scepter")
	end
end


function spell_lab_symbiotic_target:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_DEATH--[[]]--
		,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
		--]]--
	}
	return funcs
end

function spell_lab_symbiotic_target:IsHidden()
	return false
end

function spell_lab_symbiotic_target:OnDeath (kv)
	if IsServer() then
	  if kv.unit == self:GetParent() then
		  if self.symbiot ~= nil then
		    self.symbiot:Terminate(kv.attacker)
		  end
		return end
		if not self:GetParent():IsRealHero() then
			return end
		--local stat = kv.unit:GetPrimaryAttribute()
		if not self:GetCaster():HasScepter() then
			 return end
		if kv.unit:IsRealHero() and kv.unit:GetTeam() ~= self:GetParent():GetTeam() then
			local dist = CalcDistanceBetweenEntityOBB(kv.unit, self:GetParent())
			if dist > self.maxdistance then return end
			local amount = self.symbiot:GetAbility():GetSpecialValueFor("stat_scepter")
				--TODO: Make over head alerts right... they might be float values so these commented functions won't work.
			--if stat == 0 then
			self:GetParent():ModifyStrength(amount)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, self:GetParent(), amount, nil)
		--	elseif stat == 1 then
			self:GetParent():ModifyAgility(amount)
		--	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetParent(), amount, nil)
		--	elseif stat == 2 then
			self:GetParent():ModifyIntellect(amount)
			self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"spell_lab_symbiotic_bonus",{stacks=amount})
		--	SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self:GetParent(), amount, nil)
			--end
		end
	end
end

function spell_lab_symbiotic_target:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function spell_lab_symbiotic_target:Show (time)
	if self:GetParent():IsInvisible() then
		self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_item_dustofappearance",{duration = time})
	end
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

function spell_lab_symbiotic_target:GetModifierPercentageManaRegen ()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("mana_regen")
	end
end

function spell_lab_symbiotic_target:GetModifierPhysicalArmorBonus ()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("physical_armor")
	end
end
function spell_lab_symbiotic_target:GetModifierMagicalResistanceBonus ()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("magic_armor")
	end
end
