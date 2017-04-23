function ScepterRespawn( keys )
	local caster = keys.caster
	if caster:HasScepter() then
		Timers:CreateTimer( 0.1, function( )
			caster:SetBuybackCooldownTime(0)
			if caster:HasModifier('modifier_buyback_gold_penalty') then
				caster:SetBuybackGoldLimitTime(0)
				caster:RemoveModifierByName('modifier_buyback_gold_penalty')
			end
		end)
	end
end

function ScepterBuyback( keys )
	local target = keys.unit
	print(target:GetName())
	for _,caster in pairs(HeroList:GetAllHeroes()) do
		if caster:HasScepter() and caster:GetName() == "npc_dota_hero_skeleton_king" and caster ~= target then
			Timers:CreateTimer( 0.1, function()
				if target:HasModifier('modifier_buyback_gold_penalty') then
					print("Zeros gained gold because a hero bought back while carrying Aghanim's Scepter.")
					caster:ModifyGold(target:GetBuybackCost() * 0.6, false, 0)

					local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf"
					local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
					ParticleManager:SetParticleControl( particle, 0, caster:GetAbsOrigin() )
					ParticleManager:SetParticleControl( particle, 1, caster:GetAbsOrigin() )


					local value = math.floor(target:GetBuybackCost() * 0.6)
					local symbol = 0 -- "+" presymbol
					local color = Vector(255, 200, 33) -- Gold
					local lifetime = 2.0
					local digits = string.len(value) + 1
					local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
					local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
					ParticleManager:SetParticleControl( particle, 1, Vector( symbol, value, 0) )
				    ParticleManager:SetParticleControl( particle, 2, Vector( lifetime, digits, 0) )
				    ParticleManager:SetParticleControl( particle, 3, color )

				    EmitSoundOn("General.Coins", caster)
				end
			end)
		end
	end
end