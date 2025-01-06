class Interaction {
	public static function displayError(msg:String) {
		trace("[ERROR] " + msg);
		showPressToContinue();
	}

	public static function showPressToContinue() {
		Sys.print("Press any key to continue");
		Sys.getChar(false);
	}
}
