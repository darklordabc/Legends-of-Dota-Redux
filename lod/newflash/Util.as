package {
    // Flash Libraries
    import flash.display.MovieClip;
    import flash.utils.getQualifiedClassName;

    // Used to make nice buttons / doto themed stuff
    import flash.utils.getDefinitionByName;

    // Events
    import flash.events.MouseEvent;

    // Scaleform stuff
    import scaleform.clik.interfaces.IDataProvider;
    import scaleform.clik.data.DataProvider;

    public class Util {
        // Function to repeat a string many times
        public static function strRep(str, count) {
            var output = "";
            for(var i=0; i<count; i++) {
                output = output + str;
            }

            return output;
        }

        public static function isPrintable(t) {
            if(t == null || t is Number || t is String || t is Boolean || t is Function || t is Array) {
                return true;
            }
            // Check for vectors
            if(getQualifiedClassName(t).indexOf('__AS3__.vec::Vector') == 0) return true;

            return false;
        }

        public static function PrintTable(t, indent=0, done=null) {
            var i:int, key, key1, v:*, thisClass;

            // Validate input
            if(isPrintable(t)) {
                trace("PrintTable called with incorrect arguments!");
                return;
            }

            if(indent == 0) {
                trace(t.name+" "+t+": {")
            }

            // Stop loops
            done ||= new flash.utils.Dictionary(true);
            if(done[t]) {
                trace(strRep("\t", indent)+"<loop object> "+t);
                return;
            }
            done[t] = true;

            // Grab this class
            thisClass = getQualifiedClassName(t);

            // Print methods
            for each(key1 in flash.utils.describeType(t)..method) {
                // Check if this is part of our class
                if(key1.@declaredBy == thisClass) {
                    // Yes, log it
                    trace(strRep("\t", indent+1)+key1.@name+"()");
                }
            }

            // Check for text
            if("text" in t) {
                trace(strRep("\t", indent+1)+"text: "+t.text);
            }

            // Print variables
            for each(key1 in flash.utils.describeType(t)..variable) {
                key = key1.@name;
                v = t[key];

                // Check if we can print it in one line
                if(isPrintable(v)) {
                    trace(strRep("\t", indent+1)+key+": "+v);
                } else {
                    // Grab the class of it
                    thisClass = getQualifiedClassName(t);

                    // Open bracket
                    trace(strRep("\t", indent+1)+key+" "+thisClass+": {");

                    // Recurse!
                    PrintTable(v, indent+1, done)

                    // Close bracket
                    trace(strRep("\t", indent+1)+"}");
                }
            }

            // Find other keys
            for(key in t) {
                v = t[key];

                // Check if we can print it in one line
                if(isPrintable(v)) {
                    trace(strRep("\t", indent+1)+key+": "+v);
                } else {
                    // Grab the class of it
                    thisClass = getQualifiedClassName(t);

                    // Open bracket
                    trace(strRep("\t", indent+1)+key+" "+thisClass+": {");

                    // Recurse!
                    PrintTable(v, indent+1, done)

                    // Close bracket
                    trace(strRep("\t", indent+1)+"}");
                }
            }

            // Get children
            if(t is MovieClip) {
                // Loop over children
                for(i = 0; i < t.numChildren; i++) {
                    // Grab the class of it
                    thisClass = getQualifiedClassName(t);

                    // Open bracket
                    trace(strRep("\t", indent+1)+t.name+" "+t+" "+thisClass+": {");

                    // Recurse!
                    PrintTable(t.getChildAt(i), indent+1, done);

                    // Close bracket
                    trace(strRep("\t", indent+1)+"}");
                }
            }

            // Close bracket
            if(indent == 0) {
                trace("}");
            }
        }

        // Make a small button
        public static function smallButton(container:MovieClip, txt:String, emptyMC:Boolean=false, centre:Boolean=false):MovieClip {
            // Grab the class for a small button
            var dotoButtonClass:Class = getDefinitionByName("ChannelTab") as Class;

            // Should we empty it first?
            if(emptyMC) {
                // Empty it
                empty(container);
            }

            // Create the button
            var btn:MovieClip = new dotoButtonClass();
            btn.label = txt;
            container.addChild(btn);

            // Should we center it?
            if(centre) {
                btn.x = -btn.width/2;
            }

            // Return the button
            return btn;
        }

        // Makes a combo box
        public static function comboBox(container:MovieClip, slots:Number):MovieClip {
            // Grab the class for a small button
            var dotoComboBoxClass:Class = getDefinitionByName("ComboBoxSkinned") as Class;

            // Create the button
            var comboBox:MovieClip = new dotoComboBoxClass();
            container.addChild(comboBox);

            // Create the data provider
            var dp:IDataProvider = new DataProvider();
            for(var i:Number=0; i<slots; i++) {
                dp[i] = {
                  "label":"empty",
                  "data":i
               };
            }

            // Apply the data provider
            comboBox.setDataProvider(dp);

            // Return the button
            return comboBox;
        }

        // Sets a string in a combo box
        public static function setComboBoxString(comboBox:MovieClip, slot:Number, txt:String):void {
            comboBox.menuList.dataProvider[slot] = {
                "label":txt,
                "data":slot
            };

            if(slot == 0) {
                comboBox.defaultSelection = comboBox.menuList.dataProvider[0];
                comboBox.setSelectedIndex(0);
            }
        }

        // Empties a movieclip
        public static function empty(mc:MovieClip) {
            while(mc.numChildren > 0) {
                mc.removeChildAt(0);
            }
        }

        // Hides the parent when clicked
        public static function hideParentOnClick(e:MouseEvent) {
            e.currentTarget.parent.visible = false;
        }

        // Decodes a character sent over the network
        public static function decodeChar(message:String, index:Number) {
            // Convert the character into a number
            var n = message.charCodeAt(index);

            // Fix weird number errors
            if(n > 255) n -= 4294967040;

            // Remove 1 and return
            return n - 1;
        }
    }
}