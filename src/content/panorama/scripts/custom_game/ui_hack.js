"use strict";

(function(){
    var parent = $.GetContextPanel().GetParent();
    while(parent.GetParent() != null)
        parent = parent.GetParent();

    //var hudElements = parent.FindChildTraverse('HUDElements').Children();

    // Main function
    GameUI.CustomUIConfig().$ = function( selector ) {
        // Selector type
        function getSelectorType(selector) {
            if (selector.match(/#[\w]+/))
                return 'ID';
            if (selector.match(/[\\.\w]+/))
                return 'CLASS';        
        }

        // Filter by selector
        function filterSelector( data, s ) {
            if (data.length == 0)
                return [];

            // Add children
            var workData = data;
            for(var panel of workData){
                var sel = selectBySelector( panel, s );

                if (sel != null)
                    for(var c of sel)
                        data.push(c);
            }

            var selType = getSelectorType(s);
            switch(selType){
                case 'ID':
                    s = s.replace('#', '');

                    data = data.filter(function(v, k){
                        if (v == null)
                            return false;
                        return v.id == s;
                    });
                    break;

                case 'CLASS':
                    var classes = s.split('.').filter(function(v, k){ 
                        return v != '';
                    });
                        
                    data = data.filter(function(v, k){
                        if (v == null)
                            return false;

                        for(var c of classes)
                            if (!v.BHasClass(c))
                                return false;

                        return true;
                    });

                    break;
            }

            return data;
        }

        // First selection
        function selectBySelector( panel, s ){
            if (s == '' || panel == null)
                return [];

            var selection = [];
            var selType = getSelectorType(s);

            switch(selType){
                case 'ID':
                    s = s.replace('#', '');

                    selection.push(panel.FindChildTraverse(s));
                    break;

                case 'CLASS':
                    var classes = s.split('.').filter(function(v, k){ 
                        return v != '';
                    });

                    var children = panel.FindChildrenWithClassTraverse(classes[0]);
                    children = children.filter(function(v, k){
                        for(var c of classes)
                            if (!v.BHasClass(c))
                                return false;

                        return true;
                    });

                    for(var c of children)
                        selection.push(c);

                    break;
            }

            return selection;
        }

        // Selector function
        function select( panel, selector ){
            if (!panel)
                return [];

            var selectors = selector.match(/[#\\.\w]+/g);
            if (selectors.length == 0)
                return;

            var selection = selectBySelector(panel, selectors[0])

            if (selectors.length > 1)
                for(var i = 1; i < selectors.length; i++) {
                    selection = filterSelector(selection, selectors[i]);
                }

            return selection;
        };

        
        var obj = {
            'array': select( parent, selector ),

            'get': function() {
                return this.array;
            },
            'first': function() {
                if (this.array.length > 0)
                    this.array = [this.array[0]];

                return this;
            },
            'last': function() {
                if (this.array.length > 0)
                    this.array = [this.array[this.array.length - 1]];

                return this;
            },            
            // 
            'each': function( f ) {
                if (typeof f == 'function')
                    this.array.forEach(f);
            },
            // Set styles
            'css': function( props ) {
                if (typeof props == 'object')
                    for(var k of Object.keys(props)) 
                        this.each(function( p ) {
                            var propVal = props[k];

                            var dashes = k.match(/-./g);
                            if (dashes)
                                dashes.forEach(function(m){ 
                                    k = k.replace(m, m.replace('-', '').toUpperCase())
                                })

                            p.style[k] = propVal + ';';
                        })

                return this;
            },

            'msg': function() {
                $.Msg(this);
            }
        }

        return obj;
    }
})()