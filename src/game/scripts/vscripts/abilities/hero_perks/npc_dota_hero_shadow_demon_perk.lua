--------------------------------------------------------------------------------------------------------
--
--		Hero: Shadow Demon
--		Perk: When Shadow Demon buys an item that is limited by stock, he gains a permanent +1 to all attributes. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_shadow_demon_perk", "abilities/hero_perks/npc_dota_hero_shadow_demon_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if npc_dota_hero_shadow_demon_perk ~= "" then npc_dota_hero_shadow_demon_perk = class({}) end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_shadow_demon_perk				
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_shadow_demon_perk ~= "" then modifier_npc_dota_hero_shadow_demon_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsHidden()
	return false 
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:OnCreated(keys)
	-- Hard-coded due to being used in a listener for items purchased. 
	self.limitedItems = {
		item_ward_observer = true,
		item_smoke_of_deceit = true,
		item_tome_of_knowledge = true,
		item_gem = true,
		item_courier = true,
		item_flying_courier = true,
		item_infused_raindrop = true,
	}

	ListenToGameEvent("dota_item_purchased", function(keys)
		local caster = self:GetCaster()
		local hero = PlayerResource:GetPlayer(keys.PlayerID):GetAssignedHero()
		if hero == caster and self.limitedItems[keys.itemname] and hero:HasModifier("modifier_npc_dota_hero_shadow_demon_perk") then
			print("Shadow demon is supporting hard!")
			local modifierName = self:GetName()
			local stacks = self:GetStackCount()
			self:SetStackCount(stacks + 1)
		end
	end, nil)
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:DeclareFunctions()
	return { 
	MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
end

--------------------------------------------------------------------------------------------------------
function perkShadowDemon(filterTable)
	local units = filterTable["units"]
	local order_type = filterTable["order_type"]
	local issuer = filterTable["issuer_player_id_const"]
	local abilityIndex = filterTable["entindex_ability"]
	local targetIndex = filterTable["entindex_target"]

	local ability = EntIndexToHScript(abilityIndex)
	local target = EntIndexToHScript(targetIndex)

	if abilityIndex then
		if order_type == DOTA_UNIT_ORDER_SELL_ITEM and ability then
			local seller = ability:GetPurchaser()
			if seller:HasModifier("modifier_npc_dota_hero_shadow_demon_perk") then
				if seller:IsAlive() or GameRules:GetGameTime() - ability:GetPurchaseTime() < 10 then
					if ability:GetAbilityName() == "item_ward_dispenser" then
						seller:DisassembleItem(ability)
						print("Shadow Demon is trying to abuse game mechanics to gain an advantage, but is failing miserably!")
					elseif ability:HasAbilityFlag("limited") then 
						local modifier = seller:FindModifierByName("modifier_npc_dota_hero_shadow_demon_perk")
						if modifier then
							print("Shadow Demon is trying to abuse game mechanics to gain an advantage, but is failing miserably!")
							local stacks = modifier:GetStackCount()
							local charges = ability:GetCurrentCharges()
							if charges == 0 or ability:GetAbilityName() == "item_infused_raindrop" then charges = 1 end
							seller:SetModifierStackCount(modifier:GetName(), modifier:GetAbility(), stacks - charges)
						end
					end
				else
					print("Shadow Demon is trying to abuse game mechanics to gain an advantage, but is failing miserably!")
					return false
				end
			end
		elseif order_type == DOTA_UNIT_ORDER_GIVE_ITEM and not target:HasInventory() and ability then
			local seller = ability:GetPurchaser()
			if seller:HasModifier("modifier_npc_dota_hero_shadow_demon_perk") then
				if seller:IsAlive() or GameRules:GetGameTime() - ability:GetPurchaseTime() < 10 then
					if ability:GetAbilityName() == "item_ward_dispenser" then
						seller:DisassembleItem(ability)
						print("Shadow Demon is trying to abuse game mechanics to gain an advantage, but is failing miserably!")
					elseif ability:HasAbilityFlag("limited") then 
						local modifier = seller:FindModifierByName("modifier_npc_dota_hero_shadow_demon_perk")
						if modifier then
							print("Shadow Demon is trying to abuse game mechanics to gain an advantage, but is failing miserably!")
							local stacks = modifier:GetStackCount()
							local charges = ability:GetCurrentCharges()
							if charges == 0 or ability:GetAbilityName() == "item_infused_raindrop" then charges = 1 end
							seller:SetModifierStackCount(modifier:GetName(), modifier:GetAbility(), stacks - charges)
						end
					end
				else
					print("Shadow Demon is trying to abuse game mechanics to gain an advantage, but is failing miserably!")
					return false
				end
			end
		end
	end
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:GetModifierBonusStats_Intellect(params)
	return self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:GetModifierBonusStats_Agility(params)
	return self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:GetModifierBonusStats_Strength(params)
	return self:GetStackCount()
end
--------------------------------------------------------------------------------------------------------
