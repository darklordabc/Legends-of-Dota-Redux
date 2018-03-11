nyx_assassin_burrow_redux = class({})
LinkLuaModifier("modifier_nyx_assassin_burrow_invis_override_redux", "abilities/nyx_assassin_burrow_redux",LUA_MODIFIER_MOTION_NONE)


function nyx_assassin_burrow_redux:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local modifier_burrowed = "modifier_nyx_assassin_burrow"
	local sound_burrow = "Hero_NyxAssassin.Burrow.In"
	local sound_unburrow = "Hero_NyxAssassin.Burrow.Out"
	local particle_burrow = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow.vpcf"
	local particle_unburrow = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow_exit.vpcf"
	
	if not caster:HasModifier(modifier_burrowed) then -- Burrowing
		-- Start gesture
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)	

		-- Play burrow sound
		EmitSoundOn(sound_burrow, caster)

		-- Add burrow particles
		local particle_burrow_fx = ParticleManager:CreateParticle(particle_burrow, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_burrow_fx, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_burrow_fx)

	else -- Unburrowing
		-- Play unburrow sound
		EmitSoundOn(sound_unburrow, caster)

		-- Add unburrow particles
		local particle_unburrow_fx = ParticleManager:CreateParticle(particle_unburrow, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_unburrow_fx, 0, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_unburrow_fx)		
	end

	return true
end

function nyx_assassin_burrow_redux:OnSpellStart()
	local caster = self:GetCaster()
	local ability = self	
	local modifier_burrowed = "modifier_nyx_assassin_burrow"
	local modifier_invis_override = "modifier_nyx_assassin_burrow_invis_override_redux"	

	-- if Nyx isn't burrowed, Give nyx the burrow modifier. Else, unburrow him
	if not caster:HasModifier(modifier_burrowed) then
		caster:AddNewModifier(caster, ability, modifier_burrowed, {})
		caster:AddNewModifier(caster, ability, modifier_invis_override, {})
	else
		caster:RemoveModifierByName(modifier_burrowed)
		caster:RemoveModifierByName(modifier_invis_override)
	end
end

function nyx_assassin_burrow_redux:GetAbilityTextureName()
	local caster = self:GetCaster()
	local modifier_burrowed = "modifier_nyx_assassin_burrow"	

	if not caster:HasModifier(modifier_burrowed) then
		return "custom/nyx_assassin_burrow_redux"
	else
		return "custom/nyx_assassin_unburrow_redux"
	end	
end

--Invisibility override modifier
modifier_nyx_assassin_burrow_invis_override_redux = class({})

function modifier_nyx_assassin_burrow_invis_override_redux:CheckState()
	local state = {[MODIFIER_STATE_INVISIBLE] = false}
	return state	
end

function modifier_nyx_assassin_burrow_invis_override_redux:IsHidden()
	return true	
end

function modifier_nyx_assassin_burrow_invis_override_redux:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end