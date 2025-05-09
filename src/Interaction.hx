class Interaction {


	public static function displayError(msg:String) {
		trace("[ERROR] " + msg);
		showPressToContinue();
	}

	public static function requestInput(prompt:String) {
		Sys.print(prompt);
		return Sys.stdin().readLine();
	}
	public static function showPressToContinue(prompt:String = "Press any key to continue") {
		Sys.print(prompt);
		Sys.getChar(false);
		#if windows
		Sys.print("\n");
		#end
	}

}
