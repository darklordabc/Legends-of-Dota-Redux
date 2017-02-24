if military == nil then
	military = class({})
end

LinkLuaModifier( "military_mod", "abilities/overflow/military/p_mod.lua", LUA_MODIFIER_MOTION_NONE )

function military:GetBehavior() 
	local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
	return behav
end

function military:GetIntrinsicModifierName() return "military_mod" end

function military:OnHeroLevelUp() 
	self:GetCaster():ModifyGold( self:GetSpecialValueFor("gold"), true, DOTA_ModifyGold_AbilityCost )

	local caster = self:GetCaster()
	local ply = caster:GetPlayerOwner()
	local gold = self:GetSpecialValueFor("gold")

	if caster:IsRealHero() then
		SendOverheadEventMessage( caster, OVERHEAD_ALERT_GOLD , caster, gold, nil )
	end

end