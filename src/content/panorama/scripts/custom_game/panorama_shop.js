var Util = GameUI.CustomUIConfig().Util;
var PlayerTables = GameUI.CustomUIConfig().PlayerTables;

var ItemList = {},
	ItemData = {},
	SmallItems = [],
	SmallItemsAlwaysUpdated = [],
	SearchingFor = null,
	QuickBuyTarget = null,
	QuickBuyTargetAmount = 0,
	LastHero = null,
	ItemStocks = [];

var console = {
	log: function() {
		var args = Array.prototype.slice.call(arguments);
		return $.Msg(args.map(function(x) {return typeof x === 'object' ? JSON.stringify(x, null, 4) : x;}).join('\t'));
	},
	error: function() {
		Array.prototype.forEach.call(arguments, function(arg) {
			console.log(arg instanceof Error ? arg.stack : new Error(arg).stack);
		});
	}
};

function OpenCloseShop(newState) {
	if (typeof newState !== 'boolean') newState = !$('#ShopBase').BHasClass('ShopBaseOpen');
	$('#ShopBase').SetHasClass('ShopBaseOpen', newState);

	if (newState) {
		Game.EmitSound('Shop.PanelUp');
		UpdateShop();
		//$("#ShopBase").SetFocus();
	} else {
		Game.EmitSound('Shop.PanelDown');
		ClearSearch();
	}
}

function ClearSearch() {
	$.DispatchEvent('DropInputFocus', $('#ShopSearchEntry'));
	$('#ShopSearchEntry').text = '';
}

function SearchItems() {
	var searchStr = $('#ShopSearchEntry').text.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&');
	if (SearchingFor !== searchStr) {
		SearchingFor = searchStr;
		var ShopSearchOverlay = $('#ShopSearchOverlay');
		$.Each(ShopSearchOverlay.Children(), function(child) {
			child.DestroyItemPanel();
		});
		$.GetContextPanel().SetHasClass('InSearchMode', searchStr.length > 0);
		if (searchStr.length > 0) {
			var searchRegExp = new RegExp(searchStr, 'i');
			var foundItems = Object.keys(ItemData).filter(function(itemName) {
				var localizedName = $.Localize('DOTA_Tooltip_ability_' + itemName);
				return itemName.lastIndexOf('item_recipe_', 0) !== 0 &&
					Object.keys(ItemData[itemName].names)
						.map(function(key) { return ItemData[itemName].names[key] })
						.concat(localizedName)
						.some(function (title) {
							return title.search(searchRegExp) > -1;
						});
			});

			foundItems.sort(function(x1, x2) {
				return ItemData[x1].cost - ItemData[x2].cost;
			});

			$.Each(foundItems, function(itemName) {
				SnippetCreate_SmallItem($.CreatePanel('Panel', ShopSearchOverlay, 'ShopSearchOverlay_item_' + itemName), itemName);
			});
		}
	}
}

function PushItemsToList() {
	var isShopPageSelected = false;
	// Get array of tab names which has > 0 active items
	var enabledPages = Object.keys(ItemList)
		.filter(function(shopName) {
			var shopContent = ItemList[shopName];
			for (var tabName in shopContent) {
				for (var groupName in shopContent[tabName]) {
					for (var itemIndex in shopContent[tabName][groupName]) {
						var itemName = shopContent[tabName][groupName][itemIndex];
						if (ItemData[itemName] && ItemData[itemName].purchasable) {
							return true;
						}
					}
				}
			}

			return false;
		});

	$.Each(enabledPages, function(shopName) {
		var shopContent = ItemList[shopName];
		var TabButton;

		// Don't show tab list when only one tab enabled
		if (enabledPages.length > 1) {
			TabButton = $.CreatePanel('RadioButton', $('#ShopPagesList'), '');
			TabButton.BLoadLayoutSnippet('ShopPageButton');
			TabButton.FindChildTraverse('ButtonImage').SetImage('file://{images}/custom_game/shop/page_' + shopName + '.png');
			TabButton.SetPanelEvent('onactivate', function() {
				SelectShopPage(shopName);
			});
		}

		var TabShopItemlistPanel = $.CreatePanel('Panel', $('#ShopPagesHost'), shopName);
		TabShopItemlistPanel.BLoadLayoutSnippet('ShopPage');
		FillShopPage(TabShopItemlistPanel, shopName, shopContent);

		if (!isShopPageSelected) {
			if (TabButton) TabButton.checked = true;
			SelectShopPage(shopName);
			isShopPageSelected = true;
		}
	});
}

