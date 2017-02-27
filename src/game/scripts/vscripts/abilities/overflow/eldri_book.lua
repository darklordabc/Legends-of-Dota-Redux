if book_eldri_modifier == nil then
	book_eldri_modifier = class({})
end

function book_eldri_modifier:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_SPENT_MANA,
	MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
	return funcs
end

function book_eldri_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function book_eldri_modifier:OnCreated( kv )
	if IsServer() then
		self:SetStackCount(kv.stacks)
	end
end

function book_eldri_modifier:OnRefresh( kv )
	if IsServer() then
		local stacks = self:GetStackCount() + kv.stacks
		self:SetStackCount(stacks)
	end
end

function book_eldri_modifier:OnSpentMana(kv)
	if IsServer() then
		if kv.unit == self:GetParent() then
			local damage = {
				attacker = self:GetParent(),
				damage = kv.cost*self:GetStackCount()*0.05,
				damage_type = DAMAGE_TYPE_MAGICAL,
				ability = kv.ability,
				victim = self:GetParent()
			}
			ApplyDamage( damage )
		end
	end
end

function book_eldri_modifier:OnAbilityExecuted(keys)
	if IsServer() then
			if keys.caster ~= nil then return end
			if keys.caster == self:GetParent() then return end
			if keys.ability ~= nil and keys.ability.GetManaCost ~= nil and keys.ability.GetLevel ~= nil then
				self:GetParent():GiveMana(keys.ability:GetManaCost(keys.ability:GetLevel())*self:GetStackCount()*0.05)
			end
	end
end

function book_eldri_modifier:GetOverrideAttackMagical()
	return 1
end

function book_eldri_modifier:GetTexture()
	return "elder_god"
end
function book_eldri_modifier:IsHidden()
	return false
end
