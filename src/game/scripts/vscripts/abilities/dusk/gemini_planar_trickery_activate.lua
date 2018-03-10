gemini_planar_trickery_activate = class({})

function gemini_planar_trickery_activate:OnSpellStart()
	if IsServer() then
		local c = self:GetCaster()

		if not c:HasModifier("modifier_planar_trickery") then -- it's bugged; they must have the modifier
			-- if this is the case, we reset the ability by giving the modifier for a small amount of time
			-- when its duration ends, it will set the correct abilities to be hidden etc
			local ab = c:FindAbilityByName("gemini_planar_trickery")
			c:AddNewModifier(c, ab, "modifier_planar_trickery", {Duration=0.03})
		end

		if c.planar_trickery_portal then
			ParticleManager:CreateParticle("particles/units/heroes/hero_gemini/planar_trickery_activate.vpcf", PATTACH_ABSORIGIN, c)
			c:EmitSound("Voidwalker.PlanarTrickery.Teleport")

			Timers:CreateTimer(0.06,function()
				FindClearSpaceForUnit(c, c.planar_trickery_portal:GetAbsOrigin(), true)
				ParticleManager:CreateParticle("particles/units/heroes/hero_gemini/planar_trickery_activate.vpcf", PATTACH_ABSORIGIN, c)
				c:EmitSound("Voidwalker.PlanarTrickery.Teleport")

				local mod = c:FindModifierByName("modifier_planar_trickery")

				if mod then
					mod:Destroy()
				end
			end)
		end
	end
end