function SelectShopPage(shopName) {
	$.Each($('#ShopPagesHost').Children(), function(child) {
		child.SetHasClass('SelectedPage', child.id === shopName);
	});
}

function FillShopPage(panel, shopName, shopContent) {
	var isTabSelected = false;
	$.Each(shopContent, function(tabContent, tabName) {
		tabName = tabName + '';
		var id = 'shop_' + shopName + '_tab_' + tabName;
		panel.FindChildTraverse('ShopTabs').BCreateChildren('<RadioButton class="ShopTabButton" id="' + id + '" group="shop_' + shopName + '"/>');
		var TabButton = panel.FindChildTraverse(id);
		TabButton.style.width = (100 / Object.keys(shopContent).length) + '%';
		var TabButtonLabel = $.CreatePanel('Label', TabButton, '');
		TabButtonLabel.text = $.Localize('panorama_shop_' + id);
		TabButtonLabel.hittest = false;
		var TabShopItemlistPanel = $.CreatePanel('Panel', panel.FindChildTraverse('ShopItems'), 'shop_panels_tab_' + tabName);
		TabShopItemlistPanel.AddClass('ItemsPageInnerContainer');
		FillShopTable(TabShopItemlistPanel, tabContent);
		TabButton.SetPanelEvent('onactivate', function() {
			SelectShopTab(panel, tabName);
		});

		if (!isTabSelected) {
			SelectShopTab(panel, tabName);
			TabButton.checked = true;
			isTabSelected = true;
		}
	});
}

function SelectShopTab(panel, tabName) {
	$.Each(panel.FindChildTraverse('ShopItems').Children(), function(child) {
		child.SetHasClass('SelectedPage', child.id.replace('shop_panels_tab_', '') === tabName);
	});
}

function FillShopTable(panel, shopData) {
	for (var groupName in shopData) {
		var groupPanel = $.CreatePanel('Panel', panel, panel.id + '_group_' + groupName);
		groupPanel.AddClass('ShopItemGroup');
		$.Each(shopData[groupName], function(itemName) {
			var itemPanel = $.CreatePanel('Panel', groupPanel, groupPanel.id + '_item_' + itemName);
			SnippetCreate_SmallItem(itemPanel, itemName);
			//groupPanel.AddClass("ShopItemGroup")
		});
	}
}

