package {
    // Flash Libraries
    import flash.display.MovieClip;
    import flash.utils.getQualifiedClassName;
    import flash.utils.describeType;

    public class util {
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
            // Hook console window trace
            var instance = console_window.getInstance();
            var trace = instance.print;

            var i:int, key, key1, v:*;

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
            var thisClass = getQualifiedClassName(t);

            // Print methods
            for each(key1 in describeType(t)..method) {
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
            for each(key1 in describeType(t)..variable) {
                key = key1.@name;
                v = t[key];

                // Check if we can print it in one line
                if(isPrintable(v)) {
                    trace(strRep("\t", indent+1)+key+": "+v);
                } else {
                    // Open bracket
                    trace(strRep("\t", indent+1)+key+": {");

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
                    // Open bracket
                    trace(strRep("\t", indent+1)+key+": {");

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
                    // Open bracket
                    trace(strRep("\t", indent+1)+t.name+" "+t+": {");

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
    }
}