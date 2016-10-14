--[[ ============================================================================================================
	Author: Rook, with help from Noya
	Date: February 26, 2015
	Returns a reference to a newly-created illusion unit.
================================================================================================================= ]]
function invoker_retro_confuse_create_illusion(keys, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration, find_clear_space)	
	local player_id = keys.caster:GetPlayerID()
	local caster_team = keys.caster:GetTeam()
	
	local illusion = CreateUnitByName(keys.caster:GetUnitName(), illusion_origin, find_clear_space, keys.caster, nil, caster_team)  --handle_UnitOwner needs to be nil, or else it will crash the game.
	illusion:SetPlayerID(player_id)
	illusion:SetControllableByPlayer(player_id, true)

	--Level up the illusion to the caster's level.
	local caster_level = keys.caster:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	--Set the illusion's available skill points to 0 and teach it the abilities the caster has.
	illusion:SetAbilityPoints(0)
	for ability_slot = 0, 15 do
		local individual_ability = keys.caster:GetAbilityByIndex(ability_slot)
		if individual_ability ~= nil then 
			local illusion_ability = illusion:FindAbilityByName(individual_ability:GetAbilityName())
			if illusion_ability ~= nil then
				illusion_ability:SetLevel(individual_ability:GetLevel())
			end
		end
	end

	--Recreate the caster's items for the illusion.
	for item_slot = 0, 5 do
		local individual_item = keys.caster:GetItemInSlot(item_slot)
		if individual_item ~= nil then
			local illusion_duplicate_item = CreateItem(individual_item:GetName(), illusion, illusion)
			illusion:AddItem(illusion_duplicate_item)
		end
	end
	
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle 
	illusion:AddNewModifier(keys.caster, keys.ability, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
	
	illusion:MakeIllusion()  --Without MakeIllusion(), the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.  Without it, IsIllusion() returns false and IsRealHero() returns true.

	return illusion
end



--[[ ============================================================================================================
	Author: Rook
	Date: February 26, 2015
	Called when Confuse is cast.
================================================================================================================= ]]
function invoker_retro_confuse_on_spell_start(keys)
	local target_point = keys.target_points[1]
	
	local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
	local wex_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
	if quas_ability ~= nil and wex_ability ~= nil then
		local illusion_duration = keys.ability:GetLevelSpecialValueFor("duration", quas_ability:GetLevel() - 1)
		local illusion_incoming_damage_percent = keys.ability:GetLevelSpecialValueFor("incoming_damage_percent", wex_ability:GetLevel() - 1)

		--Create the illusions.
		local confuse_illusion = invoker_retro_confuse_create_illusion(keys, target_point, illusion_incoming_damage_percent, 0, illusion_duration, true)
		local confuse_ghost = invoker_retro_confuse_create_illusion(keys, confuse_illusion:GetAbsOrigin(), 0, 0, illusion_duration * 2, false)  --The ghost lasts twice as long as the illusion.

		--Make it so all of the units are facing the same direction.
		local caster_forward_vector = keys.caster:GetForwardVector()
		confuse_ghost:SetForwardVector(caster_forward_vector)
		confuse_illusion:SetForwardVector(caster_forward_vector)
		
		--Set the illusion's health and mana values to those of the real Invoker.
		local caster_health = keys.caster:GetHealth()
		local caster_mana = keys.caster:GetMana()
		confuse_ghost:SetHealth(caster_health)
		confuse_ghost:SetMana(caster_mana)
		confuse_illusion:SetHealth(caster_health)
		confuse_illusion:SetMana(caster_mana)
		
		--Limit how the ghost and illusion can be interacted with.
		keys.ability:ApplyDataDrivenModifier(keys.caster, confuse_illusion, "modifier_invoker_retro_confuse_illusion", nil)
		keys.ability:ApplyDataDrivenModifier(keys.caster, confuse_ghost, "modifier_invoker_retro_confuse_illusion", nil)
		keys.ability:ApplyDataDrivenModifier(keys.caster, confuse_ghost, "modifier_invoker_retro_confuse_ghost", nil)
		
		--Give Invoker's orb particle effects and modifiers to the illusions.
		for i=1, 3, 1 do
			if keys.caster.invoked_orbs[i] ~= nil then
				local orb_name = keys.caster.invoked_orbs[i]:GetName()
				if orb_name == "invoker_retro_quas" then
					local orb_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, confuse_illusion)
					ParticleManager:SetParticleControlEnt(orb_particle_effect, 1, confuse_illusion, PATTACH_POINT_FOLLOW, "attach_orb" .. i, confuse_illusion:GetAbsOrigin(), false)
					local illusion_quas_ability = confuse_illusion:FindAbilityByName("invoker_retro_quas")
					if illusion_quas_ability ~= nil then
						illusion_quas_ability:ApplyDataDrivenModifier(confuse_illusion, confuse_illusion, "modifier_invoker_retro_quas_instance", nil)
					end
					
					local orb_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, confuse_ghost)
					ParticleManager:SetParticleControlEnt(orb_particle_effect, 1, confuse_ghost, PATTACH_POINT_FOLLOW, "attach_orb" .. i, confuse_ghost:GetAbsOrigin(), false)
					local illusion_quas_ability = confuse_ghost:FindAbilityByName("invoker_retro_quas")
					if illusion_quas_ability ~= nil then
						illusion_quas_ability:ApplyDataDrivenModifier(confuse_ghost, confuse_ghost, "modifier_invoker_retro_quas_instance", nil)
					end
				elseif orb_name == "invoker_retro_wex" then
					local orb_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_wex_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, confuse_illusion)
					ParticleManager:SetParticleControlEnt(orb_particle_effect, 1, confuse_illusion, PATTACH_POINT_FOLLOW, "attach_orb" .. i, confuse_illusion:GetAbsOrigin(), false)
					local illusion_wex_ability = confuse_illusion:FindAbilityByName("invoker_retro_wex")
					if illusion_wex_ability ~= nil then
						illusion_wex_ability:ApplyDataDrivenModifier(confuse_illusion, confuse_illusion, "modifier_invoker_retro_wex_instance", nil)
					end
					
					local orb_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_wex_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, confuse_ghost)
					ParticleManager:SetParticleControlEnt(orb_particle_effect, 1, confuse_ghost, PATTACH_POINT_FOLLOW, "attach_orb" .. i, confuse_ghost:GetAbsOrigin(), false)
					local illusion_wex_ability = confuse_ghost:FindAbilityByName("invoker_retro_wex")
					if illusion_wex_ability ~= nil then
						illusion_wex_ability:ApplyDataDrivenModifier(confuse_ghost, confuse_ghost, "modifier_invoker_retro_wex_instance", nil)
					end
				elseif orb_name == "invoker_retro_exort" then
					local orb_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, confuse_illusion)
					ParticleManager:SetParticleControlEnt(orb_particle_effect, 1, confuse_illusion, PATTACH_POINT_FOLLOW, "attach_orb" .. i, confuse_illusion:GetAbsOrigin(), false)
					local illusion_exort_ability = confuse_illusion:FindAbilityByName("invoker_retro_exort")
					if illusion_exort_ability ~= nil then
						illusion_exort_ability:ApplyDataDrivenModifier(confuse_illusion, confuse_illusion, "modifier_invoker_retro_exort_instance", nil)
					end
					
					local orb_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, confuse_ghost)
					ParticleManager:SetParticleControlEnt(orb_particle_effect, 1, confuse_ghost, PATTACH_POINT_FOLLOW, "attach_orb" .. i, confuse_ghost:GetAbsOrigin(), false)
					local illusion_exort_ability = confuse_ghost:FindAbilityByName("invoker_retro_exort")
					if illusion_exort_ability ~= nil then
						illusion_exort_ability:ApplyDataDrivenModifier(confuse_ghost, confuse_ghost, "modifier_invoker_retro_exort_instance", nil)
					end
				end
			end
		end
		
		--Give the illusion the caster's spell(s) so it looks like it has something invoked.  Give it the correct version of Invoke, as well.
		--There is no reason to give the ghost anything because it cannot be selected.
		local illusion_current_invoked_spell_d = confuse_illusion:GetAbilityByIndex(3)
		confuse_illusion:RemoveAbility(illusion_current_invoked_spell_d:GetName())
		local caster_current_invoked_spell_d = keys.caster:GetAbilityByIndex(3)
		local caster_current_invoked_spell_d_name = caster_current_invoked_spell_d:GetName()
		confuse_illusion:AddAbility(caster_current_invoked_spell_d_name)
		local illusion_new_invoked_spell_d = confuse_illusion:FindAbilityByName(caster_current_invoked_spell_d_name)
		illusion_new_invoked_spell_d:SetLevel(caster_current_invoked_spell_d:GetLevel())
		
		local illusion_current_invoked_spell_f = confuse_illusion:GetAbilityByIndex(4)
		confuse_illusion:RemoveAbility(illusion_current_invoked_spell_f:GetName())
		local caster_current_invoked_spell_f = keys.caster:GetAbilityByIndex(4)
		local caster_current_invoked_spell_f_name = caster_current_invoked_spell_f:GetName()
		confuse_illusion:AddAbility(caster_current_invoked_spell_f_name)
		local illusion_new_invoked_spell_f = confuse_illusion:FindAbilityByName(caster_current_invoked_spell_f_name)
		illusion_new_invoked_spell_f:SetLevel(caster_current_invoked_spell_f:GetLevel())
		
		local illusion_current_invoke = confuse_illusion:GetAbilityByIndex(5)
		confuse_illusion:RemoveAbility(illusion_current_invoke:GetName())
		local caster_invoke = keys.caster:GetAbilityByIndex(5)
		local caster_invoke_name = caster_invoke:GetName()
		confuse_illusion:AddAbility(caster_invoke_name)
		local illusion_new_invoke = confuse_illusion:FindAbilityByName(caster_invoke_name)
		illusion_new_invoke:SetLevel(caster_invoke:GetLevel())
		
		--Play some particle effects and sound.
		ParticleManager:CreateParticle("particles/generic_gameplay/illusion_created.vpcf", PATTACH_ABSORIGIN_FOLLOW, confuse_illusion)
		keys.caster:EmitSound("Hero_Terrorblade.ConjureImage")
	end
end