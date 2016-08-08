LinkLuaModifier( "nexus_super_illusion", "scripts/vscripts/../abilities/modifiers/nexus_super_illusion.lua" ,LUA_MODIFIER_MOTION_NONE )
local Timers = require('easytimers')
local util = require('util')

function CreateSuperIllusion (keys)
	local caster = keys.caster
	local target = keys.target
	local owner = caster:GetPlayerOwner():GetAssignedHero()
	local ability = owner:FindAbilityByName("skoros_Nexus")

	caster.true_owner = owner
	target.duration = target:FindModifierByName("Nexus_on_ally"):GetRemainingTime() or 0


	target.nexusdouble = CreateUnitByName( caster:GetUnitName(), target:GetAbsOrigin(), false, owner, caster:GetPlayerOwner(), caster:GetTeamNumber())
	target.nexusdouble:AddNewModifier(caster, ability, "nexus_super_illusion", {duration = -1})
	ability:ApplyDataDrivenModifier(caster, target.nexusdouble, "Nexus_ManaSpent", {duration = -1})
	--ability:ApplyDataDrivenModifier(caster, caster, "Nexus_on_self", {duration = -1})
	target.nexusdouble:SetControllableByPlayer(owner:GetPlayerID(), false)
	target.nexusdouble:SetOwner(owner)
	--target.nexusdouble:AddNoDraw()
	target.nexusdouble:SetModelScale(0.1)
	target.nexusdouble:MakeIllusion()

	StartSoundEvent("Hero_Skoros.Nexus.Cast", caster)
	StartSoundEvent("Hero_Skoros.Nexus", target)
	
	local caster_level = caster:GetLevel() 
	for i = 2, caster_level do
		target.nexusdouble:HeroLevelUp(false)
	end
	for ability_id = 0, 15 do
		local ability = target.nexusdouble:GetAbilityByIndex(ability_id)
		if ability then
			ability:SetLevel(caster:GetAbilityByIndex(ability_id):GetLevel())
		end
	end
	for item_id = 0, 5 do
		local item_in_caster = caster:GetItemInSlot(item_id)
		if item_in_caster ~= nil then
			local item_name = item_in_caster:GetName()
			local item_created = CreateItem( item_name, caster, caster)
			target.nexusdouble:AddItem(item_created)
			item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges()) 
			item_created:StartCooldown(item_in_caster:GetCooldownTimeRemaining())
		else
			local item_created = CreateItem("item_dummy_datadriven", caster, caster)
			target.nexusdouble:AddItem(item_created)
		end
	end
	for j = 0, 5 do
		dummy_in_unit = target.nexusdouble:GetItemInSlot(j)
		if dummy_in_unit and dummy_in_unit:GetName() == "item_dummy_datadriven" then
			target.nexusdouble:RemoveItem(dummy_in_unit)
		end
	end
	target.nexusdouble:SetAbilityPoints(0)
	target.nexusdouble:SetHasInventory(true)
	Timers:CreateTimer(function()
		if not target.nexusdouble:IsNull() and not target:IsNull() and target:IsAlive() then
			if target:HasModifier("Nexus_on_ally") then
				target.duration = target:FindModifierByName("Nexus_on_ally"):GetRemainingTime() or 0
			end
			target.nexusdouble:SetAbsOrigin(target:GetAbsOrigin())
		--else 
			--return -1
		end
	return 0.01
	end, DoUniqueString('skoros_nexus'), 0.01)
end

function KILLSELF (keys)
	local owner = keys.caster.true_owner
	local ability = owner:FindAbilityByName("skoros_Nexus")
	local target = keys.target
	local duration = target.duration

	StopSoundEvent("Hero_Skoros.Nexus", target)
	if owner:HasScepter() then
		local units = FindUnitsInRadius(target:GetTeam(), target:GetAbsOrigin(), nil, ability:GetCastRange(), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)	
		for _,unit in pairs(units) do
			if not unit:HasModifier("Nexus_on_ally") and unit ~= target and unit ~= owner and target.duration > 0.5 then
				ability:ApplyDataDrivenModifier(owner, unit, "Nexus_on_ally", {Duration = duration})
				owner:RemoveModifierByName("Nexus_on_self")
				ability:ApplyDataDrivenModifier(caster, unit, "modifier_nexus_attach", {Duration = 2.0})
				target.nexusdouble:ForceKill(false)
				return
			end
		end
	end
	if not target.nexusdouble:IsNull() then target.nexusdouble:ForceKill(false) end
end