function SnippetCreate_SmallItem(panel, itemName, skipPush, onDragStart, onDragEnd) {
	panel.BLoadLayoutSnippet('SmallItem');
	if (itemName === '__indent__') {
		panel.style.opacity = 0;
		return;
	}
	panel.itemName = itemName;
	panel.FindChildTraverse('SmallItemImage').itemname = itemName;
	if (itemName.lastIndexOf('item_recipe', 0) === 0)
		panel.FindChildTraverse('SmallItemImage').SetImage('raw://resource/flash3/images/items/recipe.png');
	panel.SetPanelEvent('onactivate', function() {
		if (!$.GetContextPanel().BHasClass('InSearchMode')) {
			$('#ShopBase').SetFocus();
		}
		if (GameUI.IsAltDown()) {
			GameEvents.SendCustomGameEventToServer('custom_chat_send_message', {
				shop_item_name: panel.IsInQuickbuy ? QuickBuyTarget : itemName,
				isQuickbuy: panel.IsInQuickbuy,
				gold: GetRemainingPrice(panel.IsInQuickbuy ? QuickBuyTarget : itemName, {})
			});
		} else {
			ShowItemRecipe(itemName);
			if (GameUI.IsShiftDown()) {
				SetQuickbuyTarget(itemName);
			}
		}
	});
	panel.SetPanelEvent('oncontextmenu', function() {
		if (panel.BHasClass('CanBuy')) {
			SendItemBuyOrder(itemName);
		} else {
			GameEvents.SendEventClientSide('dota_hud_error_message', {
				'splitscreenplayer': 0,
				'reason': 80,
				'message': '#dota_hud_error_not_enough_gold'
			});
			Game.EmitSound('General.NoGold');
		}
	});
	panel.SetPanelEvent('onmouseover', function() {
		ItemShowTooltip(panel);
	});
	panel.SetPanelEvent('onmouseout', function() {
		ItemHideTooltip(panel);
	});
	panel.DestroyItemPanel = function() {
		var id1 = SmallItemsAlwaysUpdated.indexOf(panel);
		var id2 = SmallItems.indexOf(panel);
		if (id1 > -1)
			SmallItemsAlwaysUpdated.splice(id1, 1);
		if (id2 > -1)
			SmallItems.splice(id2, 1);
		panel.visible = false;
		panel.DeleteAsync(0);
	};
	if (!panel.IsInQuickbuy) {
		$.RegisterEventHandler('DragStart', panel, function(panelId, dragCallbacks) {
			var itemName = panel.itemName;
			if (!onDragStart || onDragStart(panel)) {
				$.GetContextPanel().AddClass('DropDownMode');
				ItemHideTooltip(panel);
				var displayPanel = $.CreatePanel('DOTAItemImage', panel, 'dragImage');
				displayPanel.itemname = itemName;
				if (itemName.lastIndexOf('item_recipe_', 0) === 0)
					displayPanel.SetImage('raw://resource/flash3/images/items/recipe.png');

				dragCallbacks.displayPanel = displayPanel;
				dragCallbacks.offsetX = 0;
				dragCallbacks.offsetY = 0;
				return true;
			}
			return false;
		});

		$.RegisterEventHandler('DragEnd', panel, function(panelId, draggedPanel) {
			$.GetContextPanel().RemoveClass('DropDownMode');
			draggedPanel.DeleteAsync(0);
			!onDragEnd || onDragEnd(panel);
			return true;
		});
	}
	UpdateSmallItem(panel);
	if (!skipPush)
		SmallItems.push(panel);
	return panel;
}

function ShowItemRecipe(itemName) {
	var currentItemData = ItemData[itemName];
	if (currentItemData == null)
		return;
	var RecipeData = currentItemData.Recipe;
	var BuildsIntoData = currentItemData.BuildsInto;
	var DropListData = currentItemData.DropListData;
	$.Each($('#ItemRecipeBoxRow1').Children(), function(child) {
		if (child.DestroyItemPanel != null)
			child.DestroyItemPanel();
		else
			child.DeleteAsync(0);
	});
	$.Each($('#ItemRecipeBoxRow2').Children(), function(child) {
		if (child.DestroyItemPanel != null)
			child.DestroyItemPanel();
		else
			child.DeleteAsync(0);
	});
	$.Each($('#ItemRecipeBoxRow3').Children(), function(child) {
		if (child.DestroyItemPanel != null)
			child.DestroyItemPanel();
		else
			child.DeleteAsync(0);
	});

	$('#ItemRecipeBoxRow1').RemoveAndDeleteChildren();
	$('#ItemRecipeBoxRow2').RemoveAndDeleteChildren();
	$('#ItemRecipeBoxRow3').RemoveAndDeleteChildren();

	var itemPanel = $.CreatePanel('Panel', $('#ItemRecipeBoxRow2'), 'ItemRecipeBoxRow2_item_' + itemName);
	SnippetCreate_SmallItem(itemPanel, itemName);
	itemPanel.style.align = 'center center';
	var len = 0;
	if (RecipeData != null && RecipeData.items != null) {
		$.Each(RecipeData.items[1], function(childName) {
			var itemPanel = $.CreatePanel('Panel', $('#ItemRecipeBoxRow3'), 'ItemRecipeBoxRow3_item_' + childName);
			SnippetCreate_SmallItem(itemPanel, childName);
			itemPanel.style.align = 'center center';
		});
		len = Object.keys(RecipeData.items).length;
		if (RecipeData.visible && RecipeData.recipeItemName != null) {
			len++;
			var itemPanel = $.CreatePanel('Panel', $('#ItemRecipeBoxRow3'), 'ItemRecipeBoxRow3_item_' + RecipeData.recipeItemName);
			SnippetCreate_SmallItem(itemPanel, RecipeData.recipeItemName);
			itemPanel.style.align = 'center center';
		}
	}
	$('#ItemRecipeBoxRow3').SetHasClass('ItemRecipeBoxRowLength7', len >= 7);
	$('#ItemRecipeBoxRow3').SetHasClass('ItemRecipeBoxRowLength8', len >= 8);
	$('#ItemRecipeBoxRow3').SetHasClass('ItemRecipeBoxRowLength9', len >= 9);
	if (BuildsIntoData != null) {
		$.Each(BuildsIntoData, function(childName) {
			var itemPanel = $.CreatePanel('Panel', $('#ItemRecipeBoxRow1'), 'ItemRecipeBoxRow1_item_' + childName);
			SnippetCreate_SmallItem(itemPanel, childName);
			itemPanel.style.align = 'center center';
		});
		$('#ItemRecipeBoxRow1').SetHasClass('ItemRecipeBoxRowLength7', Object.keys(BuildsIntoData).length >= 7);
		$('#ItemRecipeBoxRow1').SetHasClass('ItemRecipeBoxRowLength8', Object.keys(BuildsIntoData).length >= 8);
		$('#ItemRecipeBoxRow1').SetHasClass('ItemRecipeBoxRowLength9', Object.keys(BuildsIntoData).length >= 9);
	}
}

