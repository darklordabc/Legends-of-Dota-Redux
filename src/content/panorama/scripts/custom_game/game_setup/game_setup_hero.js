"use strict";
var heroName = '';

function setHeroName( name, tooltipFunct, info ) {
    $.GetContextPanel().SetAttributeString('heroName', name);
    $('#heroImage').heroname = name;
    $('#heroName').text = $.Localize(name);

	$.GetContextPanel().SetPanelEvent('onmouseover', function() {
		// Tooltip
        var displayNameTitle = $.Localize(name);
        var heroStats = tooltipFunct(name, info);		// Fix this shit!!!!

        // Show the tip
        $.DispatchEvent('DOTAShowTitleTextTooltipStyled', $.GetContextPanel(), displayNameTitle, heroStats, "testStyle");

		// Hero movie
		if ($('#heroMovie') != null)
			return;

		var movie = $.CreatePanel( 'DOTAHeroMovie', $.GetContextPanel(), 'heroMovie' );
		$.GetContextPanel().MoveChildBefore(movie, $('#heroImage'));
    	$('#heroMovie').heroname = name;

    	var parent = $.GetContextPanel().GetParent();
    	while(parent.GetParent() != null)
        	parent = parent.GetParent();

        parent.FindChildTraverse("TitleTextTooltip").FindChildTraverse("Contents").style.maxWidth = "325px;";
	});

	$.GetContextPanel().SetPanelEvent('onmouseout', function(){
		// Tooltip
        $.DispatchEvent('DOTAHideAbilityTooltip');
        $.DispatchEvent('DOTAHideTitleTextTooltip');

		// Hero movie
		if ($('#heroMovie') == null)
			return;		
		$('#heroMovie').DeleteAsync(0);
	});
}

(function() {
    $.GetContextPanel().setHeroName = setHeroName;
})();