function GetDotaHud() {
    var panel = $.GetContextPanel();
    while (panel && panel.id !== 'Hud') {
        panel = panel.GetParent();
	}

    if (!panel) {
        throw new Error('Could not find Hud root from panel with id: ' + $.GetContextPanel().id);
	}

	return panel;
}

function FindDotaHudElement(id) {
	return GetDotaHud().FindChildTraverse(id);
}

function MakeNeutralItemsInShopColored() {
	var itemsTier = FindDotaHudElement('GridNeutralItems');
	var correctItemsInTier = itemsTier.FindChildrenWithClassTraverse('MainShopItem');
	for(var i=0; i<correctItemsInTier.length; i++){
		correctItemsInTier[i].style.saturation = 1.0;
		correctItemsInTier[i].style.brightness = 1.0;
	}
}

(function()
{
	GameEvents.Subscribe("MakeNeutralItemsInShopColored", MakeNeutralItemsInShopColored)
})();

