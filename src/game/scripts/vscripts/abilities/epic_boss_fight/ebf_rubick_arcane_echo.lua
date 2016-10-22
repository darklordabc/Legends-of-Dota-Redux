function SpellEcho(keys)
	local caster = keys.caster
	local ability = keys.ability
	if ability:IsCooldownReady() then return end
	local echo = params.event_ability
	local delay = ability:GetLevelSpecialValueFor("delay",ability:GetLevel()-1)
	local no_echo = {["shredder_chakram"] = true,
					 ["shredder_chakram_return"] = true,
					 ["shredder_chakram_2"] = true,
					 ["shredder_return_chakram_2"] = true,
					 ["arc_warden_tempest_double"] = true,
					 ["alchemist_unstable_concoction"] = true,
					 ["alchemist_unstable_concoction_throw"] = true,
					 ["vengefulspirit_nether_swap"] = true,
					 ["juggernaut_omni_slash"] = true,
					 ["rubick_telekinesis_land"] = true,
					 ["antimage_blink"] = true,
					 ["queenofpain_blink"] = true,
					 ["phoenix_icarus_dive"] = true,
					 ["phoenix_icarus_dive_stop"] = true,
					 ["phoenix_fire_spirits"] = true,
					 ["phoenix_sun_ray_stop"] = true,
					 ["phoenix_sun_ray"] = true,
					 ["phoenix_sun_ray_toggle_move"] = true,
					 ["phoenix_supernova"] = true,
					 ["phoenix_launch_fire_spirit"] = true
					}
	if echo and caster:IsRealHero() and not no_echo[ echo:GetName() ] then
		local cooldown = ability:GetCooldown(ability:GetLevel()-1)*get_octarine_multiplier(caster)
		if echo:GetCursorTarget() then
			caster:SetCursorCastTarget(echo:GetCursorTarget())
		elseif echo:GetCursorPosition() then
			caster:SetCursorPosition(echo:GetCursorPosition())
		else
			caster:SetCursorTargetingNothing(true)
		end
		local echo_effect = ParticleManager:CreateParticle("particles/rubick_spell_echo.vpcf", PATTACH_ABSORIGIN , caster)
		ParticleManager:SetParticleControl(echo_effect, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(echo_effect, 1, Vector(1,0,0))
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)
		Timers:CreateTimer(
                        function()
                            echo:OnSpellStart()
							ability:StartCooldown(cooldown)
                        end, DoUniqueString('ebf_rubick_spell_echo'), delay)
	end
end
