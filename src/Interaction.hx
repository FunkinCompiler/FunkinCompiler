class Interaction {
	public static final MSG_EXPORT_ZIP_NAME:String = 
		"Type in a name for your exported file (without .zip):";
	public static final MSG_EXPORT_META_MISSING:String = 
		"Your mod doesn't contain \"_polymod_meta.json\". Please create a valid metadata file for this mod first!";
	public static final MSG_EXPORT_META_NO_VERSION:String = 
		'It seems like your "_polymod_meta.json" is missing a "mod_version" attribute...';
	public static final MSG_EXPORT_MOD_VERSION:String = "What version number should be used for this mod version? Leave blank to use the current one";
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
