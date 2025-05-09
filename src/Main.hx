import config.FunkCfg;
import commands.SetupTask;
import commands.ProjectTasks;
import commands.CompileTasks;
import haxe.Exception;

class Main {
	// public static var Mod_Directory:String = "workbench";

	// // location of v-slice engine directory (beginning in root directory)
	// public static var baseGameDir:String = "funkinGame";

	// public static var modAssetsDir:String = "mod_base";

	// public static var fnfcFilesDir:String = "fnfc_files";
	// public static var hxcFilesDir:String = "source/mod/";

	//* CONFIG END
	// location of v-slice engine's "mods" directory (beginning in "source/ttw" folder)
	//public static var baseGane_modDir:String = '../$baseGameDir/mods';
	private static final watermark:String = "Funkin Compiler v0.2";
	public static final commands:Map<String,(FunkCfg) -> Void> = [
		"setup" => (cfg) ->{
			SetupTask.task_setupEnvironment(cfg.TEMPLATE_REMOTE_SRC);
		},
		"new" => (cfg) ->{
			ProjectTasks.task_setupProject(cfg.TEMPLATE_REMOTE_SRC);
		},
		"just-run" => (cfg) ->{
			CompileTasks.Task_RunGame(cfg.GAME_PATH);
		},
		"just-compile" => (cfg) ->{
			CompileTasks.Task_CompileGame(cfg.MOD_CONTENT_FOLDER, cfg.MOD_HX_FOLDER, cfg.MOD_FNFC_FOLDER, cfg.GAME_PATH+"/mods/"+cfg.GAME_MOD_NAME);
			trace("Done!");
		},
		"run" => (cfg) ->{
			CompileTasks.Task_CompileGame(cfg.MOD_CONTENT_FOLDER, cfg.MOD_HX_FOLDER, cfg.MOD_FNFC_FOLDER, cfg.GAME_PATH+"/mods/"+cfg.GAME_MOD_NAME);
			CompileTasks.Task_RunGame(cfg.GAME_PATH);
		},
		"export" => (cfg) ->{
			CompileTasks.Task_ExportGame(cfg.MOD_CONTENT_FOLDER, cfg.MOD_HX_FOLDER, cfg.MOD_FNFC_FOLDER, cfg.GAME_PATH+"/mods/"+cfg.GAME_MOD_NAME);
			trace("Done!");
		}
	];

	public static function main() {
		var args = Sys.args();
		trace(args);
		var compileMode:String = args.length == 1 ? args[0] : "";
		if(compileMode == ""){
			interactiveMenu();
		}
		else if (commands.exists(compileMode)){
			try {
				var config = new FunkCfg();
				commands[compileMode](config);
			} catch (x:Exception) {
				Interaction.displayError('Fatal error occurred while running in "$compileMode" :\n\n${x.details()}\n');
			}
		}
		else {
			Interaction.displayError('Compile task ${compileMode} is not defined. Are you sure you typed that correctly?');
		}
	}
	static function interactiveMenu() {
		Sys.println("No arguments! Running in interactive mode...");
		Sys.println(watermark);
		var programNames = new Array<String>();
		for (str in commands.keys()){
			programNames.push(str);
			Sys.println('${programNames.length}. $str');
		}
		var user_input = Interaction.requestInput("Select program number:");
		var user_index = Std.parseInt(user_input)-1;
		if (user_index >= 0 && user_index <= programNames.length){
			try {
				var config = new FunkCfg();
				commands[programNames[user_index]](config);
				Interaction.showPressToContinue("Press any key to end interactive mode...");
			} catch (x:Exception) {
				Interaction.displayError('Fatal error occurred while running in "${programNames[user_index]}" :\n\n${x.details()}\n');
			}
		}
		else{
			Interaction.displayError('"${user_input}" is not a valid input!\n');
		}
	}
}
