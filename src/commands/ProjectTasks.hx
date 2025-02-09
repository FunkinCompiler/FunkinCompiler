package commands;

import helpers.Config;
import haxe.io.Path;
import helpers.ZipTools;
import haxe.Http;
import sys.FileSystem;
import sys.io.File;

class ProjectTasks {
    public static function assertTemplateZip(cfg:Config):Bool {
        if(!FileSystem.exists("template.zip")){
            var client = new Http(cfg.TEMPLATE_REMOTE_SRC);
            client.request();
            if (client.responseBytes == null){
                return false;
            }
            File.saveBytes("template.zip",client.responseBytes);
        }
        return true;
    }
    public static function task_setupProject(cfg:Config) {
        var name = Interaction.requestInput("Type in the name of the project:");
        Sys.println("Making project...");
        if (assertTemplateZip(cfg)){
            ZipTools.extractZip(File.read("template.zip"),name);
            File.copy(Sys.programPath(),Path.join([name,"compiler.exe"]));
            File.copy("funk.cfg",Path.join([name,"funk.cfg"]));
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