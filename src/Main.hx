import programs.Hxc;
import programs.Fnfc;
import helpers.ZipTools;
import helpers.Process;
import helpers.FileManager;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
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

	static function main() {
		var args = Sys.args();
		trace(args);
		var compileMode:String = args.length == 1 ? args[0] : "";
		try {
			switch (compileMode) {
				case "just-run":
					{
						Task_RunGame('../$baseGameDir/');
					}
				case "just-compile":
					{
						Task_CompileGame(modAssetsDir, hxcFilesDir, fnfcFilesDir, baseGane_modDir + "/" + Mod_Directory);
						trace("Done!");
					}
				case "run":
					{
						Task_CompileGame(modAssetsDir, hxcFilesDir, fnfcFilesDir, baseGane_modDir + "/" + Mod_Directory);
						Task_RunGame('../$baseGameDir/');
					}
				case "export":
					{
						Task_ExportGame(modAssetsDir, hxcFilesDir, fnfcFilesDir, baseGane_modDir + "/" + Mod_Directory);
						trace("Done!");
					}
				default:
					{
						Interaction.displayError('Compile task ${compileMode} is not defined. Are you sure you typed that correctly?');
					}
			}
		} catch (x:Exception) {
			Interaction.displayError('Fatal error occurred while running in "$compileMode" :\n\n${x.details()}\n');
		}
	}

	static function Task_ExportGame(mod_assets:String, hxc_source:String, fnfc_assets:String, export_mod_path:String) {
		if (!FileManager.isManifestPresent(mod_assets)) {
			Interaction.displayError("Your mod doesn't contain \"_polymod_meta.json\". Please create a valid metadata file for this mod first!");
			Sys.exit(0);
		}
		var manifestPath = '$mod_assets/_polymod_meta.json';
		var poly_json = File.getContent(manifestPath);

		var varGetter:EReg = ~/"mod_version": *"([0-9.]+)" */i;
		if (!varGetter.match(poly_json)) {
			Interaction.displayError('It seems like your "_polymod_meta.json" is missing a "mod_version" attribute...');
			Sys.exit(0);
		}
		Sys.print("Type in a name for your exported file (without .zip):");
		var userModName = Sys.stdin().readLine();

		Sys.print('What version number should be used for this mod version? Leave blank to use the current one (${varGetter.matched(1)}): ');
		var userModVersion = Sys.stdin().readLine();

		if (userModVersion != "") {
			var validator:EReg = ~/[0-9.]+/i;
			if (!validator.match(userModVersion)) {
				Interaction.displayError("Invalid version string. Use Semacic versioning here!");
				return;
			}
			var new_poly = varGetter.replace(poly_json, '"mod_version": "${userModVersion}"');
			File.saveContent(manifestPath, new_poly);
			trace('Updated you mod\'s version to ${userModVersion}');
		}

		Task_CompileGame(mod_assets, hxc_source, fnfc_assets, export_mod_path);

		// create the output file
		var out = sys.io.File.write('${userModName}.zip', true);
		ZipTools.makeZipArchive(export_mod_path, out);
	}

	static function Task_CompileGame(mod_assets:String, hxc_source:String, fnfc_assets:String, export_mod_path:String) // baseGane_modDir, Mod_Directory
	{
		if (!FileManager.isManifestPresent(mod_assets))
			Sys.exit(0);
		FileManager.deleteDirRecursively(export_mod_path);
		copyTemplate(mod_assets, export_mod_path);
		var fnfc = new Fnfc(fnfc_assets, export_mod_path);
		var hxc = new Hxc(hxc_source, export_mod_path);
		fnfc.processDirectory();
		hxc.processDirectory();
	}

	static function Task_RunGame(game_path:String) {
		var linux_bin = FileSystem.exists(Path.join([game_path, "Funkin"]));
		var windows_bin = FileSystem.exists(Path.join([game_path, "Funkin.exe"]));
		var mac_bin = FileSystem.exists(Path.join([game_path, "Funkin.app"])); // not supported
		if (windows_bin) {
			if (Sys.systemName() == "Windows")
				Process.spawnProcess(game_path, "Funkin.exe");
			else {
				trace("[INFO] Windows build on non-windows machine. Attempting to run using wine...");
				Process.spawnProcess(game_path, "Funkin.exe", "wine ");
			}
		} else if (linux_bin) {
			if (Sys.systemName() == "Linux")
				Process.spawnProcess(game_path, "Funkin");
			else
				Interaction.displayError('Incompatible FNF version. Replace it with the windows one.');
		} else if (mac_bin && Sys.systemName() == "Mac")
			Interaction.displayError("I personally don't know how to run the game natively on your platform\n"
				+ "You might try to install wine and use Windows build instead");
		else
			Interaction.displayError('No FNF binary found. Make sure that there\'s copy of FNF in $baseGameDir directory.');
	}

	private static function copyTemplate(mod_assets:String, export_mod_path:String) {
		FileSystem.createDirectory(mod_assets);
		FileManager.scanDirectory(mod_assets, s -> {
			FileSystem.createDirectory(Path.join([export_mod_path, Path.directory(s)]));
			File.copy('$mod_assets/$s', Path.join([export_mod_path, s]));
		}, s -> {});
	}
}
