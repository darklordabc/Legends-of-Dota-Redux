"use strict";
var pickList = [
	{
		name: 'Main',
		icon: 'default.png',
		content: [
			'nyx_assassin_burrow',
			'nyx_assassin_burrow',
			'nyx_assassin_burrow',
			'nyx_assassin_burrow',
			'nyx_assassin_burrow',
			'nyx_assassin_burrow',
		]
	},
	{
		name: 'One',
		icon: 'default.png',
		content: [
			'nyx_assassin_burrow',
			'nyx_assassin_burrow',
			'nyx_assassin_burrow',
			'nyx_assassin_burrow',
		]
	},
	{
		name: 'Two',
		icon: 'default.png',
		content: [
			'nyx_assassin_burrow',
		]
	},
	{
		name: 'Three',
		icon: 'default.png',
		content: []
	},
	{
		name: 'Four',
		icon: 'default.png',
		content: []
	},
	{
		name: 'main',
		icon: 'default.png',
		content: []
	},
	{
		name: 'secondary',
		icon: 'default.png',
		content: []
	},
	{
		name: 'secondary',
		icon: 'default.png',
		content: []
	},
	{
		name: 'secondary',
		icon: 'default.png',
		content: []
	},
	{
		name: 'secondary',
		icon: 'default.png',
		content: []
	},
			{
		name: 'main',
		icon: 'default.png',
		content: []
	},
	{
		name: 'secondary',
		icon: 'default.png',
		content: []
	},
	{
		name: 'secondary',
		icon: 'default.png',
		content: []
	},
	{
		name: 'secondary',
		icon: 'default.png',
		content: []
	},
	{
		name: 'secondary',
		icon: 'default.png',
		content: []
	},
];

var settings = {
	visible: true,
	width: 500,
	height: 500,
	sliderPosition: '',
	elementFunct: function( parent, element){
		var elementPanel = $.CreatePanel( "Panel", parent, '');
		elementPanel.BLoadLayoutSnippet('ability');
		elementPanel.FindChildTraverse('abilityIcon').abilityname = element;
	}
}

var imagesPath = 'file://{images}/custom_game/picker/';

// Sets position of slider
function setSliderPosition( position ) {
	switch(position) {
		case 'top':
		case 'left':		
			$.GetContextPanel().MoveChildAfter($('#pickerArea'), $('#sliderArea'));
			break;
		case 'bottom':			
		case 'right':
			$.GetContextPanel().MoveChildAfter($('#sliderArea'), $('#pickerArea'));
			break;			
	}

	$('#sliderArea').SetHasClass('vertical', position == 'left' || position == 'right');
	$.GetContextPanel().SetHasClass('horizontal', position == 'left' || position == 'right');
}

// Apply settings
function applySettings( newSettings ) {
	if (!newSettings)
		return;

	for(var key of Object.keys(newSettings)){
		if (!settings.hasOwnProperty(key))
			continue;

		settings[key] = newSettings[key];

		switch(key)	{
			case 'visible':
				$.GetContextPanel().visible = settings.visible;
				break;
			case 'width':
				$.GetContextPanel().style.width = settings[key] + "px;";
				break;
			case 'height':
				$.GetContextPanel().style.height = settings[key] + "px;";
				break;				
			case 'sliderPosition':
				setSliderPosition( settings[key] );
				break;
		}
	}	
}

// Show all categories
function showAllCategories() {
	for(var i = 0; i < $('#slider').GetChildCount(); i++)
		$('#slider').GetChild(i).RemoveClass('active');

	$('#sliderArea').GetChild(0).AddClass('active');

	for(var i = 0; i < $('#pickerArea').GetChildCount(); i++)
		$('#pickerArea').GetChild(i).visible = true;
}

// Filling categories content
function addCategory(name, category) {
  	var panel = $.CreatePanel( "Panel", $('#pickerArea'), name);
    panel.BLoadLayoutSnippet('category');
    panel.FindChildTraverse('categoryName').text = $.Localize(category.name);

	for(var element of category.content)
		settings.elementFunct(panel.FindChildTraverse('categoryContent'), element);
}

// Categories in slider
function setCategoryHadlers( panel, category ) {
	panel.SetPanelEvent('onactivate', function() {
		for(var i = 0; i < $('#slider').GetChildCount(); i++)
			$('#slider').GetChild(i).RemoveClass('active');
		$('#sliderArea').GetChild(0).RemoveClass('active');
		
		for(var i = 0; i < $('#pickerArea').GetChildCount(); i++)
			$('#pickerArea').GetChild(i).visible = false;

    	panel.AddClass('active');
    	$('#' + panel.id.replace('Icon', '')).visible = true;;
    });

    panel.SetPanelEvent('onmouseover', function() {
    	$.DispatchEvent('DOTAShowTextTooltip', panel, $.Localize(category.name));
    });

    panel.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTextTooltip');
    });    
}

function addCategoryIcon(name, category) {
    var panel = $.CreatePanel( "Panel", $('#slider'), name);
    panel.BLoadLayoutSnippet('categoryIcon'); 
    panel.FindChildTraverse('icon').SetImage(imagesPath + category.icon);
	setCategoryHadlers(panel, category);	
}

// Update panel data
function updatePanelData( data ) {
	for(var i = 0; i < $('#pickerArea').GetChildCount(); i++)
		$('#pickerArea').GetChild(i).DeleteAsync(0);

	for(var i = 0; i < $('#slider').GetChildCount(); i++)
		$('#slider').GetChild(i).DeleteAsync(0);

	var i = 0;
	for(var category of data){
		// Skip empty categories
		if (category.content.length === 0)
			continue;

		addCategory('cat' + i, category)
		addCategoryIcon('catIcon' + i, category);
        i++;
	}

	showAllCategories();
}

(function() {
	var a = {
		sliderPosition: 'bottom'
	}

	applySettings( settings ); 
	updatePanelData( pickList );

	applySettings( a ); 
})(); 