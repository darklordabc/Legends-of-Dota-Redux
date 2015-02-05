/*
Easy Dragging system by Ash47
*/

package {
    // Flash Libraries
    import flash.display.MovieClip;

    // Events
    import flash.events.MouseEvent;

    // Glow Filter
    import flash.filters.GlowFilter;
    import flash.filters.BitmapFilterQuality;

    public class EasyDrag {
        // Contains the movieclip we are dragging
        private static var dragClip;
        private static var dragClickedClip;
        private static var dragTarget;

        // Stores all the callbacks
        private static var callbacks:Object = {};
        private static var callbackList:Array = [];

        // Callbacks for when dragging starts
        private static var callbacksStart:Object = {};

        // The stage
        private static var stage;

        // The drag effect
        private static var dragEffect:GlowFilter;

        // Called to setup everything
        public static function init(_stage) {
            // Reset all objects
            stage = _stage;
            callbacks = {};
            callbackList = [];
            callbacksStart = {};
            dragClip = null;
            dragClickedClip = null;
            dragTarget = null;

            // Setup the dragging effect
            dragEffect = new GlowFilter();
            dragEffect.blurX = 15;
            dragEffect.blurY = 15;
            dragEffect.strength = 2;
            dragEffect.inner = false;
            dragEffect.knockout = false;
            dragEffect.color = 0x0000FF;
            dragEffect.quality = BitmapFilterQuality.HIGH;
        }

        // Makes this movieclip draggable
        public static function dragMakeValidFrom(mc:MovieClip, callback:Function):void {
            mc.addEventListener(MouseEvent.MOUSE_DOWN, dragMousePressed, false, 0, true);
            mc.addEventListener(MouseEvent.MOUSE_UP, dragMouseReleased, false, 0, true);
            mc.addEventListener(MouseEvent.ROLL_OUT, dragFromRollOut, false, 0, true);

            // Store the callback
            callbacksStart[mc] = callback;
        }

        // Makes this movieclip into a valid target
        public static function dragMakeValidTarget(mc:MovieClip, callback:Function, checkCallback:Function):void {
            mc.addEventListener(MouseEvent.ROLL_OVER, dragTargetRollOver, false, 0, true);
            mc.addEventListener(MouseEvent.ROLL_OUT, dragTargetRollOut, false, 0, true);

            // Store the callback
            callbacks[mc] = {
                'callback': callback,
                'checkCallback': checkCallback,
                'mc': mc
            }

            // Store this mc
            callbackList.push(callbacks[mc]);
        }

        // Tells you if dragging is currently happening
        public static function isDragging():Boolean {
            if(dragClip) return true;
            return false;
        }

        // Runs when we are dragging something, move the drag item to our cursor
        private static function dragListener(e:MouseEvent):void {
            dragClip.x = e.stageX;
            dragClip.y = e.stageY;
        }

        // When a drag target is rolled over
        private static function dragTargetRollOver(e:MouseEvent):void {
            // Store the new target
            dragTarget = e.target;
        }

        // Runs when we are dragging something, and the mouse is released
        private static function dragMouseUp(e:MouseEvent):void {
            dragClickedClip = null;
            if(dragClip) {
                if(dragTarget) {
                    // Check if we have a callback for this MC
                    if(callbacks[dragTarget]) {
                        // Run the callback
                        callbacks[dragTarget].callback(dragTarget, dragClip);
                    }
                }

                // Remove drag object
                stage.removeChild(dragClip);
                dragClip = null;

                // Remove move event
                stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragListener);
            }

            stage.removeEventListener(MouseEvent.MOUSE_UP, dragMouseUp);

            // Tell our drop targets about it
            for(var i=0; i<callbackList.length; ++i) {
                // Grab the callback object
                var callback:Object = callbackList[i];

                if(callback) {
                    // Run the callback
                    callback.checkCallback(callback.mc, null, false);
                }
            }
        }

        // Run when something that is draggable is pressed
        private static function dragMousePressed(e):void {
            // Ensure it was a left click
            if(e.buttonIdx == 0) {
                // Store this as a possible drag
                dragClickedClip = e.currentTarget;
                dragTarget = null;
            }
        }

        // Run when something that is draggable is released
        private static function dragMouseReleased(e:MouseEvent):void {
            dragClickedClip = null;
        }

        // Run when you your mouse leaves something you can drag from
        private static function dragFromRollOut(e:MouseEvent):void {
            // Check if this is the clip we tried to drag
            if(dragClickedClip == e.target) {
                // Check if there is already a drag clip
                if(dragClip && stage.contains(dragClip)) {
                    // Remove drag object
                    stage.removeChild(dragClip);
                    dragClip = null;
                }

                // Make a new dragclip
                dragClip = new MovieClip();
                dragClip.mouseEnabled = false;
                stage.addChild(dragClip);

                dragClip.filters = [dragEffect];

                // Check if we have a callback
                if(callbacksStart[dragClickedClip]) {
                    // Run the callback, if false is returned, don't drag
                    if(!callbacksStart[dragClickedClip](dragClickedClip, dragClip)) {
                        // Remove drag object
                        stage.removeChild(dragClip);
                        dragClip = null;
                        return;
                    }
                }

                /// Tell our drop targets about it
                for(var i=0; i<callbackList.length; ++i) {
                    // Grab the callback object
                    var callback:Object = callbackList[i];

                    if(callback) {
                        // Run the callback
                        callback.checkCallback(callback.mc, dragClip, true);
                    }
                }

                // Add listeners
                stage.addEventListener(MouseEvent.MOUSE_MOVE, dragListener, false, 0, true);
                stage.addEventListener(MouseEvent.MOUSE_UP, dragMouseUp, false, 0, true);

                // Stop it from procing again
                dragClickedClip = null;
            }
        }

        // Run when the mouse leaves a valid target
        private static function dragTargetRollOut(e:MouseEvent):void {
            // Validate target
            if(e.target == dragTarget) {
                // Remove drag target
                dragTarget = null;
            }
        }
    }
}