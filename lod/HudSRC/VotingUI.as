package  {
	import flash.display.MovieClip;

	public class VotingUI extends MovieClip {
        // The header
        public var votingHeader;

        // The timer in the corner
        public var timer;

		public function VotingUI() {
            var padding:Number = 4;
            var spacing:Number = 24;

            // Grab a local reference to the voting list
            var lst = lod.votingList;

            // Where to place the movieclips
            var yy:Number = votingHeader.y + votingHeader.height;

            // Create a container to house all the options
            var con = new MovieClip();
            addChild(con);

            // Loop over all options
            for(var optNumber:Number=0;lst[optNumber];optNumber++) {
                // Grab the option
                var option = lst[optNumber];

                // Workout how many options there are in this option
                var totalOptions:Number = 0;
                while(option.options[totalOptions]) totalOptions++;

                // Create the panel
                var optionPanel:MovieClip = new VotingOptionPanel(option.des, option.hint, totalOptions);
                con.addChild(optionPanel);
                con.setChildIndex(optionPanel, 0)
                optionPanel.x = 0;
                optionPanel.y = yy;

                // Move the position up
                yy += spacing;

                // Add the options in
                for(var i:Number=0; i<totalOptions; i++) {
                    // Apply the text
                    lod.setComboBoxString(optionPanel.dropDown, i, option.options[i]);
                }

                // Hook the button
                createHook(optionPanel.dropDown, optNumber);
            }

            // Spawn submit button
            //var submitBtn:MovieClip = lod.smallButton(this, '#submitvote');
            //submitBtn.x = -submitBtn.width/2;
            //submitBtn.y = this.height - submitBtn.height - padding;
		}

        // Hooks a dropdown box
        private function createHook(dropdown:MovieClip, optNumber:Number) {
            // Create the hook
            dropdown.setIndexCallback = function(comboBox) {
                // Update the vote
                lod.updateVote(optNumber, comboBox.selectedIndex);
            }
        }
	}

}
