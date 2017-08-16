LinkLuaModifier("modifier_drow_splitshot", "abilities/drow_splitshot.lua", LUA_MODIFIER_MOTION_NONE)


drow_splitshot = class({})

function drow_splitshot:GetIntrinsicModifierName()
	return "modifier_drow_splitshot"
end

function drow_splitshot:OnProjectileHit( hTarget, vLocation )
	if not IsServer() or not hTarget or hTarget:IsNull() then return end

	local bUseCastAttackOrb = true
	local bProcessProcs = true
	local bSkipCooldown = true
	local bIgnoreInvis = true
	local bUseProjectile = false
	local bFakeAttack = false
	local bNeverMiss = false

	self.mod.reduceAttackDamage = true

		self:GetCaster():PerformAttack(hTarget, bUseCastAttackOrb, bProcessProcs, bSkipCooldown, bIgnoreInvis, bUseProjectile, bFakeAttack, bNeverMiss)

	self.mod.reduceAttackDamage = false
end


modifier_drow_splitshot = class({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return false end,
	IsPermanent = function(self) return true end,
	RemoveOnDeath = function(self) return false end,
	GetAttributes = function(self) return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE+MODIFIER_ATTRIBUTE_PERMANENT end,
	DeclareFunctions = function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,} end,
})

function modifier_drow_splitshot:OnCreated( kv )
	if not IsServer() then return end

	--i believe drow ult actually works with illusions, so i guess this should work with illusions?
	--if self:GetParent():IsIllusion() then self:Destroy() return end

	self:GetAbility().mod = self

	self.splitCount = self:GetAbility():GetSpecialValueFor("split_count")
	self.searchRadius = self:GetAbility():GetSpecialValueFor("search_radius")
	self.damageReduction = (-1) * self:GetAbility():GetSpecialValueFor("damage_reduction") * 0.01

	self.projSpeed = self:GetParent():GetProjectileSpeed()
	self.projectile = self:GetParent():GetRangedProjectileName()

	-- for melee heroes
	if not self.projectile or self.projectile == "particles/base_attacks/ranged_hero.vpcf" then
		self.projectile = "particles/units/heroes/hero_drow/drow_base_attack.vpcf"
	end
	if self.projSpeed <= 0 then
		self.projSpeed = 1250
	end
end

function modifier_drow_splitshot:OnAttackLanded( keys )
	if IsServer() and keys.attacker == self:GetParent() then

		--According to the wiki, "Splintering arrows are not disabled [by break] and fully work."
		--prevent infinite loop, break check
		if self.reduceAttackDamage --[[or self:GetParent():PassivesDisabled()]] then return end

		if not self:GetAbility():IsFullyCastable() then return end

		local units = FindUnitsInRadius(self:GetParent():GetTeamNumber(), keys.target:GetAbsOrigin(), nil, self.searchRadius, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		if #units <= 1 then return end

		--dont fire projectiles at the primary target
		local pos = vlua.find(units, keys.target)
		if pos then
			table.remove(units, pos)
		end	

		local info = {
			EffectName = self.projectile,
		--	Target = nil,
			Source = keys.target,
			Ability = self:GetAbility(),
			bDodgeable = true,
			iMoveSpeed = self.projSpeed,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			bProvidesVision = false,
		--	iVisionRadius = 0,
		--	iVisionTeamNumber = self:GetParent():GetTeamNumber(),
		}

		for i=1,self.splitCount do
			if units[i] then
				info.Target = units[i]
				ProjectileManager:CreateTrackingProjectile(info)
			end
		end

		self:GetAbility():UseResources(true, false, true)
	end
end

--not sure if this is the correct modifier property for this
function modifier_drow_splitshot:GetModifierBaseDamageOutgoing_Percentage()
	if IsServer() and self.reduceAttackDamage then
		return self.damageReduction
	end
end
