PANORAMA_SHOP_DROPPED_ITEMS_LIMIT = 30

-- First level - shop (by original custom game), second level - tab, third level - category (column), fourth level - item
PANORAMA_SHOP_ITEMS = {
	-- 1 - DOTA
	{
		{
			{
				"item_tpscroll",
				"item_clarity",
				"item_faerie_fire",
				"item_smoke_of_deceit",
				"item_ward_observer",
				"item_ward_sentry",
				"item_enchanted_mango",
				"item_flask",
				"item_tango",
				"item_tome_of_knowledge",
				"item_dust",
				"item_courier",
				"item_bottle",
			},
			{
				"item_branches",
				"item_gauntlets",
				"item_slippers",
				"item_mantle",
				"item_circlet",
				"item_belt_of_strength",
				"item_boots_of_elves",
				"item_robe",
				"item_ogre_axe",
				"item_blade_of_alacrity",
				"item_staff_of_wizardry",
				"item_redux_silver_consume",
			},
			{
				"item_ring_of_protection",
				"item_stout_shield",
				"item_quelling_blade",
				"item_infused_raindrop",
				"item_orb_of_venom",
				"item_blight_stone",
				"item_blades_of_attack",
				"item_chainmail",
				"item_quarterstaff",
				"item_helm_of_iron_will",
				"item_javelin",
				"item_broadsword",
				"item_claymore",
				"item_mithril_hammer",
			},
			{
				"item_magic_stick",
				"item_wind_lace",
				"item_ring_of_regen",
				"item_sobi_mask",
				"item_boots",
				"item_gloves",
				"item_cloak",
				"item_ring_of_health",
				"item_void_stone",
				"item_gem",
				"item_lifesteal",
				"item_shadow_amulet",
				"item_ghost",
				"item_blink",
			},
			{
				"item_energy_booster",
				"item_vitality_booster",
				"item_point_booster",
				"item_platemail",
				"item_talisman_of_evasion",
				"item_hyperstone",
				"item_ultimate_orb",
				"item_demon_edge",
				"item_mystic_staff",
				"item_reaver",
				"item_eagle",
				"item_relic",
			}
		},
		{
			{
				"item_magic_wand",
				"item_null_talisman",
				"item_wraith_band",
				"item_bracer",
				"item_soul_ring",
				"item_redux_silver",
				"item_phase_boots",
				"item_power_treads",
				"item_oblivion_staff",
				"item_pers",
				"item_hand_of_midas",
				"item_travel_boots",
				"item_moon_shard",
			},
			{
				"item_ring_of_basilius",
				"item_headdress",
				"item_buckler",
				"item_urn_of_shadows",
				"item_tranquil_boots",
				"item_ring_of_aquila",
				"item_medallion_of_courage",
				"item_arcane_boots",
				"item_ancient_janggo",
				"item_vladmir",
				"item_mekansm",
				"item_spirit_vessel",
				"item_pipe",
				"item_guardian_greaves",
			},
			{
				"item_glimmer_cape",
				"item_veil_of_discord",
				"item_aether_lens",
				"item_force_staff",
				"item_necronomicon",
				"item_solar_crest",
				"item_dagon",
				"item_cyclone",
				"item_rod_of_atos",
				"item_orchid",
				"item_ultimate_scepter",
				"item_nullifier",
				"item_refresher",
				"item_sheepstick",
				"item_octarine_core",
			},
			{
				"item_hood_of_defiance",
				"item_vanguard",
				"item_blade_mail",
				"item_soul_booster",
				"item_crimson_guard",
				"item_aeon_disk",
				"item_black_king_bar",
				"item_lotus_orb",
				"item_shivas_guard",
				"item_hurricane_pike",
				"item_sphere",
				"item_bloodstone",
				"item_manta",
				"item_heart",
				"item_assault",
			},
			{
				"item_lesser_crit",
				"item_armlet",
				"item_meteor_hammer",
				"item_invis_sword",
				"item_basher",
				"item_bfury",
				"item_monkey_king_bar",
				"item_ethereal_blade",
				"item_radiance",
				"item_greater_crit",
				"item_butterfly",
				"item_silver_edge",
				"item_rapier",
				"item_abyssal_blade",
				"item_bloodthorn",
			},
			{
				"item_dragon_lance",
				"item_sange",
				"item_yasha",
				"item_kaya",
				"item_mask_of_madness",
				"item_helm_of_the_dominator",
				"item_echo_sabre",
				"item_maelstrom",
				"item_diffusal_blade",
				"item_heavens_halberd",
				"item_desolator",
				"item_sange_and_yasha",
				"item_skadi",
				"item_satanic",
				"item_mjollnir",
			}
		}
	},
	-- 2 - Angel Arena Black Star
	--{
	--	{
	--		{
	--			"item_aether_lens_arena",
	--			"item_aether_lens_2",
	--			"item_aether_lens_3",
	--			"item_aether_lens_4",
	--			"item_aether_lens_5",
	--		},
	--		{
	--			"item_steam_footgear",
	--			"item_lucifers_claw",
	--			"item_book_of_the_keeper",
	--			"item_book_of_the_guardian",
	--			"item_lotus_sphere",
	--		}
	--	}
	--}
}

