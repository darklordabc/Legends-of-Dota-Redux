require("lib/animations")
require("lib/timers")
LinkLuaModifier("modifier_totem_damage_loss", "abilities/deathtal/spell_totem", LUA_MODIFIER_MOTION_NONE)

function SpawnTotem( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local totem_name = keys.totem
	local ability_level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local max_totems = ability:GetLevelSpecialValueFor("max_totems", ability_level)

	if caster:HasScepter() then
		max_totems = ability:GetLevelSpecialValueFor("max_totems_scepter", ability_level)
	end

	if caster:FindAbilityByName("special_bonus_unique_max_totems") then
		if caster:FindAbilityByName("special_bonus_unique_max_totems"):GetLevel() > 0 then
			max_totems = max_totems + 1
		end
	end

	local player_id = caster:GetPlayerID()

	local totem = CreateUnitByName(totem_name, target, false, caster, caster, caster:GetTeam())
	FindClearSpaceForUnit(totem, target, true)
	totem:SetControllableByPlayer(player_id, true)
	Timers:CreateTimer(FrameTime(), function()
		ResolveNPCPositions(target, 328)
	end)
	totem:SetForwardVector(caster:GetForwardVector())
	totem:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
	totem:AddNewModifier(caster, ability, "modifier_rooted", {})
	if totem:FindAbilityByName("spell_totem_aura") then
		local spell_totem_aura = totem:FindAbilityByName("spell_totem_aura")
		spell_totem_aura:SetLevel(ability_level + 1)

		totem:SetMaterialGroup("radiant_level6")
		StartAnimation(totem, {activity=ACT_DOTA_CONSTANT_LAYER, duration=16, rate=1.5, translate="level3"})


		local ban_list = LoadKeyValues('scripts/kv/bans.kv')
		for i = 0, caster:GetAbilityCount() do
			if caster:GetAbilityByIndex(i) ~= nil and not ban_list.noSpellTotem[caster:GetAbilityByIndex(i):GetAbilityName()] then
				local a_ability = caster:GetAbilityByIndex(i)
				if not totem:FindAbilityByName(a_ability:GetAbilityName()) then
					totem:AddAbility(a_ability:GetAbilityName())
				end
				local b_ability = totem:FindAbilityByName(a_ability:GetAbilityName())
				b_ability:SetHidden(true)
				b_ability:SetLevel(a_ability:GetLevel())
			end
		end

		if caster:HasScepter() then
			spell_totem_aura:ApplyDataDrivenModifier(caster, totem, "modifier_totem_scepter", {})
		end
	end

	local particle = ParticleManager:CreateParticle(keys.effect, PATTACH_ABSORIGIN, totem)

	if not caster.totem_table then
		caster.totem_table = {}
	end
	local t = caster.totem_table

	t[#t+1] = totem


	if #t > max_totems then
		if not t[1]:IsNull() then
			t[1]:ForceKill(true)
		end
	end
	caster.totem_table = t

	caster:AddNewModifier(caster, ability, "modifier_totem_damage_loss", {})

	for i=1, #t do
		local unit = t[i]
		if unit ~= totem and unit:IsAlive() and caster:FindModifierByName("modifier_totem_damage_loss"):GetStackCount() > unit:FindModifierByName("modifier_totem_damage_loss"):GetStackCount() then
			unit:AddNewModifier(caster, ability, "modifier_totem_damage_loss", {})
		end
		totem:AddNewModifier(caster, ability, "modifier_totem_damage_loss", {})
	end
end

function SpellCasted( keys )
	local caster = keys.caster
	local totem = keys.totem
	local ability = keys.ability
	local event_ability = keys.event_ability
	local event_behavior = event_ability:GetBehavior()
	local cursor_pos = event_ability:GetCursorPosition()

	local ban_list = LoadKeyValues('scripts/kv/bans.kv')

	if event_ability:IsItem() or ban_list.noSpellTotem[event_ability:GetAbilityName()] then return end

	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	for _, unit in pairs(units) do
		if unit:GetUnitName() == totem and unit:GetPlayerOwnerID() == caster:GetPlayerID() then
			local cast_range = event_ability:GetCastRange() + unit:GetCastRangeIncrease()
			local unit_pos = unit:GetAbsOrigin()
			local target_pos = cursor_pos
			if bit.band(event_behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET and keys.target ~= nil then
				unit:SetCursorCastTarget(keys.target)
				target_pos = keys.target:GetAbsOrigin()
			elseif bit.band(event_behavior, DOTA_ABILITY_BEHAVIOR_POINT) == DOTA_ABILITY_BEHAVIOR_POINT then
				unit:SetCursorPosition(cursor_pos)
			else
				unit:SetCursorTargetingNothing(true)
			end
			if bit.band(event_behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) == DOTA_ABILITY_BEHAVIOR_NO_TARGET or (unit_pos - target_pos):Length2D() <= cast_range then
				for i = 0, caster:GetAbilityCount() do
					if caster:GetAbilityByIndex(i) ~= nil and not ban_list.noSpellTotem[caster:GetAbilityByIndex(i):GetAbilityName()] then
						local a_ability = caster:GetAbilityByIndex(i)
						if not unit:FindAbilityByName(a_ability:GetAbilityName()) then
							unit:AddAbility(a_ability:GetAbilityName())
						end
						local b_ability = unit:FindAbilityByName(a_ability:GetAbilityName())
						b_ability:SetHidden(true)
						b_ability:SetLevel(a_ability:GetLevel())
					end
				end
				local unit_ability = unit:FindAbilityByName(event_ability:GetAbilityName())
				unit_ability:OnSpellStart()
				if unit_ability:GetChannelTime() > 0 then
					Timers:CreateTimer(unit_ability:GetChannelTime(), function()
						unit_ability:OnChannelFinish(false)
					end)
				end
			end
		end
	end
end

function TotemScepter( keys )
	local caster = keys.caster
	local ability = keys.ability
	local owner = caster:GetOwnerEntity()

	if owner:HasScepter() and (not caster:FindModifierByName("modifier_totem_scepter")) then
		ability:ApplyDataDrivenModifier(owner, caster, "modifier_totem_scepter", {})
	end
end

function TotemAttacked( keys )
	local attacker = keys.attacker
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local hero_damage = ability:GetSpecialValueFor("hero_damage")
	local creep_damage = ability:GetSpecialValueFor("creep_damage")
	local owner = caster:GetOwnerEntity()

	local damage

	if attacker:IsRealHero() or attacker:IsTower() or attacker:GetUnitName() == "npc_dota_roshan" then
		damage = hero_damage
	else
		damage = creep_damage
	end

	if caster:GetHealth() <= damage then
		caster:Kill(ability, attacker)
	else
		caster:SetHealth(caster:GetHealth() - damage)
	end
end

function TotemDeath( keys )
	local caster = keys.caster
	local ability = keys.ability
	local owner = caster:GetOwnerEntity()

	local particle = ParticleManager:CreateParticle(keys.death_effect, PATTACH_ABSORIGIN, caster)

	for i = 0, caster:GetAbilityCount() do
		local totem_ability = caster:GetAbilityByIndex(i)
		if totem_ability ~= nil then
			if totem_ability:GetChannelTime() > 0 then
				totem_ability:OnChannelFinish(true)
			end
		end
	end

	caster:SetModelScale(0)

	local modifier = owner:FindModifierByName("modifier_totem_damage_loss")
	if owner:FindModifierByName("modifier_totem_damage_loss") then
		modifier:DecrementStackCount()
		if modifier:GetStackCount() < 1 then
			owner:RemoveModifierByName("modifier_totem_damage_loss")
		end

		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

		for _, unit in pairs(units) do
			if unit:FindModifierByName("modifier_totem_damage_loss") and unit ~= owner and unit:GetPlayerOwnerID() == owner:GetPlayerID() then
				local unit_modifier = unit:FindModifierByName("modifier_totem_damage_loss")
				if unit_modifier:GetStackCount() ~= modifier:GetStackCount() then
					unit_modifier:SetStackCount(modifier:GetStackCount())
				end
			end
		end
	end

	local t = owner.totem_table

	for i=1, #t do
		local totem = t[i]
		if totem then
			if totem == caster then
				table.remove(t, i)
			end
		end
	end
end

modifier_totem_damage_loss = class ({})

function modifier_totem_damage_loss:IsDebuff()
	return true
end

function modifier_totem_damage_loss:RemoveOnDeath( keys )
	return false
end

function modifier_totem_damage_loss:OnCreated( keys )
	if IsServer() then
		self:SetStackCount(1)
		local stack_count = self:GetStackCount()
		local damage_loss = self:GetAbility():GetSpecialValueFor("damage_loss")
	end
end

function modifier_totem_damage_loss:OnRefresh( keys )
	if IsServer() then
		self:IncrementStackCount()
		local stack_count = self:GetStackCount()
		local damage_loss = self:GetAbility():GetSpecialValueFor("damage_loss")
	end
end

function modifier_totem_damage_loss:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP
	}
	return funcs
end

function modifier_totem_damage_loss:GetModifierTotalDamageOutgoing_Percentage()
	local stack_count = self:GetStackCount()
	local damage_loss = self:GetAbility():GetSpecialValueFor("damage_loss")
	return 100 * ((1.0 - 0.01 * damage_loss)^stack_count - 1)
end

function modifier_totem_damage_loss:OnTooltip()
	local stack_count = self:GetStackCount()
	local damage_loss = self:GetAbility():GetSpecialValueFor("damage_loss")
	return -100 * ((1.0 - 0.01 * damage_loss)^stack_count - 1)
end
