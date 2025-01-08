package commands;

import helpers.Process;

class SetupTask {
    static final GIT_ERROR:String = 
    "Git is absent on this system. You can install it from here: https://git-scm.com/";
    static final HAXE_ERROR:String = 
    "You don't have haxe???\nGet it from here: https://haxe.org/download/";
    public static function task_setupEnvironment() {
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
    }
}
    