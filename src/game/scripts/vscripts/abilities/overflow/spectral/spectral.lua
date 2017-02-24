if spectral_form == nil then
	spectral_form = class({})
end

LinkLuaModifier( "spectral_form_mod", "abilities/overflow/spectral/spectral_mod.lua", LUA_MODIFIER_MOTION_NONE )

function spectral_form:GetBehavior() 
	local behav = DOTA_ABILITY_BEHAVIOR_NO_TARGET
	return behav
end

function spectral_form:OnSpellStart()
	EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "n_creep_fellbeast.Death", self:GetCaster() )
	if self:GetCaster():HasScepter() then
		local AoE = self:GetSpecialValueFor("radius_scepter")
		local allies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), nil, AoE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
		if #allies > 0 then
			for _,ally in pairs(allies) do
				if ally ~= nil then
				ally:AddNewModifier( self:GetCaster(), self, "spectral_form_mod", { duration = self:GetDuration() } )
				end
			end
		end
	else
	self:GetCaster():AddNewModifier( self:GetCaster(), self, "spectral_form_mod", { duration = self:GetDuration() } )
	end
		
end