package {
    // Flash Libraries
    import flash.display.MovieClip;

    // Events
    import flash.events.MouseEvent;

    // Scaleform stuff
    import scaleform.clik.interfaces.IDataProvider;
    import scaleform.clik.data.DataProvider;

    /*
        SETUP:
    */
    // Simply create a reference to it, the first argument is the stage, the 2nd is your flash file (this)
    // rightClickMenu = new RightClickMenu(stage, this);

    public class RightClickMenu {
        private var rightClickMenu:MovieClip;
        private var rightClickCallback:Function;
        private var rightClickContainer:MovieClip;

        // The stage
        private var actualStage;

        // Should we ignore the click?
        private var ignoreClick:Boolean = true;

        public function RightClickMenu(stage, container:MovieClip) {
            // Store the container
            rightClickContainer = container;
            actualStage = stage;
        }

        // Shows the right click menu
        public function show(items:Array, newCallback:Function):void {
            if(rightClickMenu != null) {
                rightClickContainer.removeChild(rightClickMenu);
                rightClickMenu = null;
            }

            // Create the right click menu
            rightClickMenu = Util.cloneObject(rightClickContainer, lod.Globals.Loader_inventory.movieClip.userMenuScalar);

            // Add event listener
            rightClickMenu.userMenu.addEventListener('itemClick', onMenuRightClicked);

            rightClickMenu.x = rightClickContainer.mouseX;
            rightClickMenu.y = rightClickContainer.mouseY;
            rightClickCallback = newCallback;

            // Reset selection
            var data:IDataProvider = new DataProvider([]);
            rightClickMenu.userMenu.dataProvider = data;
            rightClickMenu.userMenu.rowCount = 0;

            // Put actual data in
            data = new DataProvider(items);
            rightClickMenu.userMenu.dataProvider = data;
            rightClickMenu.userMenu.rowCount = items.length;

            ignoreClick = true;
            rightClickMenu.visible = true;

            // Make it go away when clicked elsewhere
            actualStage.addEventListener(MouseEvent.CLICK, containerClickHandle);
        }

        // Hides the right click menu
        public function hide():void {
            if(rightClickMenu != null) {
                rightClickMenu.visible = false;
            }
            actualStage.removeEventListener(MouseEvent.CLICK, containerClickHandle);
        }

        // Callback for when rightclick menu is clicked
        private function onMenuRightClicked(e):void {
            // Hide the menu
            hide();

            // Run callback
            if(rightClickCallback != null) {
                rightClickCallback(e.itemRenderer["data"]["option"]);
            }
        }

        // Called when the container is clicked
        private function containerClickHandle():void {
            if(ignoreClick) {
                ignoreClick = false;
                return;
            }
            if(rightClickMenu != null && rightClickMenu.hitTestPoint(rightClickContainer.mouseX,rightClickContainer.mouseY,false)) return;
            hide();
        }
    }
}