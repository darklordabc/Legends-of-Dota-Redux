if spell_reflect_mod == nil then
	spell_reflect_mod = class({})
end

function spell_reflect_mod:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_REFLECT_SPELL
	}
	return funcs
end

function spell_reflect_mod:IsHidden()
	return true
end

function spell_reflect_mod:GetReflectSpell(keys)
	if IsServer() then
		local hAbility = self:GetAbility()
		if hAbility:GetLevel() < 1 then return false end
		if keys.ability:GetCaster():GetTeam() == self:GetCaster():GetTeam() then return false end
		if hAbility:IsCooldownReady() then
			hAbility:StartCooldown(hAbility:GetTrueCooldown(hAbility:GetLevel()))
			self:Reflect(keys)
		end
		return 1
	end
end

function spell_reflect_mod:Reflect (kv)
	if self.stored ~= nil then
		self.stored:RemoveSelf()
	end
	local hCaster = self:GetParent()
	local hAbility = hCaster:AddAbility(kv.ability:GetAbilityName())
	hAbility:SetStolen(true)
	hAbility:SetHidden(true)
	hAbility:SetLevel(kv.ability:GetLevel())
	hCaster:SetCursorCastTarget(kv.ability:GetCaster())
	hAbility:OnSpellStart()
	self.stored = hAbility
end
