package commands;

import haxe.Exception;
import sys.io.File;
import sys.FileSystem;
import helpers.FileManager;
import helpers.LangStrings;
import helpers.Process;

using StringTools;

typedef RepoLibrary = {
	name:String,
	clone_url:String,
	commit:String
}

class SetupTask {
	static final gitRepos:Array<RepoLibrary> = [
		//{name: "", commit: "", clone_url: ""},
		{name: "funkin", clone_url: "https://github.com/FunkinCompiler/Funkin-lib.git", commit: "966732aecbd0be947c2a5aaed5aa7b2d928c0ad6"},
		{name: "discord_rpc", clone_url: "https://github.com/FunkinCrew/linc_discord-rpc.git", commit: "2d83fa863ef0c1eace5f1cf67c3ac315d1a3a8a5"},
		{name: "mconsole", clone_url: "https://github.com/massive-oss/mconsole.git", commit: "06c0499ed8f80628a0e6e55ffa32c3cbd688a838"},
		{name: "lime", clone_url: "https://github.com/FunkinCrew/lime.git", commit: "872ff6db2f2d27c0243d4ff76802121ded550dd7"},
		{name: "openfl", clone_url: "https://github.com/FunkinCrew/openfl.git", commit: "8306425c497766739510ab29e876059c96f77bd2"},
		{name: "flixel", clone_url: "https://github.com/FunkinCrew/flixel.git", commit: "f2b090d6c608471e730b051c8ee22b8b378964b1"},
		{name: "flixel-addons", clone_url: "https://github.com/FunkinCrew/flixel-addons.git", commit: "7424db4e9164ff46f224a7c47de1b732d2542dd7"},
		{name: "flixel-text-input", clone_url: "https://github.com/FunkinCrew/flixel-text-input", commit: "951a0103a17bfa55eed86703ce50b4fb0d7590bc"},
		{name: "flxanimate", clone_url: "https://github.com/Dot-Stuff/flxanimate.git", commit: "0654797e5eb7cd7de0c1b2dbaa1efe5a1e1d9412"},
		{name: "FlxPartialSound", clone_url: "https://github.com/FunkinCrew/FlxPartialSound.git", commit: "a1eab7b9bf507b87200a3341719054fe427f3b15"},
		{name: "funkin,vis", clone_url: "https://github.com/FunkinCrew/funkVis.git", commit: "22b1ce089dd924f15cdc4632397ef3504d464e90"},
		{name: "grig,audio", clone_url: "https://gitlab.com/haxe-grig/grig.audio.git", commit: "57f5d47f2533fd0c3dcd025a86cb86c0dfa0b6d2"},
		{name: "hxCodec", clone_url: "https://github.com/FunkinCrew/hxCodec.git", commit: "61b98a7a353b7f529a8fec84ed9afc919a2dffdd"},
		{name: "haxeui-core", clone_url: "https://github.com/haxeui/haxeui-core.git", commit: "22f7c5a8ffca90d4677cffd6e570f53761709fbc"},
		{name: "haxeui-flixel", clone_url: "https://github.com/haxeui/haxeui-flixel.git", commit: "28bb710d0ae5d94b5108787593052165be43b980"},
		{name: "jsonpatch", clone_url: "https://github.com/EliteMasterEric/jsonpatch.git", commit: "f9b83215acd586dc28754b4ae7f69d4c06c3b4d3"},
		{name: "jsonpath", clone_url: "https://github.com/EliteMasterEric/jsonpath.git", commit: "7a24193717b36393458c15c0435bb7c4470ecdda"},
		{name: "json2object", clone_url: "https://github.com/FunkinCrew/json2object.git", commit: "a8c26f18463c98da32f744c214fe02273e1823fa"},
		{name: "thx,semver", clone_url: "https://github.com/FunkinCrew/thx.semver.git", commit: "cf8d213589a2c7ce4a59b0fdba9e8ff36bc029fa"},
		{name: "thx,core", clone_url: "https://github.com/FunkinCrew/thx.core.git", commit: "22605ff44f01971d599641790d6bae4869f7d9f4"},
		{name: "hscript", clone_url: "https://github.com/FunkinCrew/hscript.git", commit: "12785398e2f07082f05034cb580682e5671442a2"},
		{name: "polymod", clone_url: "https://github.com/larsiusprime/polymod.git", commit: "0fbdf27fe124549730accd540cec8a183f8652c0"},
	];
	static final dependencies:Array<Array<String>> = [
		["install", "format", "3.5.0"],
		["install", "hamcrest", "3.0.0"],
		["install", "hxp", "1.2.2"]
	];

	public static function task_setupEnvironment(template_url:String) {
        var force_lib_install:Bool = false;
		var postfix = " --never";
		Sys.println("[SETUP] Checking git..");
		if (!Process.checkCommand("git -v")) {
			Interaction.displayError(LangStrings.SETUP_GIT_ERROR);
			return;
		}
		Sys.println("[SETUP] Checking haxe..");
		if (!Process.checkCommand("haxe --version")) {
			Interaction.displayError(LangStrings.SETUP_HAXE_ERROR);
			return;
		}

		Sys.println("[SETUP] Checking haxelib..");
		if (!Process.isPureHaxelib()) {
			var choice = Interaction.requestInput(LangStrings.SETUP_HAXELIB_ERROR);
			if (choice.toLowerCase() == "yes" || choice.toLowerCase() == "y") {
				//postfix = ;
                force_lib_install = true;
				Sys.println("Overriding libraries!");
			}
		}

		for (line in dependencies) {
			Sys.println('[SETUP] Installing ${line[1]}..');
            var postfix = force_lib_install ? " --always" : " --never";
			var cmd = 'haxelib ' + line.join(" ") + postfix;
			Sys.println("> " + cmd);
			var code = Process.spawnProcess(cmd);
			if (code == 0)
				Sys.println("Done!");
			else
				Sys.println("[ERROR " + code + "] Command failed! Ignoring..");
		}

        var repo = Process.resolveCommand("haxelib config").replace("\n","");
        var programCwd = Sys.getCwd();
        for (line in gitRepos) {
			Sys.println('[SETUP] Installing ${line.name}..');
            if(FileSystem.exists('$repo${line.name}')){
                if(force_lib_install) {
                    trace('Trashing $repo${line.name}');
                    FileManager.deleteDirRecursively('$repo${line.name}');
                }
                else continue;
            }
                
                if(!runSetupCommand('git init "$repo${line.name}/git"')) continue;
                Sys.setCwd('$repo${line.name}/git');
                if(!runSetupCommand('git remote add origin ${line.clone_url}')) continue;
                if(!runSetupCommand('git fetch --depth=1 origin ${line.commit}')) continue;
                if(!runSetupCommand('git checkout FETCH_HEAD')) continue;
                
			
            File.saveContent('$repo${line.name}/.current',"git");
		}
        Sys.setCwd(programCwd);
		Sys.println('[SETUP] Checking mod template..');
		if (!ProjectTasks.assertTemplateZip(template_url)) {
			Sys.println("Mod template is missing!");
		}

		Sys.println("[SETUP] Setup done!");
	}
    static function runSetupCommand(cmd:String):Bool {
        Sys.println("   > " + cmd);
        var code = Process.spawnProcess(cmd);
        if (code == 0)
            Sys.println("   Done!");
        else
            Sys.println("   [ERROR " + code + "] Command failed! Ignoring..");
		return code == 0;
    }
}
