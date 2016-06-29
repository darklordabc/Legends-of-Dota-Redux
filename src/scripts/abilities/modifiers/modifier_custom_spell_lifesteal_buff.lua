modifier_custom_spell_lifesteal_buff = class({})

--------------------------------------------------------------------------------
function modifier_custom_spell_lifesteal_buff:DeclareFunctions(params)
local funcs = {
	MODIFIER_EVENT_ON_TAKEDAMAGE,
	MODIFIER_PROPERTY_TOOLTIP
	}
	return funcs
end

function modifier_custom_spell_lifesteal_buff:IsHidden()
	if self:GetAbility():GetLevel() == 0 then
		return true
	end
	return false
end

function modifier_custom_spell_lifesteal_buff:IsBuff()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return true
	end

	return false
end

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_buff:OnCreated( kv )
	self.hero_lifesteal = self:GetAbility():GetSpecialValueFor( "hero_lifesteal" )
	self.creep_lifesteal = self:GetAbility():GetSpecialValueFor( "creep_lifesteal" )
end

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_buff:OnRefresh( kv )
	self.hero_lifesteal = self:GetAbility():GetSpecialValueFor( "hero_lifesteal" )
	self.creep_lifesteal = self:GetAbility():GetSpecialValueFor( "creep_lifesteal" )
end
--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_buff:OnTooltip( params )
	return self.hero_lifesteal
end

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_buff:OnTakeDamage(params)
	local hero = self:GetParent()
	local dmg = params.damage
	local nHeroHeal = self.hero_lifesteal / 100
	local nCreepHeal = self.creep_lifesteal / 100
	if params.inflictor then
		if params.attacker == hero then
			local heal_amount = 0
			if params.unit:IsCreep() then
				heal_amount = dmg * nCreepHeal 
			elseif params.unit:IsHero() then
				if params.unit ~= hero then
				heal_amount = dmg * nHeroHeal
				end
			end
			if heal_amount > 0 and hero:GetHealth() ~= hero:GetMaxHealth() then
				local healthCalculated = hero:GetHealth() + heal_amount
				hero:Heal(heal_amount, self:GetAbility())
				ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf",PATTACH_ABSORIGIN_FOLLOW, hero)
			end
		end
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

