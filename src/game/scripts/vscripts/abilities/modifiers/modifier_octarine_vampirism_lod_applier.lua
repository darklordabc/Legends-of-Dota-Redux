modifier_octarine_vampirism_lod_applier = class({})

--------------------------------------------------------------------------------

function modifier_octarine_vampirism_lod_applier:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_octarine_vampirism_lod_applier:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_octarine_vampirism_lod_applier:GetModifierAura()
	return "modifier_octarine_vampirism_lod_buff"
end

--------------------------------------------------------------------------------

function modifier_octarine_vampirism_lod_applier:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_octarine_vampirism_lod_applier:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function modifier_octarine_vampirism_lod_applier:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_octarine_vampirism_lod_applier:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

--------------------------------------------------------------------------------

function modifier_octarine_vampirism_lod_applier:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------

function modifier_octarine_vampirism_lod_applier:OnCreated( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "radius" )
	if IsServer() and self:GetParent() ~= self:GetCaster() then
		self:StartIntervalThink( 0.5 )
	end
end

--------------------------------------------------------------------------------

function modifier_octarine_vampirism_lod_applier:OnRefresh( kv )
	self.aura_radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

--------------------------------------------------------------------------------