function SendItemBuyOrder(itemName) {
	var pid = Game.GetLocalPlayerID();
	var unit = Players.GetLocalPlayerPortraitUnit();
	unit = Entities.IsControllableByPlayer(unit, pid) ? unit : Players.GetPlayerHeroEntityIndex(pid);
	GameEvents.SendCustomGameEventToServer('panorama_shop_item_buy', {
		itemName: itemName,
		unit: unit,
		isControlDown: GameUI.IsControlDown()
	});
}

function ItemShowTooltip(panel) {
	$.DispatchEvent('DOTAShowAbilityTooltipForEntityIndex', panel, panel.itemName, Players.GetLocalPlayerPortraitUnit());
}

function ItemHideTooltip(panel) {
	$.DispatchEvent('DOTAHideAbilityTooltip', panel);
}

function LoadItemsFromTable(panorama_shop_data) {
	ItemList = panorama_shop_data.ShopList;
	ItemData = panorama_shop_data.ItemData;
	PushItemsToList();
}

function UpdateSmallItem(panel, gold) {
	try {
		var notpurchasable = !ItemData[panel.itemName].purchasable;
		panel.SetHasClass('CanBuy', GetRemainingPrice(panel.itemName, {}) <= (gold || Players.GetGold(Game.GetLocalPlayerID())) || notpurchasable);

		panel.SetHasClass('NotPurchasableItem', notpurchasable);
		if (ItemStocks[panel.itemName] != null) {
			var CurrentTime = Game.GetGameTime();
			var RemainingTime = ItemStocks[panel.itemName].current_cooldown - (CurrentTime - ItemStocks[panel.itemName].current_last_purchased_time);
			var stock = ItemStocks[panel.itemName].current_stock;
			panel.FindChildTraverse('SmallItemStock').text = stock;
			if (stock === 0 && RemainingTime > 0) {
				panel.FindChildTraverse('StockTimer').text = Math.round(RemainingTime);
				panel.FindChildTraverse('StockOverlay').style.width = (RemainingTime / ItemStocks[panel.itemName].current_cooldown * 100) + '%';
			} else {
				panel.FindChildTraverse('StockTimer').text = '';
				panel.FindChildTraverse('StockOverlay').style.width = 0;
			}
		}
	} catch (err) {
		console.error(err);
		var index = SmallItems.indexOf(panel);
		if (index > -1)
			SmallItems.splice(index, 1);
		else {
			index = SmallItemsAlwaysUpdated.indexOf(panel);
			if (index > -1)
				SmallItemsAlwaysUpdated.splice(index, 1);
		}
	}
}

