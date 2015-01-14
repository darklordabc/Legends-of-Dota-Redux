package  {
	import flash.display.MovieClip;
    import flash.events.MouseEvent;

	public class VotingUI extends MovieClip {
        // The header
        public var votingHeader;

        // The container to store clips into
        public var container:MovieClip;

        // Container for the button
        public var buttonContainer:MovieClip;

        // Contains a list of option MovieClips
        private var options:Object;

        // Contains the current option list (ie: names and values)
        private var optionList:Object;

        // Callback to call to update a vote
        private var updateCallback:Function;

        // Callback to call to finish the vote
        private var finishCallback:Function;

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

            // Where to place the movieclips
            var yy:Number = votingHeader.y + votingHeader.height;

            // Are we a slave?
            if(slave) {
                // Update the header
                votingHeader.text = '#voteheaderSlave';
            }

            // Empty the container
            Util.empty(container);

            // Loop over all options
            for(var optNumber:Number=0;optionList[optNumber];optNumber++) {
                // Grab the option
                var option = optionList[optNumber];

                // Create the panel
                var optionPanel:MovieClip = new VotingOptionPanel(slave, option.des, option.hint, Util.objectToArray(option.options));
                container.addChild(optionPanel);
                container.setChildIndex(optionPanel, 0)
                optionPanel.x = 0;
                optionPanel.y = yy;

                // Store it
                options[optNumber] = optionPanel;

                // Move the position up
                yy += spacing;

                // If we're allowed to vote
                if(!slave) {
                    // Hook the button
                    createHook(optionPanel.dropDown, optNumber);
                }
            }

            // Spawn submit button
            if(!slave) {
                var submitBtn:MovieClip = Util.smallButton(buttonContainer, '#submitvote', true, true);
                submitBtn.addEventListener(MouseEvent.CLICK, onSubmitPressed);
            }
		}

        // Stores a given vote
        public function updateSlave(optNumber:Number, newValue:Number) {
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
        }

        // Hooks a dropdown box
        private function createHook(dropdown:MovieClip, optNumber:Number) {
            // Create the hook
            dropdown.setIndexCallback = function(comboBox) {
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
