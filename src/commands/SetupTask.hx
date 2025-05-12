package commands;

import config.VSliceConfig;
import haxe.Exception;
import sys.FileSystem;
import helpers.LangStrings;
import helpers.Process;

using StringTools;

typedef RepoLibrary = {
	name:String,
	clone_url:String,
	commit:String
}

class SetupTask {

	public static function task_setupEnvironment() {
        var force_lib_install:Bool = false;
		var postfix = " --never";
		Sys.println(LangStrings.MSG_SETUP_CHECKING_GIT);
		if (!Process.checkCommand("git -v")) {
			Interaction.displayError(LangStrings.SETUP_GIT_ERROR);
			return;
		}
		Sys.println(LangStrings.MSG_SETUP_CHECKING_HAXE);
		if (!Process.checkCommand("haxe --version")) {
			Interaction.displayError(LangStrings.SETUP_HAXE_ERROR);
			return;
		}

		Sys.println("[SETUP] Checking haxelib..");
		if (!Process.isPureHaxelib()) {
			var choice = Interaction.requestInput(LangStrings.SETUP_HAXELIB_ERROR);
			if (choice.toLowerCase() == "yes" || choice.toLowerCase() == "y") {
				Sys.println("Continuing!");

			}
			else{
				Sys.println("Setup aborted!");
				return;
			}
		}

		Sys.println("[SETUP] Reading dependencies..");
		runSetupCommand("haxelib git thx.core  https://github.com/fponticelli/thx.core.git 2bf2b992e06159510f595554e6b952e47922f128 --never --skip-dependencies");
		runSetupCommand("haxelib git hmm  https://github.com/FunkinCrew/hmm.git --never --skip-dependencies");
		runSetupCommand("haxelib git grig.audio  https://gitlab.com/haxe-grig/grig.audio.git 57f5d47f2533fd0c3dcd025a86cb86c0dfa0b6d2 --never --skip-dependencies");
		runSetupCommand('haxelib git funkin ${VSliceConfig.funkinLib_url} ${VSliceConfig.funkinLib_hash} --always');
		var haxelib_repo = Process.resolveCommand("haxelib config").replace("\n","");
		var programCwd = Sys.getCwd();


		// This installs into a local repo. We need to move them
		Sys.println("CWD: "+'${haxelib_repo}funkin/git/');
		Sys.setCwd('${haxelib_repo}funkin/git/');
		runSetupCommand("haxelib run hmm reinstall");

		Sys.println("[SETUP] Moving dependencies..");
		for(dir in FileSystem.readDirectory('${haxelib_repo}funkin/git/.haxelib/')){
			
			try {

				FileSystem.rename(
					'${haxelib_repo}funkin/git/.haxelib/$dir',
					'${haxelib_repo}$dir'
					);
				}
				catch(x){
					trace('Move failed: ${haxelib_repo}funkin/git/.haxelib/$dir -> ${haxelib_repo}$dir/');
				}
		}
		Sys.setCwd(programCwd);

		Sys.println('[SETUP] Setup grig.audio..');
		runSetupCommand('haxelib dev grig.audio "${haxelib_repo}grig,audio/git/src"');
		
		Sys.println('[SETUP] Checking mod template..');
		if (!ProjectTasks.assertTemplateZip()) {
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
