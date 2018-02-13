-- Fires a projectile at the target enemy. When it hits them, it annihilates all magical impurities,
-- stunning and dealing Pure damage.
-- The damage and stun duration doubles for each time it's used on any target.

gemini_voidal_flare = class({})

LinkLuaModifier("modifier_voidal_flare","abilities/dusk/gemini_voidal_flare",LUA_MODIFIER_MOTION_NONE)

function gemini_voidal_flare:OnSpellStart()
	local c = self:GetCaster()
	local t = self:GetCursorTarget()

	local spawn_origin = c:GetAttachmentOrigin(DOTA_PROJECTILE_ATTACHMENT_ATTACK_1)

	c:EmitSound("Voidwalker.VoidalFlare")

	local info = 
	  {
	  Target = t,
	  Source = c,
	  Ability = self,  
	  EffectName = "particles/units/heroes/hero_gemini/voidal_flare.vpcf",
	  vSpawnOrigin = spawn_origin,
	  fDistance = 10000,
	  fStartRadius = 32,
	  fEndRadius = 32,
	  bHasFrontalCone = false,
	  bReplaceExisting = false,
	  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
	  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
	  iUnitTargetType = DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
	  fExpireTime = GameRules:GetGameTime() + 10.0,
	  bDeleteOnHit = true,
	  iMoveSpeed = 1700,
	  bProvidesVision = false,
	  iVisionRadius = 0,
	  iVisionTeamNumber = c:GetTeamNumber(),
	  iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	  }
  
  	local projectile = ProjectileManager:CreateTrackingProjectile(info)
end

function gemini_voidal_flare:OnProjectileHit(t,l)
	if t then
		local duration = self:GetSpecialValueFor("duration")
		local modifier = t:FindModifierByName("modifier_voidal_flare")

		if t:IsMagicImmune() then return end

		local stack = 1

		t:AddNewModifier(self:GetCaster(), self, "modifier_voidal_flare", {Duration=duration, stack=1})
		-- will set the stack to 1 if creating, or add when refreshing

		if modifier then
			stack = modifier:GetStackCount()
		end

		local damage_bonus = self:GetSpecialValueFor("damage_bonus")
		local damage = self:GetSpecialValueFor("damage") + damage_bonus * (stack-1)
		local stun = self:GetSpecialValueFor("stun") + self:GetSpecialValueFor("stun_bonus") * (stack-1)

		InflictDamage(t,self:GetCaster(),self,damage,DAMAGE_TYPE_MAGICAL)

		t:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {Duration=stun})
		t:EmitSound("Voidwalker.VoidalFlare.Hit")
	end
end

modifier_voidal_flare = class({})

function modifier_voidal_flare:OnCreated(kv)
	if IsServer() then
		local stack = kv.stack

		self:SetStackCount(kv.stack)
	end
end

function modifier_voidal_flare:OnRefresh(kv)
	if IsServer() then
		local stack = kv.stack

		local max = self:GetAbility():GetSpecialValueFor("max_mult")

		if self:GetStackCount() + stack > max then return end

		self:SetStackCount(self:GetStackCount()+kv.stack)
	end
end

function InflictDamage(target,attacker,ability,damage,damage_type,flags)
	local flags = flags or 0
	ApplyDamage({
	    victim = target,
	    attacker = attacker,
	    damage = damage,
	    damage_type = damage_type,
	    damage_flags = flags,
	    ability = ability
  	})
end