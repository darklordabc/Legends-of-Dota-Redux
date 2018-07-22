var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var SmallItems = {};
var ItemList = {};
var ItemData = {};

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

function InitializeItemList(optionPanel) {
    DynamicSubscribePTListener('panorama_shop_data', function(tableName, changesObject, deletionsObject) {
        if (changesObject.ItemData) {
            ItemData = changesObject.ItemData;
            for (var itemName in ItemData) {
                if (SmallItems[itemName]) {
                    SmallItems[itemName].forEach(function(panel) {
                        panel.SetHasClass('purchasable', ItemData[itemName].purchasable);
                    });
                }
            }
        };
        if (changesObject.ShopList) {
            ItemList = changesObject.ShopList;
            CreateItemList(optionPanel);
        };
    });
}

function CreateItemList(optionPanel) {
    var mainRoot = $.CreatePanel('Panel', optionPanel, 'option_panel_items_shop');
    mainRoot.BLoadLayoutSnippet('option_panel_items_shop');
    var isShopPageSelected = false;
    $.Each(ItemList, function(shopContent, shopName) {
        shopName = shopName + '';
        var TabButton = $.CreatePanel('RadioButton', mainRoot.FindChildTraverse('ShopPagesList'), '');
        TabButton.BLoadLayoutSnippet('ShopPageButton');
        TabButton.FindChildTraverse('ButtonImage').SetImage('file://{images}/custom_game/shop/page_' + shopName + '.png');
        TabButton.SetPanelEvent('onactivate', function() {
            SelectShopPage(shopName);
        });
        var TabShopItemlistPanel = $.CreatePanel('Panel', mainRoot.FindChildTraverse('ShopPagesHost'), shopName);
        TabShopItemlistPanel.BLoadLayoutSnippet('ShopPage');
        var ButtonSetAll = TabButton.FindChildTraverse('ButtonSetAll');
        ButtonSetAll.checked = true;
        FillShopPage(TabShopItemlistPanel, ButtonSetAll, shopName, shopContent);
        ButtonSetAll.AddClass('optionsSlotPanelHost');
        ButtonSetAll.SetPanelEvent('onactivate', function() {
            SetItemsPurchasableFromPanel(TabShopItemlistPanel, ButtonSetAll.checked);
            TabShopItemlistPanel.FindChildrenWithClassTraverse('ButtonSetAll').forEach(function(panel) {
                panel.checked = ButtonSetAll.checked;
            });
        });

        if (!isShopPageSelected) {
            SelectShopPage(shopName);
            TabButton.checked = true;
            isShopPageSelected = true;
        }
    });
}

function SelectShopPage(shopName) {
    $.Each($('#ShopPagesHost').Children(), function(child) {
        child.SetHasClass('SelectedPage', child.id === shopName);
    });
}

function FillShopPage(panel, PageButtonSetAll, shopName, shopContent) {
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
        var ButtonSetAll = $.CreatePanel('ToggleButton', TabButton, '');
        ButtonSetAll.AddClass('ButtonSetAll');
        ButtonSetAll.AddClass('optionsSlotPanelHost');
        ButtonSetAll.checked = true;
        ButtonSetAll.SetPanelEvent('onactivate', function() {
            SetItemsPurchasableFromPanel(TabShopItemlistPanel, ButtonSetAll.checked);
            var otherTabsCheckboxes = panel.FindChildrenWithClassTraverse('ButtonSetAll');
            otherTabsCheckboxes.forEach(function(checkbox) {
                if (otherTabsCheckboxes.length === 1 || (checkbox !== ButtonSetAll && checkbox.checked === ButtonSetAll.checked)) {
                    PageButtonSetAll.checked = ButtonSetAll.checked;
                }
            });
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
            var itemPanel = $.CreatePanel('DOTAItemImage', groupPanel, '');
            SnippetCreate_SmallItem(itemPanel, itemName);
        });
    }
}

function SnippetCreate_SmallItem(panel, itemName) {
    panel.AddClass('SmallItemPanel');
    if (itemName === '__indent__') {
        panel.style.opacity = 0;
        return;
    }
    panel.itemName = itemName;
    panel.itemname = itemName;
    panel.SetHasClass('purchasable', (ItemData[itemName] || {}).purchasable || true);
    if (itemName.lastIndexOf('item_recipe', 0) === 0)
        panel.FindChildTraverse('SmallItemImage').SetImage('raw://resource/flash3/images/items/recipe.png');
    var ToggleItemPurchasable = function() {
        GameEvents.SendCustomGameEventToServer('lodSetShopItemsPurchasable', {
            items: [itemName],
            purchasable: !panel.BHasClass('purchasable')
        });
    };
    panel.SetPanelEvent('onactivate', ToggleItemPurchasable);
    panel.SetPanelEvent('oncontextmenu', ToggleItemPurchasable);

    panel.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowAbilityTooltipForEntityIndex', panel, itemName, Players.GetLocalPlayerPortraitUnit());
    });
    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideAbilityTooltip', panel);
    });
    if (!SmallItems[itemName]) SmallItems[itemName] = [];
    SmallItems[itemName].push(panel);
    return panel;
}

function SetItemsPurchasableFromPanel(panel, purchasable) {
    var itemNames = [];
    panel.FindChildrenWithClassTraverse('SmallItemPanel').forEach(function(panel) {
        itemNames.push(panel.itemName);
    });
    GameEvents.SendCustomGameEventToServer('lodSetShopItemsPurchasable', {
        items: itemNames,
        purchasable: purchasable
    });
}

function SaveDisabledItems() {
    var itemNames = [];
    $('#option_panel_items_shop').FindChildrenWithClassTraverse('SmallItemPanel').forEach(function(panel) {
        if (!panel.BHasClass('purchasable')) {
            itemNames.push(panel.itemName);
        }
    });
    optionValueList.lodDisabledItems = itemNames;
    return itemNames;
}

function LoadDisabledItems(data) {
    GameEvents.SendCustomGameEventToServer('lodSetShopItemsPurchasable', {
        items: data,
        purchasable: false,
        silent: true
    });
}
