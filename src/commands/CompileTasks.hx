package commands;

import programs.Hxc;
import programs.Fnfc;
import helpers.Process;
import haxe.io.Path;
import sys.FileSystem;
import helpers.ZipTools;
import helpers.FileManager;
import sys.io.File;

class CompileTasks {
    public static function Task_ExportGame(mod_assets:String, hxc_source:String, fnfc_assets:String, export_mod_path:String) {
		if (!FileManager.isManifestPresent(mod_assets)) {
			Interaction.displayError(Interaction.MSG_EXPORT_META_MISSING);
			Sys.exit(0);
		}
		var manifestPath = '$mod_assets/_polymod_meta.json';
		var poly_json = File.getContent(manifestPath);

		var varGetter:EReg = ~/"mod_version": *"([0-9.]+)" */i;
		if (!varGetter.match(poly_json)) {
			Interaction.displayError(Interaction.MSG_EXPORT_META_NO_VERSION);
			Sys.exit(0);
		}

		var userModName = Interaction.requestInput(Interaction.MSG_EXPORT_ZIP_NAME);
		var userModVersion = Interaction.requestInput(Interaction.MSG_EXPORT_MOD_VERSION+' (${varGetter.matched(1)}): ');

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

	public static function Task_CompileGame(mod_assets:String, hxc_source:String, fnfc_assets:String, export_mod_path:String) // baseGane_modDir, Mod_Directory
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

	public static function Task_RunGame(game_path:String) {
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
			Interaction.displayError('No FNF binary found. Make sure that there\'s copy of FNF in $game_path directory.');
	}

	private static function copyTemplate(mod_assets:String, export_mod_path:String) {
		FileSystem.createDirectory(mod_assets);
		FileManager.scanDirectory(mod_assets, s -> {
			FileSystem.createDirectory(Path.join([export_mod_path, Path.directory(s)]));
			File.copy('$mod_assets/$s', Path.join([export_mod_path, s]));
		}, s -> {});
	}
}