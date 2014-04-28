package  {
	// Flash Libraries
	import flash.display.MovieClip;
	import fl.controls.Button;
	import flash.text.TextField;

	// Events
	import flash.events.MouseEvent;

	// Eval stuff
    /*import com.hurlant.eval.Evaluator;
    import com.hurlant.eval.ByteLoader;
    import flash.utils.ByteArray;
    import flash.display.Loader;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.system.LoaderContext;
    import flash.system.ApplicationDomain;*/
    import r1.deval.D;

    import ValveLib.Globals;
    import ValveLib.ElementLoader;

	public class console_window extends MovieClip {
		// Stuff from the stage
		public var outField:TextField;
		public var outFieldScrollbar;
		public var inField:TextField;
		public var inFieldScrollbar;
		public var runButton:Button;
		public var console_bg:MovieClip;

		// Evaluator stuff
        //private var evaluator:Evaluator;
        //private var loader:Loader;

        // Stores the single instance of this evaluator
        private static var instance;

		public function console_window() {
			// Init Useful stuff
            //evaluator = new Evaluator();
            //loader = new Loader();

            // Store access to this instance
            instance = this;

            // Hook execute button
            runButton.addEventListener(MouseEvent.CLICK, onRunClicked);

            // Reset text fields
            outField.text = "";
            inField.text = "";

            // Show help
            print("Console loaded successfully!");
            help();
		}

		// Returns this class
        public static function getInstance() {
            return instance;
        }

        // Run execute button is pressed
        public function onRunClicked(obj:Object) {
        	runCode(inField.text);
        }

        // Runs code
        public function runCode(code:String) {
        	// Attempt to run the code
        	try {
        		// Build code block -- damn that's big!
	        	//var expression = "function doit() {var parent = console.getInstance();var globals = parent.globals;var PrintTable = console_window.getUtil(\"PrintTable\");var trace = console_window.getInstance().print;var help = console_window.getInstance().help;try{"+code+"}catch (e:Error) {trace(e.errorID+\",\"+e.name+\",\"+e.message);}}doit();";

	        	var expression = code;

	        	D.eval(expression, {
	        		trace: print,
	        		parent: console.getInstance(),
	        		globals: console.getInstance().globals,
	        		PrintTable: util.PrintTable,
	        		help: help,
	        		get: getLoader
	        	});
    		} catch(e:Error) {
    			print(e.errorID+","+e.name+","+e.message);
    		}
        }

        // Prints a string to the console
        public function print(msg):void {
        	// Workout if we should autoscroll
        	var scroll = false;
        	if(outField.scrollV == outField.maxScrollV) scroll = true;

        	// Add text
        	outField.appendText(msg+"\n");

        	// Update scrollbar
        	outFieldScrollbar.update();

        	// Scroll if we should
        	if(scroll) outField.scrollV = outField.maxScrollV;
        }

        // Prints out help
        public function help():void {
        	print("Useful Stuff:");
        	print("globals = access to the globals table");
        	print("PrintTable(object);");
        	print("trace(string);");
        	print("help();");
        }

        public static function getUtil(str):MovieClip {
        	return util[str];
        }

        public function getLoader(str):MovieClip {
        	return console.getInstance().globals[str].movieClip;
        }
	}

}
