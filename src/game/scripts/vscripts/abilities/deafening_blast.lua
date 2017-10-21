LinkLuaModifier("modifier_deafening_blast_knockback", "abilities/deafening_blast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_deafening_blast_disarm", "abilities/deafening_blast", LUA_MODIFIER_MOTION_NONE)


invoker_deafening_blast_lod = class({})

function invoker_deafening_blast_lod:OnSpellStart()
	local pos = self:GetCursorPosition()
	if not pos then return end
	self.hit = self.hit or {}
	self.cast = self.cast or {}
	table.insert(self.cast, #self.cast)

	local startRadius = self:GetSpecialValueFor("radius_start")
	local endRadius = self:GetSpecialValueFor("radius_end")
	local distance = self:GetSpecialValueFor("travel_distance")
	local speed = self:GetSpecialValueFor("travel_speed")
	local max = 10

	--when projectile is completely gone, remove its table data
	Timers:CreateTimer(max, function() table.remove(self.cast, 1) end)

	local dir = (pos - self:GetCaster():GetAbsOrigin()):Normalized()

	--check for casting on exact origin of caster
	if pos == self:GetCaster():GetAbsOrigin() then
		dir = self:GetCaster():GetForwardVector()
	end
	dir.z = 0

	local info = {
		EffectName = "particles/units/heroes/hero_invoker/invoker_deafening_blast.vpcf",
		Ability = self,
		Source = self:GetCaster(),
		vSpawnOrigin = self:GetCaster():GetAbsOrigin(),
		fDistance = distance,
		fStartRadius = startRadius,
		fEndRadius = endRadius,
		bHasFrontalCone = true,
		bReplaceExisting = false,
		vVelocity = dir * speed,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + max,
		bDeleteOnHit = false,
		bProvidesVision = true,
		iVisionRadius = endRadius,
		iVisionTeamNumber = self:GetCaster():GetTeamNumber()
	}
	ProjectileManager:CreateLinearProjectile( info )

	--aoe deafening blast. iterate by 30 degree angles and cast 11 more times
	if self:GetCaster():HasAbility("special_bonus_unique_invoker_2") then
		if self:GetCaster():FindAbilityByName("special_bonus_unique_invoker_2"):GetLevel() > 0 then
			for i=1,11 do
				info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,30*i,0), dir) * speed
				ProjectileManager:CreateLinearProjectile( info )
			end
		end
	end

	EmitSoundOn("Hero_Invoker.DeafeningBlast", self:GetCaster())
end


function invoker_deafening_blast_lod:OnProjectileHit( hTarget, vLocation )
	if not IsServer() or not hTarget or hTarget:IsNull() then return end

	local num = #self.cast
	local mod = hTarget:FindModifierByName("modifier_deafening_blast_knockback")
	if mod then
		--dont allow re-apply if same cast hitting multiple times. DO allow if different cast
		if self.hit[hTarget] == num then return end

		hTarget:RemoveModifierByName("modifier_deafening_blast_knockback")
		hTarget:RemoveModifierByName("modifier_deafening_blast_disarm")
	end

	--mark unit as hit by this cast
	self.hit[hTarget] = num

	ApplyDamage({victim = hTarget, attacker = self:GetCaster(), ability = self, damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType()})

	if hTarget:IsAlive() then
		local knockback = self:GetSpecialValueFor("knockback_duration") 
		local disarm = self:GetSpecialValueFor("disarm_duration")

		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_deafening_blast_disarm", {duration = disarm})
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_deafening_blast_knockback", {duration = knockback}).castPoint = vLocation
	end
end

modifier_deafening_blast_knockback = class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
	GetOverrideAnimation = function(self) return ACT_DOTA_DISABLED end,
	CheckState = function(self) return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true,} end,

	GetEffectName = function(self) return "particles/status_fx/status_effect_frost.vpcf" end,
	GetEffectAttachType = function(self) return PATTACH_OVERHEAD_FOLLOW end,

	OnCreated = function(self, kv)
		if not IsServer() then return end
		self.dur = self:GetDuration()
		self.speed = 200

		self.p = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_deafening_blast_knockback_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

		--grab a reference to the modifier
		local this = self
		local tick = 1/30
		this.timer = Timers:CreateTimer(function()
			if not this or this:IsNull() then return end
			--check for vector, try again if not found
			if not this.castPoint then
				return tick
			end
			--start decreasing speed after 1/3 duration 
			if this:GetElapsedTime() >= this.dur * (1/3) then
				this.speed = this.speed * 0.98
			end

			--move parent away from point of contact
			local parent = this:GetParent()
			local speed = this.speed * tick
			local direction = (parent:GetAbsOrigin() - this.castPoint):Normalized()
			parent:SetAbsOrigin(parent:GetAbsOrigin() + direction * speed)

			--nullify walking movement
			if parent:IsMoving() then
				local backwardVector = (parent:GetAbsOrigin() - (parent:GetAbsOrigin() + parent:GetForwardVector())):Normalized()
				local movespeed = parent:GetMoveSpeedModifier(parent:GetBaseMoveSpeed()) * tick
				parent:SetAbsOrigin(parent:GetAbsOrigin() + backwardVector * movespeed)
			end

			local radius = self:GetAbility():GetSpecialValueFor("tree_radius")
			GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), radius, false)

			return tick
		end)
	end,

	OnDestroy = function(self)
		if not IsServer() then return end
		local pos = vlua.find(self:GetAbility().hit, self:GetParent())
		if pos then
			table.remove(self:GetAbility().hit, pos)
		end
		Timers:RemoveTimer(self.timer)

		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)

		ParticleManager:DestroyParticle(self.p, true)
		ParticleManager:ReleaseParticleIndex(self.p)
	end,
})

--seperate modifier because disarm has different purge properties than knockback
modifier_deafening_blast_disarm = class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
	IsPurgeException = function(self) return true end,
	CheckState = function(self) return {[MODIFIER_STATE_DISARMED] = true,} end,
	GetEffectName = function(self) return "particles/units/heroes/hero_invoker/invoker_deafening_blast_disarm_debuff.vpcf" end,
	GetEffectAttachType = function(self) return PATTACH_OVERHEAD_FOLLOW end,
})
