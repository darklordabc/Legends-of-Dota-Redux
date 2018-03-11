dark_blade = class({})
LinkLuaModifier( "modifier_dark_blade", "abilities/overflow/dark_blade/modifier_dark_blade.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_blade_fade", "abilities/overflow/dark_blade/modifier_dark_blade_fade.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_dark_blade_curse", "abilities/overflow/dark_blade/modifier_dark_blade_curse.lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function dark_blade:CastFilterResultTarget( hTarget )
	if IsServer() then

		if hTarget ~= nil and hTarget:IsMagicImmune() and ( not self:GetCaster():HasScepter() ) then
			return UF_FAIL_MAGIC_IMMUNE_ENEMY
		end

		local nResult = UnitFilter( hTarget, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber() )
		return nResult
	end

	return UF_SUCCESS
end

--------------------------------------------------------------------------------

function dark_blade:GetCastRange( vLocation, hTarget )
	return self.BaseClass.GetCastRange( self, vLocation, hTarget )
end

--------------------------------------------------------------------------------

function dark_blade:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	if hTarget ~= nil then
		--hTarget:TriggerSpellReflect( self )
		local absorb = hTarget:TriggerSpellAbsorb( self )
		
		if not absorb then
			local damage_delay = self:GetSpecialValueFor( "damage_delay" )
		
			hTarget:AddNewModifier( self:GetCaster(), self, "modifier_dark_blade", { duration = damage_delay, fade_id = GameRules:GetGameTime() } )
			EmitSoundOn( "Hero_Nightstalker.Void.Nihility", hTarget )
		end

		local nFXIndex = ParticleManager:CreateParticle( "particles/lina_spell_laguna_chain.vpcf", PATTACH_CUSTOMORIGIN, nil );
		ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin() + Vector( 0, 0, 96 ), true );
		ParticleManager:SetParticleControlEnt( nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true );
		
			local Colour = {255,150,255}
			if hTarget:HasModifier("modifier_dark_blade_curse") then
				local hMod = hTarget:FindModifierByName("modifier_dark_blade_curse")
				local nStack = hMod:GetStackCount()
				Colour[1] = Colour[1]/(nStack/2) + 50
				Colour[2] = Colour[2]/nStack + 25
			end
			ParticleManager:SetParticleControl(nFXIndex, 15, Vector(Colour[1],Colour[2],Colour[3])) 
			
		--ParticleManager:SetParticleControl(nFXIndex, 15, Vector(120,20,255)) 
		ParticleManager:ReleaseParticleIndex( nFXIndex );
	end
end

--------------------------------------------------------------------------------


function dark_blade:GetAOERadius()
	return self:GetSpecialValueFor("aoe_range")
end

function dark_blade:GetAbilityDamageType()
		return DAMAGE_TYPE_MAGICAL
end