function GetRemainingPrice(itemName, ItemCounter, baseItem) {
	if (ItemCounter[itemName] == null)
		ItemCounter[itemName] = 0;
	ItemCounter[itemName] = ItemCounter[itemName] + 1;

	var itemCount = GetItemCountInInventory(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true);
	var val = 0;
	if (itemCount < ItemCounter[itemName] || !baseItem) {
		if (ItemData[itemName] == null) {
			throw new Error('Unable to find item ' + itemName + '!');
		}
		var RecipeData = ItemData[itemName].Recipe;
		if (RecipeData != null && RecipeData.items != null) {
			$.Each(RecipeData.items[1], function(childName) {
				val += GetRemainingPrice(childName, ItemCounter, baseItem || itemName);
			});
			if (RecipeData.visible && RecipeData.recipeItemName != null) {
				val += GetRemainingPrice(RecipeData.recipeItemName, ItemCounter, baseItem || itemName);
			}
		} else {
			val += ItemData[itemName].cost;
		}
	}
	return val;
}

function SetQuickbuyStickyItem(itemName) {
	$.Each($('#QuickBuyStickyButtonPanel').Children(), function(child) {
		child.DestroyItemPanel();
	});
	var itemPanel = $.CreatePanel('Panel', $('#QuickBuyStickyButtonPanel'), 'QuickBuyStickyButtonPanel_item_' + itemName);
	SnippetCreate_SmallItem(itemPanel, itemName, true);
	itemPanel.AddClass('QuickBuyStickyItem');
	SmallItemsAlwaysUpdated.push(itemPanel);
}

function ClearQuickbuyItems() {
	QuickBuyTarget = null;
	QuickBuyTargetAmount = null;
	$.Each($('#QuickBuyPanelItems').Children(), function(child) {
		if (!child.BHasClass('DropDownValidTarget')) {
			child.DestroyItemPanel();
		} else {
			//child.visible = false
		}
	});
}

function RefreshQuickbuyItem(itemName) {
	MakeQuickbuyCheckItem(itemName, {}, {}, QuickBuyTargetAmount);
}

function MakeQuickbuyCheckItem(itemName, ItemCounter, ItemIndexer, sourceExpectedCount) {
	var RecipeData = ItemData[itemName].Recipe;
	if (ItemCounter[itemName] == null)
		ItemCounter[itemName] = 0;
	if (ItemIndexer[itemName] == null)
		ItemIndexer[itemName] = 0;
	ItemCounter[itemName] = ItemCounter[itemName] + 1;
	ItemIndexer[itemName] = ItemIndexer[itemName] + 1;
	var itemCount = GetItemCountInCourier(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true) + GetItemCountInInventory(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true);
	if ((itemCount < ItemCounter[itemName] || (itemName === QuickBuyTarget && itemCount - (sourceExpectedCount - 1) < ItemCounter[itemName]))) {
		if (RecipeData != null && RecipeData.items != null) {
			$.Each(RecipeData.items[1], function(childName) {
				MakeQuickbuyCheckItem(childName, ItemCounter, ItemIndexer);
			});
			if (RecipeData.visible && RecipeData.recipeItemName != null) {
				MakeQuickbuyCheckItem(RecipeData.recipeItemName, ItemCounter, ItemIndexer);
			}
		} else if ($('#QuickBuyPanelItems').FindChildTraverse('QuickBuyPanelItems_item_' + itemName + '_id_' + ItemIndexer[itemName]) == null) {
			var itemPanel = $.CreatePanel('Panel', $('#QuickBuyPanelItems'), 'QuickBuyPanelItems_item_' + itemName + '_id_' + ItemIndexer[itemName]);
			itemPanel.IsInQuickbuy = true;
			SnippetCreate_SmallItem(itemPanel, itemName);
			itemPanel.AddClass('QuickbuyItemPanel');
			SmallItemsAlwaysUpdated.push(itemPanel);
		}
	} else {
		if (itemName === QuickBuyTarget) {
			ClearQuickbuyItems();
		} else {
			RemoveQuickbuyItemChildren(itemName, ItemIndexer, false);
		}
	}
}

function RemoveQuickbuyItemChildren(itemName, ItemIndexer, bIncrease) {
	var RecipeData = ItemData[itemName].Recipe;
	if (bIncrease)
		ItemIndexer[itemName] = (ItemIndexer[itemName] || 0) + 1;
	RemoveQuckbuyPanel(itemName, ItemIndexer[itemName]);
	if (RecipeData != null && RecipeData.items != null) {
		$.Each(RecipeData.items[1], function(childName) {
			RemoveQuickbuyItemChildren(childName, ItemIndexer, true);
		});
		if (RecipeData.visible && RecipeData.recipeItemName != null) {
			RemoveQuickbuyItemChildren(RecipeData.recipeItemName, ItemIndexer, true);
		}
	}
}