function SyncSpells (keys, delete_bool)
	local caster = keys.caster
	local ability = keys.ability
	local interval = ability:GetSpecialValueFor("interval") + 0.01
	local sight_aoe = ability:GetSpecialValueFor("sight_aoe")


	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)	
	for _,unit in pairs(units) do

		if unit:GetUnitName() == caster:GetUnitName() and unit:GetPlayerID() == caster:GetPlayerID() and unit:HasModifier("nexus_super_illusion") then
			for ability_id = 0, 15 do
				local ability = unit:GetAbilityByIndex(ability_id)
				local originalability = caster:GetAbilityByIndex(ability_id)
				if ability and originalability then
					if not ability:IsCooldownReady() and ability:GetCooldownTimeRemaining() > 0 then
						originalability:StartCooldown(ability:GetCooldownTimeRemaining())
					end
					if not originalability:IsCooldownReady() and originalability:GetCooldownTimeRemaining() > 0 then
						ability:StartCooldown(originalability:GetCooldownTimeRemaining())
					end
					if not ability:IsCooldownReady() and ability:GetCooldownTimeRemaining() > 0 then
						originalability:StartCooldown(ability:GetCooldownTimeRemaining())
					end
				end
			end
			for item_id = 0, 5 do
				local item_in_caster = caster:GetItemInSlot(item_id)
				local item_in_unit = unit:GetItemInSlot(item_id)
				if item_in_caster and item_in_unit and item_in_caster:GetName() == item_in_unit:GetName() then
					--if not item_in_unit:IsCooldownReady() and item_in_unit:GetCooldownTimeRemaining() > 0 then

					if delete_bool == false then
						item_in_unit:StartCooldown(item_in_caster:GetCooldownTimeRemaining())
						item_in_unit:SetCurrentCharges(item_in_caster:GetCurrentCharges())
					end

						item_in_caster:StartCooldown(item_in_unit:GetCooldownTimeRemaining())
						item_in_caster:SetCurrentCharges(item_in_unit:GetCurrentCharges())
					--end
					--if not item_in_caster:IsCooldownReady() and item_in_caster:GetCooldownTimeRemaining() > 0 then
						item_in_unit:StartCooldown(item_in_caster:GetCooldownTimeRemaining())
						item_in_unit:SetCurrentCharges(item_in_caster:GetCurrentCharges())
					--end
					--if not item_in_unit:IsCooldownReady() and item_in_unit:GetCooldownTimeRemaining() > 0 then
						item_in_caster:StartCooldown(item_in_unit:GetCooldownTimeRemaining())
						item_in_caster:SetCurrentCharges(item_in_unit:GetCurrentCharges()) 
					--end
				elseif item_in_caster and not item_in_unit then
					if (not item_in_caster:IsPermanent() and delete_bool) or (item_in_caster:GetName() == "item_branches" and delete_bool) then
						caster:RemoveItem(item_in_caster)
					else
						local item_name = item_in_caster:GetName()
						local item_created = CreateItem( item_name, caster, caster)
						unit:AddItem(item_created)
						item_created:StartCooldown(item_in_caster:GetCooldownTimeRemaining())
						item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges()) 
					end
					
				elseif item_in_unit then
					unit:RemoveItem(item_in_unit)
					local item_name = "item_dummy_datadriven"
					local item_created = CreateItem( item_name, caster, caster)
					unit:AddItem(item_created)
				end
			end
			for j = 0, 5 do
				dummy_in_unit = unit:GetItemInSlot(j)
				if dummy_in_unit and dummy_in_unit:GetName() == "item_dummy_datadriven" then
					unit:RemoveItem(dummy_in_unit)
				end
			end
			unit:SetMana(caster:GetMana())
		end
	end
end

function start (event)
	local target = event.target
	local ability = event.ability
	if ability:GetLevel() == 1 then
		local target = event.target
	
		local targets = event.target_entities
		for _,hero in pairs(targets) do
			target.OldMana = target:GetMana()
		end
	end
end

function finish (event)
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local owner = caster:GetPlayerOwner():GetAssignedHero()

	if caster:HasModifier("nexus_super_illusion") then
		Timers:CreateTimer(function()
			local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
			for _,unit in pairs(units) do
				if unit:HasModifier("Nexus_on_ally") then
					unit:RemoveModifierByName("Nexus_on_ally")
					ability:EndCooldown()
					ability:RefundManaCost()
					break
				end
			end
			if owner and target == owner and target:HasModifier("Nexus_on_ally") then target:RemoveModifierByName("Nexus_on_ally") end
		end, DoUniqueString('skoros_nexus_finish'), 0.1)
	end
end

function Remove_Caster_Mana (keys)
	local caster = keys.caster.true_owner
	local ability = keys.event_ability
	local target = keys.target
	local multiplier = ability:GetLevelSpecialValueFor("mana_factor", ability:GetLevel() - 1)
	local mana_spent = ability:GetManaCost(ability:GetLevel() - 1) + 40

	caster:ReduceMana(mana_spent)
	if ability:GetName() == "item_tango" and target:GetTeam() ~= caster:GetTeam() then
		caster:AddNewModifier(caster, nil, "modifier_tango_heal", {Duration = 16.0})
	end

	Timers:CreateTimer(function()
		SyncSpells(keys, true)
	end, DoUniqueString('skoros_nexus_sync'), 0.03)
end

