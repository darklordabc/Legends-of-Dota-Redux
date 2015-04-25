package  {
	import flash.display.MovieClip;
    import flash.events.MouseEvent;

	public class VotingUI extends MovieClip {
        // The header
        public var votingHeader;

        // The containers to store clips into
        public var container1:MovieClip;
        public var container2:MovieClip;
        public var container3:MovieClip;

        // Container for the button
        public var lockButton:MovieClip;

        // Contains a list of option MovieClips
        private var options:Object;

        // Contains the current option list (ie: names and values)
        private var optionList:Object;

        // Callback to call to update a vote
        private var updateCallback:Function;

        // Callback to call to finish the vote
        private var finishCallback:Function;

        // Ignore updates
        private var ignoreUpdates:Boolean = false;

        public function VotingUI() {
            // Init containers
            options = {};
            optionList = {};
        }

		public function setup(newOptionList:Object, slave:Boolean, updateVoteCallback:Function, finishVoteCallback:Function):void {
            // Store the new stuff
            optionList = newOptionList;
            updateCallback = updateVoteCallback;
            finishCallback = finishVoteCallback;

            // Settings
            var padding:Number = 4;
            var spacing:Number = 24;

            // Reset container
            options = {};

            // Are we a slave?
            if(slave) {
                // Update the header
                votingHeader.text = '#voteheaderSlave';
            }

            // Empty the container
            Util.empty(container1);
            Util.empty(container2);
            Util.empty(container3);

            // Loop over all options
            for(var optNumber:Number=0;optionList[optNumber];optNumber++) {
                // Grab the option
                var option = optionList[optNumber];

                // Create the panel
                var optionPanel:MovieClip = new VotingOptionPanel(slave, option.des, option.hint, Util.objectToArray(option.options));

                // Fix depth issues
                optionPanel.addEventListener(MouseEvent.ROLL_OVER, fixDepthIssues, false, 0, true);

                // Put it into a container and position it nicely
                var con:MovieClip = this['container' + option.conID];
                con.addChild(optionPanel);
                optionPanel.x = 0;
                optionPanel.y = option.conPos * spacing;

                // Store it
                options[optNumber] = optionPanel;

                // If we're allowed to vote
                if(!slave) {
                    // Hook the button
                    createHook(optionPanel.dropDown, optNumber);
                } else {
                    // Set default value
                    updateSlave(optNumber, 0);
                }
            }

            // Spawn submit button
            if(slave) {
                lockButton.visible = false;
            } else {
                lockButton.visible = true;
                lockButton.setText('#submitvote');
                lockButton.addEventListener(MouseEvent.CLICK, onSubmitPressed);
            }
		}

        // Fixes depth issues
        private function fixDepthIssues(e:MouseEvent):void {
            // Do it
            e.currentTarget.parent.setChildIndex(e.currentTarget, e.currentTarget.parent.numChildren-1);
        }

        // Stores a given vote
        public function updateSlave(optNumber:Number, newValue:Number) {
            // Start ignoring updates
            ignoreUpdates = true;

            // Check if we even have this option number
            if(options[optNumber] != null) {
                // Validate the voting list
                if(optionList != null) {
                    // Grab the options for it
                    var option = optionList[optNumber];

                    if(option != null && option.options[newValue] != null) {
                        // Pass the update
                        options[optNumber].updateSlave(option.options[newValue], newValue);
                    }
                }
            }

            // Stop ignoring updates
            ignoreUpdates = false;
        }

        // Hooks a dropdown box
        private function createHook(dropdown:MovieClip, optNumber:Number) {
            // Create the hook
            dropdown.setIndexCallback = function(comboBox) {
                if(ignoreUpdates) return;

                // Update the vote
                updateCallback(optNumber, comboBox.selectedIndex);
            }
        }

        // When submit is pressed
        private function onSubmitPressed(e:MouseEvent) {
            // Done voting
            finishCallback();
        }
	}

}
