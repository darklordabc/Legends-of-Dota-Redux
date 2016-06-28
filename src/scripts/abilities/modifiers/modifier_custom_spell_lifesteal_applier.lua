modifier_custom_spell_lifesteal_applier = class({})

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_applier:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_applier:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_applier:GetModifierAura()
	return "modifier_custom_spell_lifesteal_buff"
end

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_applier:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_applier:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_applier:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_applier:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_applier:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "radius" )
	if IsServer() and self:GetParent() ~= self:GetCaster() then
		self:StartIntervalThink( 0.5 )
	end
end

--------------------------------------------------------------------------------

function modifier_custom_spell_lifesteal_applier:OnRefresh( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------