function FindAction( keys )
	local caster = keys.caster
	local ability = keys.event_ability
	local nexus = keys.ability
	local target = keys.target
	local point = keys.target_points[1]
	local owner = caster.true_owner
	local location

	SyncSpells(keys, false)

	if ability then
		if ability == nexus or ability:GetName() == "item_blink" then return end

		Timers:CreateTimer(function()
			if target then
				local units = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, ability:GetCastRange(), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)	
				for _,unit in pairs(units) do
					if unit == owner and ability:GetCastRange() > 0 then return end
				end
			end
			if point and ability:GetCastRange() > 0 then
				local units = FindUnitsInRadius(caster:GetTeam(), point, nil, ability:GetCastRange(), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)	
				for _,unit in pairs(units) do
					if unit == owner and ability:GetCastRange() > 0 then return end
				end
			end

			if target then
				location = target:GetAbsOrigin()
			else 
				location = point
			end

			local units = FindUnitsInRadius(caster:GetTeam(), location, nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)	
			for _,unit in pairs(units) do
				if unit == owner then return end
				if unit:GetUnitName() == caster:GetUnitName() and unit:GetPlayerID() == caster:GetPlayerID() and unit:HasModifier("nexus_super_illusion") then
					unit.item_ability = false
					if target then
						for i = 0, 5 do
							unit.item = unit:GetItemInSlot(i)
							local item_in_caster = caster:GetItemInSlot(i)
							if unit.item and item_in_caster:GetAbilityName() == ability:GetName() then
								if not item_in_caster or item_in_caster:GetName() ~= unit.item:GetName() then
									ResetItems(keys, caster, owner, unit, unit.item)
									return
								else
									if unit.item:RequiresCharges() then
										owner:GetItemInSlot(i):SetCurrentCharges(unit.item:GetCurrentCharges())
									end
									unit:CastAbilityOnTarget(target, unit.item, caster:GetPlayerOwnerID())
									unit.item_ability = true
									Timers:CreateTimer(function()
										owner:Stop()
									end, DoUniqueString('skoros_nexus_cast'), 0.03)
									break
								end
							end
						end
						if not unit.item_ability then
							ability = unit:FindAbilityByName(ability:GetName())
							if ability and ability:IsFullyCastable() then
								unit:CastAbilityOnTarget(target, ability, caster:GetPlayerOwnerID())
								Timers:CreateTimer(function()
									owner:Stop()
								end, DoUniqueString('skoros_nexus_cast'), 0.03)
								break
							end
						end
					elseif point then
						for i = 0, 5 do
							unit.item = unit:GetItemInSlot(i)
							if unit.item and unit.item:GetAbilityName() == ability:GetName() then
								local item_in_caster = caster:GetItemInSlot(i)
								if not item_in_caster or item_in_caster:GetName() ~= unit.item:GetName() then
									ResetItems(keys, caster, owner, unit, unit.item)
									return
								else
									if unit.item:RequiresCharges() then
										owner:GetItemInSlot(i):SetCurrentCharges(unit.item:GetCurrentCharges())
									end
									if ability:GetCastRange() > 1 then
										unit:CastAbilityOnPosition(point, unit.item, -1)
										unit.item_ability = true
										Timers:CreateTimer(function()
											owner:Stop()
										end, DoUniqueString('skoros_nexus_cast'), 0.03)
										break
									else
										unit:CastAbilityImmediately(unit.item, -1)
										unit.item_ability = true
									end
								end
							end
						end
						if not unit.item_ability then
							ability = unit:FindAbilityByName(ability:GetName())
							if ability and ability:IsFullyCastable() then
								if ability:GetCastRange() > 1 then
									unit:CastAbilityOnPosition(point, ability, -1)
									Timers:CreateTimer(function()
										owner:Stop()
									end, DoUniqueString('skoros_nexus_cast'), 0.03)
									break
								end
								break
							end
						end
					end
				end
			end
		end, DoUniqueString('skoros_nexus_spell'), 0.03)
	end
end

function ResetItems(keys, caster, owner, unit, item)
	local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)	
	for _,unit in pairs(units) do
		if unit:GetUnitName() == caster:GetUnitName() and unit:GetPlayerID() == caster:GetPlayerID() and unit:HasModifier("nexus_super_illusion") and unit ~= caster then
			for l = 0, 5 do
				stackable_item = unit:GetItemInSlot(l)
				if stackable_item and stackable_item:IsStackable() then
					unit:RemoveItem(stackable_item)
					local item_created = CreateItem("item_dummy_datadriven", caster, caster)
					unit:AddItem(item_created)
				end
			end
			for i = 0, 5 do
				item_in_unit = unit:GetItemInSlot(i)
				item_in_caster = caster:GetItemInSlot(i)
				
				if item_in_unit then
					unit:RemoveItem(item_in_unit)
				end
				if item_in_caster then
					local item_created = CreateItem( item_in_caster:GetName(), caster, caster)
					unit:AddItem(item_created)
					item_created:SetCurrentCharges(item_in_caster:GetCurrentCharges())
					item_created:StartCooldown(item_in_caster:GetCooldownTimeRemaining())
				else
					local item_created = CreateItem("item_dummy_datadriven", caster, caster)
					unit:AddItem(item_created)
				end
			end
			for j = 0, 5 do
				dummy_in_unit = unit:GetItemInSlot(j)
				if dummy_in_unit and dummy_in_unit:GetName() == "item_dummy_datadriven" then
					unit:RemoveItem(dummy_in_unit)
				end
			end 
		end
	end
end