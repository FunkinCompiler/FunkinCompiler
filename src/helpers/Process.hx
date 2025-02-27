package helpers;

class Process {
	public static function spawnProcess(cmd:String):Int {	
		var proc = new sys.io.Process(cmd);
		while (true) {
			try {
				var logline = proc.stdout.readLine();
				Sys.println(logline);
			} catch (Eof) {
				try {
					var code:Int = proc.exitCode();
					return code;
				} catch (Exception)
					Sys.println("Fatality occurred while running the game!");
					return -1000;
				break;
			} // ? this is the weirdest way to re-direct output I have ever seen.
		}
		return 0;
	}
	public static function spawnFunkinGame(cwd:String, execName:String, cmd_prefix:String = "") {
		Sys.setCwd(cwd);
		var code = spawnProcess('$cmd_prefix ./$execName');
		if(code != 0)
			Interaction.showPressToContinue();
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
	public static function resolveCommand(command:String):String {
        var proc = new sys.io.Process(command);
		var code = proc.exitCode(true);
		var out = proc.stdout.readLine();
		return out;
    }
}