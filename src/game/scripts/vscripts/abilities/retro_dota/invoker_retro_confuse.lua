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
	
	local invoker_retro_confuse_ability = keys.caster:FindAbilityByName("invoker_retro_confuse")
	if invoker_retro_confuse_ability ~= nil then
		local illusion_duration = keys.ability:GetLevelSpecialValueFor("duration", invoker_retro_confuse_ability:GetLevel() - 1)
		local illusion_incoming_damage_percent = keys.ability:GetLevelSpecialValueFor("incoming_damage_percent", invoker_retro_confuse_ability:GetLevel() - 1)

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
				
		--Play some particle effects and sound.
		ParticleManager:CreateParticle("particles/generic_gameplay/illusion_created.vpcf", PATTACH_ABSORIGIN_FOLLOW, confuse_illusion)
		keys.caster:EmitSound("Hero_Terrorblade.ConjureImage")
	end
end