package  {

	import flash.display.MovieClip;


	public class dotaSearchBox extends MovieClip {
		// Container for searchbox
		public var container:MovieClip;

		// Will container the searchbox itself
		public var searchBox:MovieClip;

		public function dotaSearchBox() {
		}

		// Setsup the search box
		public function initSearchbox() {
			if(searchBox) return;
			searchBox = Util.searchBox(container);
		}
	}

}
