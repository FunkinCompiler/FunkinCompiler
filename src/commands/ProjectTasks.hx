package commands;

import haxe.io.Path;
import helpers.ZipTools;
import haxe.Http;
import sys.FileSystem;
import sys.io.File;

class ProjectTasks {
    private static final TEMPLATE_COMMIT:String = "7f72b11590b8d90b4c5cb7320c913a6ce2f44f6d";
    public static function assertTemplateZip():Bool {
        if(!FileSystem.exists("template.zip")){
            var client = new Http('https://github.com/FunkinCompiler/mod-template/archive/$TEMPLATE_COMMIT.zip');
            client.request();
            if (client.responseBytes == null){
                return false;
            }
            File.saveBytes("template.zip",client.responseBytes);
        }
        return true;
    }
    public static function task_setupProject() {
        var name = Interaction.requestInput("Type in the name of the project:");
        Sys.println("Making project...");
        if (assertTemplateZip()){
            ZipTools.extractZip(File.read("template.zip"),name);
            File.copy(Sys.programPath(),Path.join([name,"compiler.exe"]));
            if (Sys.systemName() == "Linux"){
                Sys.command('chmod +x \'${Path.join([name,"compiler.exe"])}\'');
            }
            Sys.println("Done!");
        }
        else {
            Sys.println("Couldn't find the mod template!");
        }
    }
}