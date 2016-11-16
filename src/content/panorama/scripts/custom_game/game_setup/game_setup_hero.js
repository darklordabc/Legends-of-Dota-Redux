"use strict";

function setHeroName( name ) {
    $.GetContextPanel().SetAttributeString('heroName', name);
    $('#heroImage').heroname = name;
    $('#heroName').text = $.Localize(name);
}

(function() {
    $.GetContextPanel().setHeroName = setHeroName;
	$.GetContextPanel().SetPanelEvent('onmouseover', function(){
		if ($('#heroMovie') != null)
			return;

		var movie = $.CreatePanel( 'DOTAHeroMovie', $.GetContextPanel(), 'heroMovie' );
		$.GetContextPanel().MoveChildBefore(movie, $('#heroImage'));
    	$('#heroMovie').heroname = $.GetContextPanel().GetAttributeString('heroName', '');
	});

	$.GetContextPanel().SetPanelEvent('onmouseout', function(){
		if ($('#heroMovie') == null)
			return;		
		$('#heroMovie').DeleteAsync(0);
	});
})();