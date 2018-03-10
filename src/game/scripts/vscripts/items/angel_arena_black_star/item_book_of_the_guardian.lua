LinkLuaModifier("modifier_item_book_of_the_guardian", "items/angel_arena_black_star/item_book_of_the_guardian.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_book_of_the_guardian_effect", "items/angel_arena_black_star/item_book_of_the_guardian.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_book_of_the_guardian_blast", "items/angel_arena_black_star/item_book_of_the_guardian.lua", LUA_MODIFIER_MOTION_NONE)
item_book_of_the_guardian_baseclass = {
	GetIntrinsicModifierName = function() return "modifier_item_book_of_the_guardian" end
}

if IsServer() then
	function item_book_of_the_guardian_baseclass:OnSpellStart()
		local caster = self:GetCaster()
		local blast_radius = self:GetAbilitySpecial("blast_radius")
		local blast_speed = self:GetAbilitySpecial("blast_speed")
		local blast_damage_int_mult = self:GetSpecialValueFor("blast_damage_int_mult")
		local blast_debuff_duration = self:GetSpecialValueFor("blast_debuff_duration")
		local blast_vision_duration = self:GetSpecialValueFor("blast_vision_duration")
		local startTime = GameRules:GetGameTime()
		local affectedUnits = {}

		local pfx = ParticleManager:CreateParticle("particles/econ/events/ti7/shivas_guard_active_ti7.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(pfx, 1, Vector(blast_radius, blast_radius / blast_speed * 1.5, blast_speed))
		caster:EmitSound("DOTA_Item.ShivasGuard.Activate")

		Timers:CreateTimer(function()
			local now = GameRules:GetGameTime()
			local elapsed = now - startTime
			local abs = caster:GetAbsOrigin()
			self:CreateVisibilityNode(abs, blast_radius, blast_vision_duration)

			for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), abs, nil, elapsed * blast_speed, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
				if not affectedUnits[v] then
					affectedUnits[v] = true
					ApplyDamage({
						attacker = caster,
						victim = v,
						damage = caster:GetIntellect() * blast_damage_int_mult,
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
						ability = self
					})

					local impact_pfx = ParticleManager:CreateParticle("particles/econ/events/ti7/shivas_guard_impact_ti7.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
					ParticleManager:SetParticleControlEnt(impact_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
					v:AddNewModifier(caster, self, "modifier_item_book_of_the_guardian_blast", {duration = blast_debuff_duration})
				end
			end
			if elapsed * blast_speed < blast_radius then
				return 0.1
			end
		end)
	end
end

item_book_of_the_guardian = class(item_book_of_the_guardian_baseclass)


modifier_item_book_of_the_guardian = class({
	IsHidden      = function() return true end,
	IsAura        = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
})

function modifier_item_book_of_the_guardian:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_item_book_of_the_guardian:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_book_of_the_guardian:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_book_of_the_guardian:GetModifierPercentageManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_book_of_the_guardian:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_book_of_the_guardian:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp_pct")
end

function modifier_item_book_of_the_guardian:GetModifierAura()
	return "modifier_item_book_of_the_guardian_aura"
end

function modifier_item_book_of_the_guardian:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_book_of_the_guardian:GetAuraDuration()
	return 0.5
end

function modifier_item_book_of_the_guardian:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_item_book_of_the_guardian:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end


modifier_item_book_of_the_guardian_aura = class({
	IsPurgable = function() return false end,
})

function modifier_item_book_of_the_guardian_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_item_book_of_the_guardian_aura:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("aura_attack_speed")
end


modifier_item_book_of_the_guardian_blast = class({
	GetEffectName = function() return "particles/econ/events/ti7/shivas_guard_slow.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
})

function modifier_item_book_of_the_guardian_blast:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_item_book_of_the_guardian_blast:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("blast_movement_speed_pct")
end