function RemoveQuckbuyPanel(itemName, index) {
	var panel = $('#QuickBuyPanelItems').FindChildTraverse('QuickBuyPanelItems_item_' + itemName + '_id_' + index);
	if (panel != null) {
		panel.DestroyItemPanel();
	}
}

function SetQuickbuyTarget(itemName) {
	ClearQuickbuyItems();
	Game.EmitSound('Quickbuy.Confirmation');
	QuickBuyTarget = itemName;
	QuickBuyTargetAmount = GetItemCountInCourier(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true) + GetItemCountInInventory(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true) + 1;
	RefreshQuickbuyItem(itemName);
}

function ShowItemInShop(data) {
	if (data && data.itemName != null) {
		$('#ShopBase').AddClass('ShopBaseOpen');
		ShowItemRecipe(String(data.itemName));
	}
}

function UpdateShop() {
	SearchItems();
	var gold = Players.GetGold(Game.GetLocalPlayerID());
	$.Each(SmallItemsAlwaysUpdated, function(panel) {
		UpdateSmallItem(panel, gold);
	});
	if ($('#ShopBase').BHasClass('ShopBaseOpen'))
		$.Each(SmallItems, function(panel) {
			UpdateSmallItem(panel, gold);
		});
	//$.GetContextPanel().SetHasClass("InRangeOfShop", Entities.IsInRangeOfShop(m_QueryUnit, 0, true))
}

function AutoUpdateShop() {
	UpdateShop();
	$.Schedule(0.5, AutoUpdateShop);
	//OpenCloseShop(FindDotaHudElement("shop").BHasClass("ShopOpen"));
}

function AutoUpdateQuickbuy() {
	if (QuickBuyTarget != null) {
		RefreshQuickbuyItem(QuickBuyTarget);
	}
	$.Schedule(0.15, AutoUpdateQuickbuy);
}

function SetItemStock(item, ItemStock) {
	ItemStocks[item] = ItemStock;
}


function GetItemCountInInventory(nEntityIndex, itemName, bStash) {
	var counter = 0;
	var endPoint = 8;
	if (bStash)
		endPoint = 14;
	for (var i = endPoint; i >= 0; i--) {
		var item = Entities.GetItemInSlot(nEntityIndex, i);
		if (Abilities.GetAbilityName(item) === itemName)
			counter = counter + 1;
	}
	return counter;
}

function GetItemCountInCourier(nEntityIndex, itemName, bStash) {
	var courier = FindCourier(nEntityIndex);
	if (courier == null)
		return 0;
	var counter = 0;
	var endPoint = 8;
	if (bStash)
		endPoint = 14;
	for (var i = endPoint; i >= 0; i--) {
		var item = Entities.GetItemInSlot(courier, i);
		if (Abilities.GetAbilityName(item) === itemName && Items.GetPurchaser(item) === nEntityIndex)
			counter = counter + 1;
	}
	return counter;
}

function FindCourier(unit) {
	return $.Each(Entities.GetAllEntitiesByClassname('npc_dota_courier'), function(ent) {
		if (Entities.GetTeamNumber(ent) === Entities.GetTeamNumber(unit)) {
			return ent;
		}
	})[0];
}

function DynamicSubscribePTListener(table, callback, OnConnectedCallback) {
    if (PlayerTables.IsConnected()) {
        var tableData = PlayerTables.GetAllTableValues(table);
        if (tableData != null)
            callback(table, tableData, {});
        var ptid = PlayerTables.SubscribeNetTableListener(table, callback);
        if (OnConnectedCallback != null) {
            OnConnectedCallback(ptid);
        }
    } else {
        $.Schedule(0.1, function() {
            DynamicSubscribePTListener(table, callback, OnConnectedCallback);
        });
    }
}

