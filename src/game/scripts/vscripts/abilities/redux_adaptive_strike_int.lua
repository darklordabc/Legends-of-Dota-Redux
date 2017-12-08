LinkLuaModifier("modifier_adaptive_strike_int", "heroes/redux_adaptive_strike_int.lua", LUA_MODIFIER_MOTION_NONE)

adaptive_strike_int = class({})

function adaptive_strike_int:OnSpellStart()
	local target = self:GetCursorTarget()
	if not target then return end

	EmitSoundOn("Hero_Morphling.AdaptiveStrikeAgi.Cast", self:GetCaster())

	local info = {
		EffectName = "particles/units/heroes/hero_morphling/morphling_adaptive_strike_int_proj.vpcf",
		Ability = self,
		Target = target,
		Source = self:GetCaster(),
		bDodgeable = false,
		bProvidesVision = false,
		vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
		iMoveSpeed = 1150,
		iVisionRadius = 0,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
	}
	ProjectileManager:CreateTrackingProjectile(info)

	local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_morphling_3")
	if talent and talent:GetLevel() > 0 then
		
		local range = self:GetCastRange() + self:GetCaster():GetCastRangeIncrease()
		print("adaptive strike cast range: ", range)

		local maxTargets = talent:GetSpecialValueFor("value")
		local targets = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO--[[+DOTA_UNIT_TARGET_BASIC ???]], DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		--dont cast on main target again
		local pos = vlua.find(targets, target)
		if pos then
			table.remove(targets, pos)
		end

		--loop for casting on extra targets
		for i=1,maxTargets do
			--nothing left to cast on
			if #targets <= 0 then return end

			--select and cast on a random target
			info.target = targets[RandomInt(1, targets)]
			--skip units we cant see
			if self:GetCaster():CanEntityBeSeenByMyTeam(info.target) then
				ProjectileManager:CreateTrackingProjectile(info)
			else
				maxTargets = maxTargets + 1
			end
			--remove selected target from targets table
			pos = vlua.find(targets, info.target)
			if pos then
				table.remove(targets, pos)
			end
		end
	end
end


function adaptive_strike_int:OnProjectileHit( hTarget, vLocation)
	if not IsServer() or not hTarget or hTarget:IsNull() then return end

	local p = ParticleManager:CreateParticle("particles/units/heroes/hero_morphling/morphling_adaptive_strike_int.vpcf", PATTACH_WORLDORIGIN, hTarget)
	ParticleManager:SetParticleControlEnt(p, 1, hTarget, PATTACH_WORLDORIGIN, "attach_hitloc", GetGroundPosition(hTarget:GetAbsOrigin(), hTarget), false)
	ParticleManager:ReleaseParticleIndex(p)

	EmitSoundOn("Hero_Morphling.AdaptiveStrike", hTarget)

	hTarget:AddNewModifier(self:GetCaster(), self, "modifier_adaptive_strike_int", {})
end

modifier_adaptive_strike_int = class({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return false end,
	IsStunDebuff = function(self) return true end,
	CheckState = function(self) return {[MODIFIER_STATE_SILENCED] = true,} end,

	OnCreated = function(self, kv)
		if not IsServer() then return end

		local int = self:GetCaster():GetIntellect()
		local str = self:GetCaster():GetAgility() --75
		local agi = self:GetCaster():GetStrength() --50

		if agi > str then
			calc = math.abs( (agi - str) / (agi + (agi * 0.5)) )
		else
			calc = math.abs( (str - agi) / (str + (str * 0.5)) )
		end

		local duration = some_calculation
		self:SetDuration(duration, true)
	end,
})



----------------------delete me
function CDOTA_BaseNPC:GetCastRangeIncrease()
 local range = 0
 local stack_range = 0
 for _, parent_modifier in pairs(self:FindAllModifiers()) do
   if parent_modifier.GetModifierCastRangeBonus then
     range = math.max(range,parent_modifier:GetModifierCastRangeBonus())
   end
   if parent_modifier.GetModifierCastRangeBonusStacking then
     stack_range = stack_range + parent_modifier:GetModifierCastRangeBonusStacking()
   end
 end
 local hTalent = nil
 for talent_name,talent_range_bonus in pairs(CAST_RANGE_TALENTS) do
   hTalent = self:FindAbilityByName(talent_name)
   if hTalent ~= nil and hTalent:GetLevel() > 0 then
     stack_range = stack_range + talent_range_bonus
   end
   hTalent = nil
 end
 return range + stack_range
end