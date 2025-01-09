import commands.SetupTask;
import commands.ProjectTasks;
import commands.CompileTasks;
import haxe.Exception;

class Main {
	public static var Mod_Directory:String = "workbench";

	// location of v-slice engine directory (beginning in root directory)
	public static var baseGameDir:String = "funkinGame";

	public static var modAssetsDir:String = "mod_base";

	public static var fnfcFilesDir:String = "fnfc_files";
	public static var hxcFilesDir:String = "source/mod/";

	//* CONFIG END
	// location of v-slice engine's "mods" directory (beginning in "source/ttw" folder)
	public static var baseGane_modDir:String = '../$baseGameDir/mods';
	public static final commands:Map<String,() -> Void> = [
		"setup" => () ->{
			SetupTask.task_setupEnvironment();
		},
		"new" => () ->{
			ProjectTasks.task_setupProject();
		},
		"just-run" => () ->{
			CompileTasks.Task_RunGame('../$baseGameDir/');
		},
		"just-compile" => () ->{
			CompileTasks.Task_CompileGame(modAssetsDir, hxcFilesDir, fnfcFilesDir, baseGane_modDir + "/" + Mod_Directory);
			trace("Done!");
		},
		"run" => () ->{
			CompileTasks.Task_CompileGame(modAssetsDir, hxcFilesDir, fnfcFilesDir, baseGane_modDir + "/" + Mod_Directory);
			CompileTasks.Task_RunGame('../$baseGameDir/');
		},
		"export" => () ->{
			CompileTasks.Task_ExportGame(modAssetsDir, hxcFilesDir, fnfcFilesDir, baseGane_modDir + "/" + Mod_Directory);
			trace("Done!");
		}
	];

	public static function main() {
		var x = () ->{

		};
		var args = Sys.args();
		trace(args);
		var compileMode:String = args.length == 1 ? args[0] : "";
		if(compileMode == ""){
			interactiveMenu();
		}
		else if (commands.exists(compileMode)){
			try {
				commands[compileMode]();
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
		var programNames = new Array<String>();
		for (str in commands.keys()){
			programNames.push(str);
			Sys.println('${programNames.length}. $str');
		}
		var user_input = Interaction.requestInput("Select program number:");
		var user_index = Std.parseInt(user_input)-1;
		if (user_index >0 && user_index <= programNames.length){
			try {
				commands[programNames[user_index]]();
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
