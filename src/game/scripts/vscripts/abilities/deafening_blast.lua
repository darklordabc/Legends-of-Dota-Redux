LinkLuaModifier("modifier_deafening_blast_knockback", "abilities/deafening_blast", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_deafening_blast_disarm", "abilities/deafening_blast", LUA_MODIFIER_MOTION_NONE)

deafening_blast = class({})

function deafening_blast:OnSpellStart()
	local pos = self:GetCursorPosition()
	if not pos then return end
	self.castpoint = self:GetCaster():GetAbsOrigin()

	--fire projectile
	local info = {
		nil,
		nil,	
	}
	ProjectileManager:CreateLinearProjectile(info)

	if self:GetCaster():HasTalent("invoker_talent") then
		--aoe deafening blast. iterate by 30 degree angles and cast X(11?) times
		for i=???? do
			--edit direction and vector or something in info table
			info.TargetOrSomeShit = new
			--fire projectile again
			ProjectileManager:CreateLinearProjectile(info)
		end
	end
end

function deafening_blast:OnProjectileHit( hTarget, vLocation )
	if not IsServer() or not hTarget or hTarget:IsNull() then return end
  --apply modifiers on hit (if not spell immune?)
end

modifier_deafening_blast_knockback = class({
	IsHidden = function(self) return true end,
	IsPurgable = function(self) return false end,
	GetOverrideAnimation = function(self) return ACT_DOTA_FLAIL end,

	OnCreated = function(self)
		if not IsServer() then return end
		self.value = self:GetAbility():GetSpecialValueFor("")
		--grab a referance to castpoint. so the ability doesnt bug out when trying to use the castpoint from a different cast
		self.castpoint = self:GetAbility().castpoint

		self:SetPriority(DOTA_MOTION_CONTROLLER_PRIORITY_HIGH)

		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
		end
	end,

	UpdateHorizontalMotion = function(self, me, dt)
		print("me: "..tostring(me),
			"dt: "..tostring(dt))
		if not IsServer() then return end

		--move parent away from cast point. reference wiki for exacts

	end,

	OnHorizontalMotionInterrupted = function(self)
		self:Destroy()
	end,	
})

--seperate modifier because disarm has different purge properties than knockback
modifier_deafening_blast_disarm = class({
	IsHidden = function(self) return false end,
	IsPurgable = function(self) return false end,
	IsPurgeException = function(self) return true end,
	CheckState = function(self) return {[MODIFIER_STATE_DISARMED] = true,} end,

	GetEffectName = function(self) return "" end,
	GetEffectAttachType = function(self) return PATTACH_OVERHEAD_FOLLOW end,
})
