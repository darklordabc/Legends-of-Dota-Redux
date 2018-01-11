mifune_bushido = class({})

LinkLuaModifier("modifier_bushido","abilities/dusk/mifune_bushido",LUA_MODIFIER_MOTION_NONE)

function mifune_bushido:OnSpellStart()
	local caster = self:GetCaster()
	local mod = "modifier_bushido"
	local duration = self:GetSpecialValueFor("duration")

	-- Sound

	caster:AddNewModifier(caster, self, mod, {Duration=duration})
end

modifier_bushido = class({})

function modifier_bushido:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		-- MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		-- MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function modifier_bushido:GetEffectName()
	return "particles/units/heroes/hero_mifune/bushido_unit.vpcf"
end

if IsServer() then

	function modifier_bushido:OnCreated()
		local agi = self:GetParent():GetBaseAgility()
		local pct = self:GetAbility():GetSpecialValueFor("percent")/100

		self:SetStackCount(math.floor(agi*pct))
	end

	-- function modifier_bushido:OnAttacked(params)
	-- 	local p = self:GetParent()
	-- 	local a = params.attacker
	-- 	local t = params.target

	-- 	if t ~= p then return end

	-- 	a:EmitSound("Hero_Juggernaut.OmniSlash")
	-- 	-- Particle

	-- 	-- p:PerformAttack(
	-- 	-- 	a,
	-- 	-- 	true,
	-- 	-- 	true,
	-- 	-- 	true,
	-- 	-- 	false,
	-- 	-- 	false,
	-- 	-- 	false,
	-- 	-- 	true
	-- 	-- )
	-- end

end

function modifier_bushido:GetModifierBonusStats_Agility()
	if self:GetStackCount() > 0 then
		return self:GetStackCount()
	end
end

-- function modifier_bushido:GetModifierBaseAttackTimeConstant()
-- 	return self:GetAbility():GetSpecialValueFor("base_attack_time")
-- end

function modifier_bushido:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end