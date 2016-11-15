"use strict";

function setHeroName( name ) {
    $.GetContextPanel().SetAttributeString('heroName', name);
    $('#heroImage').heroname = name;
    $('#heroMovie').heroname = name;
    $('#heroName').text = $.Localize(name);
}

(function() {
    $.GetContextPanel().setHeroName = setHeroName;
})();