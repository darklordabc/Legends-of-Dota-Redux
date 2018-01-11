gemini_planar_trickery = class({})

LinkLuaModifier("modifier_planar_trickery","abilities/dusk/gemini_planar_trickery",LUA_MODIFIER_MOTION_NONE)

function gemini_planar_trickery:OnSpellStart()
	if IsServer() then
		local c = self:GetCaster()
		local t = self:GetCursorTarget()
		local pos = t:GetAbsOrigin()

		local duration = self:GetSpecialValueFor("duration")

		local mod = c:FindModifierByName("modifier_planar_trickery")

		if mod then
			mod:Destroy()
		end

		local unit =  CreateModifierThinker( c, self, "",
	     		{Duration=duration+1.50},
	    		pos, c:GetTeamNumber(), false)

		local p = ParticleManager:CreateParticle("particles/units/heroes/hero_gemini/planar_trickery_rune.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)

		c:AddNewModifier(c, self, "modifier_planar_trickery", {Duration=duration}) --[[Returns:void
		No Description Set
		]]

		c.planar_trickery_portal = unit
		c.planar_trickery_portal_p = p

		c:EmitSound("Voidwalker.PlanarTrickery")
	end
end

modifier_planar_trickery = class({})

function modifier_planar_trickery:OnCreated()
	if IsServer() then
		local c = self:GetParent()
		local ab1 = self:GetAbility()
		local ab2 = c:FindAbilityByName("gemini_planar_trickery_activate")

		ab1:SetHidden(true)
		ab2:SetHidden(false)

		ab2:SetLevel(1)

		self:StartIntervalThink(3.0)
	end
end

function modifier_planar_trickery:OnIntervalThink()
	if IsServer() then
		local c = self:GetParent()
		if not c.planar_trickery_portal then return end
		local pos = c.planar_trickery_portal:GetAbsOrigin()
		self:GetAbility():CreateVisibilityNode( pos, 250, 3 )
	end
end

function modifier_planar_trickery:OnDestroy()
	if IsServer() then
		local c = self:GetParent()
		local dp = c.planar_trickery_portal_p
		if dp then
			ParticleManager:DestroyParticle(dp,false)
		end
		Timers:CreateTimer(0.50,function()
			if c.planar_trickery_portal then
				c.planar_trickery_portal:RemoveSelf()
			end
			c.planar_trickery_portal = nil
			c.planar_trickery_portal_p = nil
		end)

		local ab1 = self:GetAbility()
		local ab2 = c:FindAbilityByName("gemini_planar_trickery_activate")

		ab1:SetHidden(false)
		ab2:SetHidden(true)
	end
end