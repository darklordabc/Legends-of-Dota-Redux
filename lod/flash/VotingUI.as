package  {
	import flash.display.MovieClip;
    import flash.events.MouseEvent;

	public class VotingUI extends MovieClip {
        // The header
        public var votingHeader;

        // The timer in the corner
        public var timer;

        private var options:Object;

		public function VotingUI(slave:Boolean) {
            // Settings
            var padding:Number = 4;
            var spacing:Number = 24;

            // Options container
            options = {};

            // Grab a local reference to the voting list
            var lst = lod.votingList;

            // Where to place the movieclips
            var yy:Number = votingHeader.y + votingHeader.height;

            // Are we a slave?
            if(slave) {
                // Update the header
                votingHeader.text = '#voteheaderSlave';
            }

            // Create a container to house all the options
            var con = new MovieClip();
            addChild(con);

            // Loop over all options
            for(var optNumber:Number=0;lst[optNumber];optNumber++) {
                // Grab the option
                var option = lst[optNumber];

                // Workout how many options there are in this option
                var totalOptions:Number = 0;
                while(option.options[totalOptions] != null) totalOptions++;

                // Create the panel
                var optionPanel:MovieClip = new VotingOptionPanel(slave, option.des, option.hint, totalOptions);
                con.addChild(optionPanel);
                con.setChildIndex(optionPanel, 0)
                optionPanel.x = 0;
                optionPanel.y = yy;

                // Store it
                options[optNumber] = optionPanel;

                // Move the position up
                yy += spacing;

                // If we're allowed to vote
                if(!slave) {
                    // Add the options in
                    for(var i:Number=0; i<totalOptions; i++) {
                        // Apply the text
                        lod.setComboBoxString(optionPanel.dropDown, i, option.options[i]);
                    }

                    // Hook the button
                    createHook(optionPanel.dropDown, optNumber);
                }
            }

            // Spawn submit button
            if(!slave) {
                var submitBtn:MovieClip = lod.smallButton(this, '#submitvote');
                submitBtn.x = -submitBtn.width/2;
                submitBtn.y = this.height - submitBtn.height - padding;
                submitBtn.addEventListener(MouseEvent.CLICK, onSubmitPressed);
            }
		}

        public function updateSlave(optNumber:Number, newValue:Number) {
            // Check if we even have this option number
            if(options[optNumber] != null) {
                // Grab a local reference to the voting list
                var lst = lod.votingList;

                // Validate the voting list
                if(lst != null) {
                    // Grab the options for it
                    var option = lst[optNumber];

                    if(option != null && option.options[newValue] != null) {
                        // Pass the update
                        options[optNumber].updateSlave(option.options[newValue]);
                    }
                }
            }
        }

        // Hooks a dropdown box
        private function createHook(dropdown:MovieClip, optNumber:Number) {
            // Create the hook
            dropdown.setIndexCallback = function(comboBox) {
                // Update the vote
                lod.updateVote(optNumber, comboBox.selectedIndex);
            }
        }

        // When submit is pressed
        private function onSubmitPressed(e:MouseEvent) {
            // Done voting
            lod.finishedVoting();
        }
	}

}
