if chi_strike_sp == nil then
	chi_strike_sp = class({})
end

LinkLuaModifier( "chi_strike_sp_mod", "abilities/overflow/chi_strike_sp/modifier.lua", LUA_MODIFIER_MOTION_NONE )

function chi_strike_sp:GetBehavior()
	local behav = DOTA_ABILITY_BEHAVIOR_PASSIVE
	return behav
end

function chi_strike_sp:GetIntrinsicModifierName() return "chi_strike_sp_mod" end

function chi_strike_sp:OnProjectileHit(hTarget, vLocation)
	if hTarget == nil then return end
	if self.original_target and self.original_target == hTarget then
	return false
	end
	self.chi_on = true
	local cap = self:GetCaster():GetAttackCapability()
	local acq = self:GetCaster():GetAcquisitionRange()
	local pos = self:GetCaster():GetAbsOrigin()
	self:GetCaster():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	self:GetCaster():SetAcquisitionRange(99999)
	self:GetCaster():SetAbsOrigin(hTarget:GetAbsOrigin())
  self:GetCaster():PerformAttack(hTarget, true, true, true, true, false, false, true)
	--self:GetCaster():PerformAttack(hTarget, true, true, true, true,false)
	self:GetCaster():SetAbsOrigin(pos)
	self:GetCaster():SetAcquisitionRange(acq)
	self:GetCaster():SetAttackCapability(cap)
	self.chi_on = false
	return false
end