SHOP_LIST_STATUS_IN_INVENTORY = 0
SHOP_LIST_STATUS_IN_STASH = 1
SHOP_LIST_STATUS_TO_BUY = 2
SHOP_LIST_STATUS_NO_STOCK = 3
SHOP_LIST_STATUS_ITEM_DISABLED = 4

if PanoramaShop == nil then
	_G.PanoramaShop = class({})
	PanoramaShop._RawItemData = {}
	PanoramaShop._ItemData = {}
	PanoramaShop.FormattedData = {}
	PanoramaShop.StocksTable = {
		[DOTA_TEAM_GOODGUYS] = {},
		[DOTA_TEAM_BADGUYS] = {},
		[DOTA_TEAM_CUSTOM_1] = {},
		[DOTA_TEAM_CUSTOM_2] = {},
	}
	PanoramaShop.UnitsInShop = {}

	PlayerTables:CreateTable("panorama_shop_data", {}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
end

function PanoramaShop:PushStockInfoToAllClients()
	for team,tt in pairs(PanoramaShop.StocksTable) do
		local ItemStocks = PlayerTables:GetTableValue("panorama_shop_data", "ItemStocks_team" .. team) or {}
		for item,v in pairs(tt) do
			ItemStocks[item] = {
				current_stock = v.current_stock,
				current_cooldown = v.current_cooldown,
				current_last_purchased_time = v.current_last_purchased_time,
			}
		end
		PlayerTables:SetTableValue("panorama_shop_data", "ItemStocks_team" .. team, ItemStocks)
	end
end

function PanoramaShop:GetItemStockCooldown(team, item)
	local t = PanoramaShop.StocksTable[team][item]
	return t ~= nil and (t.current_cooldown - (GameRules:GetGameTime() - t.current_last_purchased_time))
end

function PanoramaShop:GetItemStockCount(team, item)
	local t = PanoramaShop.StocksTable[team][item]
	return t ~= nil and t.current_stock
end

function PanoramaShop:IncreaseItemStock(team, item)
	local t = PanoramaShop.StocksTable[team][item]
	if t and (t.ItemStockMax == -1 or t.current_stock < t.ItemStockMax) then
		t.current_stock = t.current_stock + 1
		if (t.ItemStockMax == -1 or t.current_stock < t.ItemStockMax) then
			PanoramaShop:StackStockableCooldown(team, item, t.ItemStockTime)
		end
		PanoramaShop:PushStockInfoToAllClients()
	end
end

function PanoramaShop:DecreaseItemStock(team, item)
	local t = PanoramaShop.StocksTable[team][item]
	if t and t.current_stock > 0 then
		if t.current_stock == t.ItemStockMax then
			PanoramaShop:StackStockableCooldown(team, item, t.ItemStockTime)
		end
		t.current_stock = t.current_stock - 1
		PanoramaShop:PushStockInfoToAllClients()
	end
end

function PanoramaShop:StackStockableCooldown(team, item, time)
	local t = PanoramaShop.StocksTable[team][item]
	if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		time = time - GameRules:GetDOTATime(false, true)
	end
	t.current_cooldown = time
	t.current_last_purchased_time = GameRules:GetGameTime()
	Timers:CreateTimer(time, function()
		PanoramaShop:IncreaseItemStock(team, item)
	end)
end

function PanoramaShop:InitializeItemTable()
	local RecipesToCheck = {}
	-- loading all items and splitting them by item/recipe
	for name, kv in pairs(KeyValues.ItemKV) do
		if type(kv) == "table" and (kv.ItemPurchasable or 1) == 1 then
			if kv.ItemRecipe == 1 then
				RecipesToCheck[kv.ItemResult] = name
			end
			PanoramaShop._RawItemData[name] = kv
		end
	end
	-- adding data for each item
	local itemsBuldsInto = {}
	for name, kv in pairs(PanoramaShop._RawItemData) do
		local itemdata = {
			id = kv.ID or -1,
			purchasable = true,
			cost = GetTrueItemCost(name),
			names = {name:lower()},
		}

		if kv.ItemAliases then
			for _,v in ipairs(util:split(kv.ItemAliases, ";")) do
				if not util:contains(itemdata.names, v:lower()) then
					table.insert(itemdata.names, v:lower())
				end
			end
		end

		if RecipesToCheck[name] then
			local recipedata = {
				visible = GetTrueItemCost(RecipesToCheck[name]) > 0,
				items = {},
				cost = GetTrueItemCost(RecipesToCheck[name]),
				recipeItemName = RecipesToCheck[name],
			}
			local recipeKv = KeyValues.ItemKV[RecipesToCheck[name]]

			if not itemsBuldsInto[RecipesToCheck[name]] then itemsBuldsInto[RecipesToCheck[name]] = {} end
			if not util:contains(itemsBuldsInto[RecipesToCheck[name]], name) then
				table.insert(itemsBuldsInto[RecipesToCheck[name]], name)
			end
			for key, ItemRequirements in pairsByKeys(recipeKv.ItemRequirements) do
				local itemParts = util:split(string.gsub(ItemRequirements, " ", ""), ";")
				if not util:contains(itemParts, name) then
					table.insert(recipedata.items, itemParts)
				else
					print(name .. " has a recipe with itself, ignoring")
				end
				for _,v in ipairs(itemParts) do
					if not itemsBuldsInto[v] then itemsBuldsInto[v] = {} end
					if not util:contains(itemsBuldsInto[v], name) then
						table.insert(itemsBuldsInto[v], name)
					end
				end
			end
			itemdata.Recipe = recipedata
		end
		if kv.ItemStockMax or kv.ItemStockTime or kv.ItemInitialStockTime or kv.ItemStockInitial then
			local stocks = {
				ItemStockMax = kv.ItemStockMax or -1,
				ItemStockTime = kv.ItemStockTime or 0,
				current_stock = kv.ItemStockInitial,
				current_cooldown = kv.ItemInitialStockTime or 0,
				current_last_purchased_time = -1,
			}
			if not stocks.current_stock then
				if stocks.current_cooldown == 0 then
					stocks.current_stock = kv.ItemStockInitial or kv.ItemStockMax or 0
				else
					stocks.current_stock = 0
				end
			end
			for k,_ in pairs(PanoramaShop.StocksTable) do
				PanoramaShop.StocksTable[k][name] = {}
				util:MergeTables(PanoramaShop.StocksTable[k][name], stocks)
			end
		end
		PanoramaShop.FormattedData[name] = itemdata
	end
	--[[ for unit,itemlist in pairs(DROP_TABLE) do
		for _,v in ipairs(itemlist) do
			local iteminfo = PanoramaShop.FormattedData[v.Item]
			if iteminfo.Recipe then
				print("[PanoramaShop] Item that has recipe is defined in unit drop table", itemName)
			else
				if not iteminfo.DropListData then
					iteminfo.DropListData = {}
				end
				if not iteminfo.DropListData[unit] then
					iteminfo.DropListData[unit] = {}
				end

				table.insert(iteminfo.DropListData[unit], v.DropChance)
			end
		end
	end ]]
	for name,items in pairs(itemsBuldsInto) do
		if PanoramaShop.FormattedData[name] then
			PanoramaShop.FormattedData[name].BuildsInto = items
		end
	end
	-- checking all items in shop list
	local Items = {}
	for shopName, shopData in pairs(PANORAMA_SHOP_ITEMS) do
		Items[shopName] = {}
		for tabName, tabData in pairs(shopData) do
			Items[shopName][tabName] = {}
			for groupName, groupData in pairs(tabData) do
				Items[shopName][tabName][groupName] = {}
				for _, itemName in ipairs(groupData) do
					if not PanoramaShop.FormattedData[itemName] and itemName ~= "__indent__" then
						print("[PanoramaShop] Item defined in shop list is not defined in any of item KV files", itemName)
					else
						table.insert(Items[shopName][tabName][groupName], itemName)
					end
				end
			end
		end
	end
	PanoramaShop._ItemData = Items
	CustomGameEventManager:RegisterListener("panorama_shop_item_buy", Dynamic_Wrap(PanoramaShop, "OnItemBuy"))
	PlayerTables:SetTableValues("panorama_shop_data", {ItemData = util:DeepCopy(PanoramaShop.FormattedData), ShopList = Items})
	PanoramaShop:PushStockInfoToAllClients()
end

function PanoramaShop:SetItemsPurchasable(items, purchasable, playerID)
	for _, item in pairs(items) do
		local results = PanoramaShop:RecursiveSetItemPurchasable(item, purchasable, playerID)
		for text, result in pairs(results) do
			if #result > 0 then
				for k,v in pairs(result) do
					result[k] = "DOTA_Tooltip_ability_" .. v
				end

				network:sendNotification(PlayerResource:GetPlayer(playerID), {
					sort = "lodInfo",
					text = text,
					list = {
						separator = ", ",
						elements = result
					}
				})
			end
		end
	end

	PlayerTables:SetTableValue("panorama_shop_data", "ItemData", util:DeepCopy(PanoramaShop.FormattedData))
end

function PanoramaShop:RecursiveSetItemPurchasable(item, purchasable, playerID)
	local modifiedItems = { lodInfoRequiredEnabled = {}, lodInfoDerivativeDisabled = {}, lodInfoDerivativeEnabled = {} }
	if not PanoramaShop.FormattedData[item] then return modifiedItems end
	if PanoramaShop.FormattedData[item].purchasable == purchasable then return modifiedItems end
	local recipeName = item:gsub("item_", "item_recipe_")

	if PanoramaShop.FormattedData[recipeName] then
		-- 0 cost recipe means that item can be built just from it's components, so shop can't disable it
		if not purchasable and PanoramaShop.FormattedData[recipeName].cost == 0 then
			-- Recursive disabled items shouldn't do notifications
			if playerID then
				local requiredItems = {}
				for _, itemComponents in ipairs(PanoramaShop.FormattedData[item].Recipe.items) do
					for _,v in ipairs(itemComponents) do
						local str = "DOTA_Tooltip_ability_" .. v
						if not util:contains(requiredItems, str) then
							table.insert(requiredItems, str)
						end
					end
				end
				network:sendNotification(PlayerResource:GetPlayer(playerID), {
					sort = "lodDanger",
					text = "lodFailedDisableItem",
					params = {
						["abilityName"] = "DOTA_Tooltip_ability_" .. item
					},
					list = {
						separator = ", ",
						elements = requiredItems
					}
				})
				GameRules.pregame:PlayAlert(playerID)
				return modifiedItems
			else
				local canDisable = false
				for _, itemComponents in ipairs(PanoramaShop.FormattedData[item].Recipe.items) do
					canDisable = false
					for _,v in ipairs(itemComponents) do
						if not PanoramaShop.FormattedData[v].purchasable then
							canDisable = true
						end
					end
				end
				if not canDisable then
					return modifiedItems
				end
			end
		end
		PanoramaShop.FormattedData[recipeName].purchasable = purchasable
		PanoramaShop.FormattedData[item].purchasable = purchasable
	end
	PanoramaShop.FormattedData[item].purchasable = purchasable

	if purchasable then
		-- Enabling an item should also enable all it's required items
		if PanoramaShop.FormattedData[item].Recipe then
			for _, itemComponents in ipairs(PanoramaShop.FormattedData[item].Recipe.items) do
				for _,v in ipairs(itemComponents) do
					table.insert(modifiedItems.lodInfoRequiredEnabled, v)
					for _,v in ipairs(self:RecursiveSetItemPurchasable(v, true).lodInfoRequiredEnabled) do
						table.insert(modifiedItems.lodInfoRequiredEnabled, v)
					end
				end
			end
		end
		-- And enable all items it builds to (only if it's the only missing component)
		-- This function already has too much repeative code. TODO: Refactor it
		for _,itemBuiltTo in ipairs(PanoramaShop.FormattedData[item].BuildsInto or {}) do
			local canEnable = true
			for _, itemComponents in ipairs(PanoramaShop.FormattedData[itemBuiltTo].Recipe.items) do
				canEnable = true
				for _,v in ipairs(itemComponents) do
					if v ~= item and not PanoramaShop.FormattedData[v].purchasable then
						canEnable = false
					end
				end
			end
			if canEnable then
				table.insert(modifiedItems.lodInfoDerivativeEnabled, itemBuiltTo)
				for _,v in ipairs(self:RecursiveSetItemPurchasable(itemBuiltTo, true).lodInfoDerivativeEnabled) do
					table.insert(modifiedItems.lodInfoDerivativeEnabled, v)
				end
			end
		end
	else
		-- Disabling an item should also disable all items it builds to
		for _,v in ipairs(PanoramaShop.FormattedData[item].BuildsInto or {}) do
			table.insert(modifiedItems.lodInfoDerivativeDisabled, v)
			for _,v in ipairs(self:RecursiveSetItemPurchasable(v, false).lodInfoDerivativeDisabled) do
				table.insert(modifiedItems.lodInfoDerivativeDisabled, v)
			end
		end
	end

	return modifiedItems
end

function PanoramaShop:StartItemStocks()
	for team,v in pairs(PanoramaShop.StocksTable) do
		for item,stocks in pairs(v) do
			if stocks.current_cooldown > 0 then
				PanoramaShop:StackStockableCooldown(team, item, stocks.current_cooldown)
			elseif stocks.ItemStockMax == -1 or stocks.current_stock < stocks.ItemStockMax then
				PanoramaShop:StackStockableCooldown(team, item, stocks.ItemStockTime)
			end
		end
	end
	PanoramaShop:PushStockInfoToAllClients()
end

function PanoramaShop:OnItemBuy(data)
	if data and data.itemName and data.unit then
		local ent = EntIndexToHScript(data.unit)
		if ent and ent.entindex and (ent:GetPlayerOwner() == PlayerResource:GetPlayer(data.PlayerID) or ent == FindCourier(PlayerResource:GetTeam(data.PlayerID))) then
			PanoramaShop:BuyItem(data.PlayerID, ent, data.itemName)
		end
	end
end

function PanoramaShop:SellItem(unit, item)
	local cost = item:GetCost()
	local playerID = UnitVarToPlayerID(unit)
	if not item:IsSellable() --[[ or MeepoFixes:IsMeepoClone(unit) ]] then
		util:DisplayError(playerID, "dota_hud_error_cant_sell_item")
		return
	end
	if item:IsStackable() then
		local chargesRate = item:GetCurrentCharges() / item:GetInitialCharges()
		cost = cost * chargesRate
	end
	if GameRules:GetGameTime() - item:GetPurchaseTime() > 10 then
		cost = cost / 2
	end
	UTIL_Remove(item)
	PlayerResource:ModifyGold(playerID, cost, false, 0)
	local player = PlayerResource:GetPlayer(playerID)
	SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, unit, math.floor(gold), player)
end

function PanoramaShop:PushItem(playerID, unit, itemName, bOnlyStash)
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	local team = PlayerResource:GetTeam(playerID)
	local item = CreateItem(itemName, hero, hero)
	local isInShop = PanoramaShop.UnitsInShop[unit]
	item:SetPurchaseTime(GameRules:GetGameTime())
	item:SetPurchaser(hero)

	local itemPushed = false
	--If unit has slot for that item
	if isInShop and not bOnlyStash then
		if unit:UnitHasSlotForItem(itemName, true) then
			unit:AddItem(item)
			itemPushed = true
		end
	end

	--Try to add item to hero's stash
	if not itemPushed then
		-- Stackable item abuse fix, not very good, but that's all I can do without smth like SetStackable
		local hasSameStackableItem = item:IsStackable() and unit:HasItemInInventory(itemName)
		if hasSameStackableItem then
			Notifications:Bottom(playerID, {text="panorama_shop_stackable_purchase", style = {color = "red"}, duration = 4.5})
		else
			if not isInShop then SetAllItemSlotsLocked(unit, true, true) end
			FillSlotsWithDummy(unit, false)
			for i = DOTA_STASH_SLOT_1 , DOTA_STASH_SLOT_6 do
				local current_item = unit:GetItemInSlot(i)
				if current_item and current_item:GetAbilityName() == "item_dummy" then
					UTIL_Remove(current_item)
					unit:AddItem(item)
					itemPushed = true
					break
				end
			end
			ClearSlotsFromDummy(unit, false)
			if not isInShop then SetAllItemSlotsLocked(unit, false, true) end
		end
	end
	--At last drop an item on fountain
	if not itemPushed then
		local spawnPointName = "info_courier_spawn"
		local teamCared = true
		if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
			spawnPointName = "info_courier_spawn_radiant"
			teamCared = false
		elseif PlayerResource:GetTeam(playerID) == DOTA_TEAM_BADGUYS then
			spawnPointName = "info_courier_spawn_dire"
			teamCared = false
		end
		local ent
		while true do
			ent = Entities:FindByClassname(ent, spawnPointName)
			if ent and (not teamCared or (teamCared and ent:GetTeam() == PlayerResource:GetTeam(playerID))) then
				CreateItemOnPositionSync(ent:GetAbsOrigin() + RandomVector(RandomInt(0, 300)), item)
				break
			end
		end
	end
end

function PanoramaShop:GetNumDroppedItemsForPlayer(playerID)
	local droppedItems = 0
	for i = 0, GameRules:NumDroppedItems() - 1 do
		local item = GameRules:GetDroppedItem(i):GetContainedItem()
		if IsValidEntity(item) then
			local owner = item:GetPurchaser()
			if IsValidEntity(owner) and owner:GetPlayerID() == playerID then
				droppedItems = droppedItems + 1
			end
		end
	end
	return droppedItems
end

function PanoramaShop:GetAllItemsByNameInInventory(unit, itemname, bBackpack)
	local items = {}
	for slot = 0, bBackpack and DOTA_STASH_SLOT_6 or DOTA_ITEM_SLOT_9 do
		local item = unit:GetItemInSlot(slot)
		if item and item:GetAbilityName() == itemname and item:GetPurchaser() == unit then
			table.insert(items, item)
		end
	end
	return items
end

function PanoramaShop:GetAllPrimaryRecipeItems(unit, childItemName, baseItemName)
	local primary_items = {}
	local itemData = PanoramaShop.FormattedData[childItemName]
	local _tempItemCounter = {}
	_tempItemCounter[childItemName] = (_tempItemCounter[childItemName] or 0) + 1

	--local itemcount_all = #PanoramaShop:GetAllItemsByNameInInventory(unit, childItemName, true)
	local itemcount = #PanoramaShop:GetAllItemsByNameInInventory(unit, childItemName, true)
	--isInShop and itemcount_all or itemcount_all - #PanoramaShop:GetAllItemsByNameInInventory(unit, childItemName, false)
	if (childItemName == baseItemName or itemcount < _tempItemCounter[childItemName]) and itemData.Recipe then
		for _, newchilditem in ipairs(itemData.Recipe.items[1]) do
			local subitems, newCounter = PanoramaShop:GetAllPrimaryRecipeItems(unit, newchilditem, baseItemName)
			table.add(primary_items, subitems)
			for k,v in pairs(newCounter) do
				_tempItemCounter[k] = (_tempItemCounter[k] or 0) + v
			end
		end
		if itemData.Recipe.cost > 0 then
			table.insert(primary_items, itemData.Recipe.recipeItemName)
			_tempItemCounter[itemData.Recipe.recipeItemName] = (_tempItemCounter[itemData.Recipe.recipeItemName] or 0) + 1
		end
	end
	table.insert(primary_items, childItemName)
	return primary_items, _tempItemCounter
end

function PanoramaShop:HasAnyOfItemChildren(unit, team, childItemName, baseItemName)
	if not PanoramaShop.FormattedData[childItemName].Recipe then return false end
	local primary_items = PanoramaShop:GetAllPrimaryRecipeItems(unit, childItemName, baseItemName)
	util:removeByValue(primary_items, childItemName)
	for _,v in ipairs(primary_items) do
		local stocks = PanoramaShop:GetItemStockCount(team, v)
		if FindItemInInventoryByName(unit, v, true) or not PanoramaShop.FormattedData[v].purchasable or stocks then
			return true
		end
	end
	return false
end

function PanoramaShop:BuyItem(playerID, unit, itemName)
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	local team = PlayerResource:GetTeam(playerID)
	--[[ if Duel:IsDuelOngoing() then
		util:DisplayError(playerID, "#dota_hud_error_cant_purchase_duel_ongoing")
		return
	end ]]

	if PanoramaShop:GetNumDroppedItemsForPlayer(playerID) >= PANORAMA_SHOP_DROPPED_ITEMS_LIMIT then
		util:DisplayError(playerID, "#dota_hud_error_panorama_shop_dropped_items_limit")
		return
	end

	if unit:IsIllusion() or not unit:HasInventory() then
		unit = hero
	end
	local isInShop = unit:HasModifier("modifier_fountain_aura_arena")

	local itemCounter = {}
	local ProbablyPurchasable = {}

	function DefineItemState(name)
		local has = PanoramaShop:HasAnyOfItemChildren(unit, team, name, itemName)
		--print(name, has)
		if has then
			InsertItemChildrenToCheck(name)
		else
			itemCounter[name] = (itemCounter[name] or 0) + 1
			local itemcount_inv = #PanoramaShop:GetAllItemsByNameInInventory(unit, name, false)
			local itemcount_stash = #PanoramaShop:GetAllItemsByNameInInventory(unit, name, true) - itemcount_inv
			local stocks = PanoramaShop:GetItemStockCount(team, name)
			if name ~= itemName and itemcount_stash >= itemCounter[name] then
				ProbablyPurchasable[name .. "_index_" .. itemCounter[name]] = SHOP_LIST_STATUS_IN_STASH
			elseif name ~= itemName and itemcount_inv >= itemCounter[name] then
				ProbablyPurchasable[name .. "_index_" .. itemCounter[name]] = SHOP_LIST_STATUS_IN_INVENTORY
			elseif not PanoramaShop.FormattedData[name].purchasable then
				ProbablyPurchasable[name .. "_index_" .. itemCounter[name]] = SHOP_LIST_STATUS_ITEM_DISABLED
			elseif stocks and stocks < 1 then
				ProbablyPurchasable[name .. "_index_" .. itemCounter[name]] = SHOP_LIST_STATUS_NO_STOCK
			else
				ProbablyPurchasable[name .. "_index_" .. itemCounter[name]] = SHOP_LIST_STATUS_TO_BUY
			end
		end
	end

	function InsertItemChildrenToCheck(name)
		local itemData = PanoramaShop.FormattedData[name]
		if itemData.Recipe then
			for _, newchilditem in ipairs(itemData.Recipe.items[1]) do
				DefineItemState(newchilditem)
			end
			if itemData.Recipe.cost > 0 then
				DefineItemState(itemData.Recipe.recipeItemName)
			end
		end
	end

	DefineItemState(itemName)

	local ItemsInInventory = {}
	local ItemsInStash = {}
	local ItemsToBuy = {}
	local wastedGold = 0
	for name,status in pairs(ProbablyPurchasable) do
		name = string.gsub(name, "_index_%d+", "")
		if status == SHOP_LIST_STATUS_ITEM_DISABLED then
			util:DisplayError(playerID, "dota_hud_error_panorama_shop_item_disabled")
			return
		elseif status == SHOP_LIST_STATUS_NO_STOCK then
			util:DisplayError(playerID, "dota_hud_error_item_out_of_stock")
			return
		elseif status == SHOP_LIST_STATUS_TO_BUY then
			wastedGold = wastedGold + GetTrueItemCost(name)
			table.insert(ItemsToBuy, name)
		elseif status == SHOP_LIST_STATUS_IN_INVENTORY then
			table.insert(ItemsInInventory, name)
		elseif status == SHOP_LIST_STATUS_IN_STASH then
			table.insert(ItemsInStash, name)
		end
	end

	if PlayerResource:GetGold(playerID) >= wastedGold then
		util:EmitSoundOnClient(playerID, "General.Buy")
		PlayerResource:SpendGold(playerID, wastedGold, 0)

		if isInShop then
			for _,v in ipairs(ItemsInStash) do
				local removedItem = FindItemInInventoryByName(unit, v, true, not isInShop)
				if not removedItem then removedItem = FindItemInInventoryByName(unit, v, false) end
				unit:RemoveItem(removedItem)
			end
			for _,v in ipairs(ItemsInInventory) do
				local removedItem = FindItemInInventoryByName(unit, v, false)
				if not removedItem then removedItem = FindItemInInventoryByName(unit, v, true, true) end
				unit:RemoveItem(removedItem)
			end
			PanoramaShop:PushItem(playerID, unit, itemName)
			if PanoramaShop.StocksTable[team][itemName] then
				PanoramaShop:DecreaseItemStock(team, itemName)
			end
		elseif #ItemsInInventory == 0 and #ItemsInStash > 0 then
			for _,v in ipairs(ItemsInStash) do
				unit:RemoveItem(FindItemInInventoryByName(unit, v, true, false))
			end
			PanoramaShop:PushItem(playerID, unit, itemName, true)
			if PanoramaShop.StocksTable[team][itemName] then
				PanoramaShop:DecreaseItemStock(team, itemName)
			end
		else
			for _,v in ipairs(ItemsToBuy) do
				PanoramaShop:PushItem(playerID, unit, v)
				if PanoramaShop.StocksTable[team][v] then
					PanoramaShop:DecreaseItemStock(team, v)
				end
			end
		end
	end
end

function GetTrueItemCost(name)
	local cost = GetItemCost(name)
	if cost <= 0 then
		local tempItem = CreateItem(name, nil, nil)
		if not tempItem then
			print("[GetTrueItemCost] Warning: " .. name)
		else
			cost = tempItem:GetCost()
			UTIL_Remove(tempItem)
		end
	end
	return cost
end

function FillSlotsWithDummy(unit, bNoStash)
	for i = 0, bNoStash and DOTA_ITEM_SLOT_9 or DOTA_STASH_SLOT_6 do
		local current_item = unit:GetItemInSlot(i)
		if not current_item then
			unit:AddItemByName("item_dummy")
		end
	end
end

function ClearSlotsFromDummy(unit, bNoStash)
	for i = 0, bNoStash and DOTA_ITEM_SLOT_9 or DOTA_STASH_SLOT_6 do
		local current_item = unit:GetItemInSlot(i)
		if current_item and current_item:GetAbilityName() == "item_dummy" then
			unit:RemoveItem(current_item)
			UTIL_Remove(current_item)
		end
	end
end

function SetAllItemSlotsLocked(unit, locked, bNoStash)
	for i = 0, bNoStash and DOTA_ITEM_SLOT_9 or DOTA_STASH_SLOT_6 do
		local current_item = unit:GetItemInSlot(i)
		if current_item then
			ExecuteOrderFromTable({
				UnitIndex = unit:GetEntityIndex(),
				OrderType = DOTA_UNIT_ORDER_SET_ITEM_COMBINE_LOCK,
				AbilityIndex = current_item:GetEntityIndex(),
				TargetIndex = locked and 1 or 0,
				Queue = false
			})
		end
	end
end

function CDOTA_BaseNPC:UnitHasSlotForItem(itemname, bBackpack)
	if self.HasRoomForItem then
		return self:HasRoomForItem(itemname, bBackpack, true) ~= 4
	else
		for i = 0, bBackpack and DOTA_STASH_SLOT_6 or DOTA_ITEM_SLOT_9 do
			local item = self:GetItemInSlot(i)
			if not IsValidEntity(item) or (item:GetAbilityName() == itemname and item:IsStackable()) then
				return true
			end
		end
		return false
	end
end

function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0
	local iter = function()
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end

function table.add(input1, input2)
	for _,v in ipairs(input2) do
		table.insert(input1, v)
	end
end

function FindItemInInventoryByName(unit, itemname, searchStash, onlyStash, ignoreBackpack)
	local lastSlot = ignoreBackpack and DOTA_ITEM_SLOT_6 or DOTA_ITEM_SLOT_9
	local startSlot = 0
	if searchStash then lastSlot = DOTA_STASH_SLOT_6 end
	if onlyStash then startSlot = DOTA_STASH_SLOT_1 end
	for slot = startSlot, lastSlot do
		local item = unit:GetItemInSlot(slot)
		if item and item:GetAbilityName() == itemname then
			return item
		end
	end
end
