package helpers;

class Process {
	public static function spawnProcess(cwd:String, execName:String, cmd_prefix:String = "") {
		Sys.setCwd(cwd);
		var proc = new sys.io.Process('$cmd_prefix ./$execName');

		while (true) {
			try {
				var logline = proc.stdout.readLine();
				Sys.println(logline);
			} catch (Eof) {
				try {
					var code:Int = proc.exitCode();
					if (code != 0)
						Interaction.showPressToContinue();
				} catch (Exception)
					Interaction.displayError("Fatality occurred while running the game!");
				break;
			} // ? this is the weirdest way to re-direct output I have ever seen.
		}
	}
	public static function checkCommand(execName:String):Bool {
        var proc = new sys.io.Process(execName);
		var code = proc.exitCode(true);
		if( code != 0){
			Sys.println("ERROR");
			Sys.println("-------");
			Sys.println(proc.stdout.readAll());
			Sys.println("-------");

		}
		return code == 0;
    }
	public static function isPureHaxelib():Bool {
        var proc = new sys.io.Process("haxelib list");
		var code = proc.exitCode(true);
		var out = proc.stdout.readAll();
		return code == 0 && out.length == 0;
    }
}