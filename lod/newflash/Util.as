package {
    // Flash Libraries
    import flash.display.MovieClip;
    import flash.utils.getQualifiedClassName;

    // Used to make nice buttons / doto themed stuff
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;

    // Events
    import flash.events.MouseEvent;

    // Scaleform stuff
    import scaleform.clik.interfaces.IDataProvider;
    import scaleform.clik.data.DataProvider;
    import scaleform.clik.events.ListEvent;

    // Marking spells different colors
    import flash.filters.ColorMatrixFilter;

    public class Util {
        // A red filter
        public static var redFilter:Array = [new ColorMatrixFilter([1,1,1,0,0,0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.0,0.0,0.0,1,0])];

        // A grey filter
        public static var greyFilter:Array = [new ColorMatrixFilter([0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.0,0.0,0.0,1,0])];

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
        public static function comboBox(container:MovieClip, slots:Array):MovieClip {
            // Grab the class for a small button
            var dotoComboBoxClass:Class = getDefinitionByName("ComboBoxSkinned") as Class;

            // Create the button
            var comboBox:MovieClip = new dotoComboBoxClass();
            container.addChild(comboBox);

            // Set the slots
            setComboBoxSlots(comboBox, slots);

            // Return the button
            return comboBox;
        }

        // Sets the slots in the given combo box
        public static function setComboBoxSlots(comboBox:MovieClip, slots:Array):void {
            // Create the data provider
            var dp:IDataProvider = new DataProvider();

            // Ensure slots is ok
            if(slots != null) {
                for(var i:Number=0; i<slots.length; i++) {
                    dp[i] = {
                      "label":slots[i],
                      "data":i
                   };
                }
            }

            // Apply the data provider
            comboBox.setDataProvider(dp);

            comboBox.defaultSelection = comboBox.menuList.dataProvider[0];
            comboBox.setSelectedIndex(0);
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

        // Creates a search box
        public static function searchBox(container:MovieClip):MovieClip {
            return cloneObject(container, lod.Globals.Loader_shared_heroselectorandloadout.movieClip.heroDock.filterButtons.searchBox);
        }

        // Clones the given movieclip
        public static function cloneObject(contianer:MovieClip, source:MovieClip):MovieClip {
            var objectClass:Class = Object(source).constructor;
            var instance:MovieClip = new objectClass() as MovieClip;
            contianer.addChild(instance);
            /*instance.transform = source.transform;
            instance.filters = source.filters;
            instance.cacheAsBitmap = source.cacheAsBitmap;
            instance.opaqueBackground = source.opaqueBackground;
            source.parent.addChild(instance);*/

            return instance;
        }

        // Empties a movieclip
        public static function empty(mc:MovieClip) {
            while(mc.numChildren > 0) {
                mc.removeChildAt(0);
            }
        }

        // Moves all the clips from one movieclip, to another
        public static function moveClips(mc1:MovieClip, mc2:MovieClip) {
            while(mc1.numChildren > 0) {
                var child = mc1.getChildAt(0);
                mc1.removeChildAt(0);
                mc2.addChild(child);
            }
        }

        public static function getClass(obj:Object):Class {
            return Class(getDefinitionByName(getQualifiedClassName(obj)));
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

        // Returns minutes:seconds from a number, seconds is always two digits
        public static function sexyTime(time:Number):String {
            return Math.floor(time/60)+':'+(Math.floor(time)%60<10 ? '0' : '')+(Math.floor(time)%60);
        }

        // Object to array converter
        public static function objectToArray(obj:Object):Array {
            if(obj == null) return [];

            var arr = [];
            for(var i=0; obj[i] != null; ++i) {
                arr.push(obj[i]);
            }

            return arr;
        }
    }
}