package commands;

import helpers.Process;

class SetupTask {
    static final GIT_ERROR:String = 
    "Git is absent on this system. You can install it from here: https://git-scm.com/";
    static final HAXE_ERROR:String = 
    "You don't have haxe???\nGet it from here: https://haxe.org/download/";
    static final HAXELIB_ERROR:String = 
    "You seem to have non-empty, or absent dependencies folder.\n"+
    "You can reinstall existing dependencies, or keep them as is.\n"+
    "Do you want to reinstall? (yes/no): ";
    static final dependencies:Array<Array<String>> = [
        ["git","funkin",            "https://github.com/FunkinCompiler/Funkin-lib.git",     "da3c009e613c1661493750267a4c744ce0107e73"],
        ["git","discord_rpc",       "https://github.com/FunkinCrew/linc_discord-rpc",       "2d83fa863ef0c1eace5f1cf67c3ac315d1a3a8a5"],
        ["git","mconsole",          "https://github.com/massive-oss/mconsole",              "06c0499ed8f80628a0e6e55ffa32c3cbd688a838"],
        ["git","lime",              "https://github.com/FunkinCrew/lime",                   "872ff6db2f2d27c0243d4ff76802121ded550dd7"],
        ["git","openfl",            "https://github.com/FunkinCrew/openfl",                 "8306425c497766739510ab29e876059c96f77bd2"],
        
        ["git","flixel",            "https://github.com/FunkinCrew/flixel",                 "f2b090d6c608471e730b051c8ee22b8b378964b1"],
        ["git","flixel-addons",     "https://github.com/FunkinCrew/flixel-addons",          "7424db4e9164ff46f224a7c47de1b732d2542dd7"],
        ["git","flixel-text-input", "https://github.com/FunkinCrew/flixel-text-input",      "951a0103a17bfa55eed86703ce50b4fb0d7590bc"],
        ["git","flixel-ui",         "https://github.com/HaxeFlixel/flixel-ui",              "27f1ba626f80a6282fa8a187115e79a4a2133dc2"],
        ["git","flxanimate",        "https://github.com/Dot-Stuff/flxanimate",              "0654797e5eb7cd7de0c1b2dbaa1efe5a1e1d9412"],
        ["git","FlxPartialSound",   "https://github.com/FunkinCrew/FlxPartialSound.git",    "a1eab7b9bf507b87200a3341719054fe427f3b15"],

        ["git","funkin.vis",        "https://github.com/FunkinCrew/funkVis",                "22b1ce089dd924f15cdc4632397ef3504d464e90"],
        ["git","grig.audio",        "https://gitlab.com/haxe-grig/grig.audio.git",          "57f5d47f2533fd0c3dcd025a86cb86c0dfa0b6d2"],
        ["git","hxCodec",           "https://github.com/FunkinCrew/hxCodec",                "61b98a7a353b7f529a8fec84ed9afc919a2dffdd"],

        ["git","haxeui-core",       "https://github.com/haxeui/haxeui-core",                "22f7c5a8ffca90d4677cffd6e570f53761709fbc"],
        ["git","haxeui-flixel",     "https://github.com/haxeui/haxeui-flixel",              "28bb710d0ae5d94b5108787593052165be43b980"],

        ["git","jsonpatch",         "https://github.com/EliteMasterEric/jsonpatch",         "f9b83215acd586dc28754b4ae7f69d4c06c3b4d3"],
        ["git","jsonpath",          "https://github.com/EliteMasterEric/jsonpath",          "7a24193717b36393458c15c0435bb7c4470ecdda"],
        ["git","json2object",       "https://github.com/FunkinCrew/json2object",            "a8c26f18463c98da32f744c214fe02273e1823fa"],
        ["git","thx.semver",        "https://github.com/FunkinCrew/thx.semver",             "cf8d213589a2c7ce4a59b0fdba9e8ff36bc029fa"],
        ["git","thx.core",          "https://github.com/FunkinCrew/thx.core",               "22605ff44f01971d599641790d6bae4869f7d9f4"],

        ["git","hscript",           "https://github.com/FunkinCrew/hscript",                "12785398e2f07082f05034cb580682e5671442a2"],
        ["git","polymod",           "https://github.com/larsiusprime/polymod",              "0fbdf27fe124549730accd540cec8a183f8652c0"],
        ["install","format",    "3.5.0"],
        ["install","hamcrest",  "3.0.0"],
        ["install","hxp",       "1.2.2"]
    ];
    public static function task_setupEnvironment() {
        var postfix = " --never";
        Sys.println("[SETUP] Checking git..");
        if(!Process.checkCommand("git -v")){
            Interaction.displayError(GIT_ERROR);
            return;
        }
        Sys.println("[SETUP] Checking haxe..");
        if(!Process.checkCommand("haxe --version")){
            Interaction.displayError(HAXE_ERROR);
            return;
        }

        Sys.println("[SETUP] Checking haxelib..");
        if(!Process.isPureHaxelib()){
            var choice = Interaction.requestInput(HAXELIB_ERROR);
            if(choice.toLowerCase() == "yes" || choice.toLowerCase() == "y") {
                postfix = " --always";
                Sys.println("Overriding libraries!");
            }
        }
        for (line in dependencies){
            Sys.println('[SETUP] Installing ${line[1]}..');
            var success = Process.checkCommand('haxelib '+line.join(" ")+postfix);
        }
        Sys.println('[SETUP] Checking mod template..');
        if (!ProjectTasks.assertTemplateZip()){
            Sys.println("Mod template is missing! Attempting to download..");
            ProjectTasks.assertTemplateZip();
        }
        Sys.println("[SETUP] Setup done!");
    }
}
    