(function() {
	$('#ShopPagesHost').RemoveAndDeleteChildren();
	$('#ShopPagesList').RemoveAndDeleteChildren();
	var hud = $.GetContextPanel().GetParent();
	while(hud.id !== 'Hud') {
		hud = hud.GetParent();
	}
	hud.FindChildTraverse('shop').visible = false;
	hud.FindChildTraverse('QuickBuyRows').visible = false;
	hud.FindChildTraverse('stash').style.marginBottom = '47px';
	var shopbtn = hud.FindChildTraverse('ShopButton');
	shopbtn.FindChildTraverse('BuybackHeader').visible = false;
	shopbtn.ClearPanelEvent('onactivate');
	shopbtn.ClearPanelEvent('onmouseover');
	shopbtn.ClearPanelEvent('onmouseout');
	shopbtn.SetPanelEvent('onactivate', function() {
		if (GameUI.IsAltDown()) {
			// Alert current gold
		} else {
			OpenCloseShop();
		}
	});

	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, true);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, true);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, true);
	Game.Events.F4Pressed.push(OpenCloseShop);
	GameEvents.Subscribe('panorama_shop_open_close', OpenCloseShop);
	Game.Events.F5Pressed.push(function() {
		if (QuickBuyTarget != null) {
			var bought = false;
			var QuickBuyPanelItems = $('#QuickBuyPanelItems');
			var childCount = QuickBuyPanelItems.GetChildCount();
			for (var i = 0; i < childCount; i++) {
				var child = QuickBuyPanelItems.GetChild(i);
				if (!child.BHasClass('DropDownValidTarget')) {
					UpdateSmallItem(child);
					if (child.BHasClass('CanBuy')) {
						SendItemBuyOrder(child.itemName);
						bought = true;
						break;
					}
				}
			}
			if (!bought) {
				GameEvents.SendEventClientSide('dota_hud_error_message', {
					'splitscreenplayer': 0,
					'reason': 80,
					'message': '#dota_hud_error_not_enough_gold'
				});
				Game.EmitSound('General.NoGold');
			}
		}
	});
	Game.Events.F8Pressed.push(function() {
		SendItemBuyOrder($('#QuickBuyStickyButtonPanel').GetChild(0).itemName);
	});
	Game.MouseEvents.OnLeftPressed.push(function(ClickBehaviors, eventName, arg) {
		if (ClickBehaviors === CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE) {
			$('#ShopBase').RemoveClass('ShopBaseOpen');
		}
	});

	GameEvents.Subscribe('panorama_shop_show_item', ShowItemInShop);
	GameEvents.Subscribe('dota_link_clicked', function(data) {
		if (data != null && data.link != null && data.link.lastIndexOf('dota.item.', 0) === 0) {
			$('#ShopBase').AddClass('ShopBaseOpen');
			ShowItemRecipe(data.link.replace('dota.item.', ''));
		}
	});

	GameEvents.Subscribe('panorama_shop_show_item_if_open', function(data) {
		if ($('#ShopBase').BHasClass('ShopBaseOpen')) ShowItemInShop(data);
	});
	DynamicSubscribePTListener('panorama_shop_data', function(tableName, changesObject, deletionsObject) {
		if (changesObject.ShopList) {
			LoadItemsFromTable(changesObject);
			SetQuickbuyStickyItem('item_tpscroll');
		};
		var stocksChanges = changesObject['ItemStocks_team' + Players.GetTeam(Game.GetLocalPlayerID())];
		if (stocksChanges) {
			for (var item in stocksChanges) {
				var ItemStock = stocksChanges[item];
				SetItemStock(item, ItemStock);
			}
		};
	});

	GameEvents.Subscribe('arena_team_changed_update', function() {
		var stockdata = PlayerTables.GetTableValue('panorama_shop_data', 'ItemStocks_team' + Players.GetTeam(Game.GetLocalPlayerID()));
		for (var item in stockdata) {
			var ItemStock = stockdata[item];
			SetItemStock(item, ItemStock);
		}
	});

	AutoUpdateShop();
	AutoUpdateQuickbuy();

	$.RegisterEventHandler('DragDrop', $('#QuickBuyStickyButtonPanel'), function(panelId, draggedPanel) {
		if (draggedPanel.itemname != null) {
			SetQuickbuyStickyItem(draggedPanel.itemname);
		}
		return true;
	});

	$.RegisterEventHandler('DragDrop', $('#QuickBuyPanelItems'), function(panelId, draggedPanel) {
		if (draggedPanel.itemname != null) {
			SetQuickbuyTarget(draggedPanel.itemname);
		}
		return true;
	});
})();
