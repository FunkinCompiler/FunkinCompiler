package commands;

import config.VSliceConfig;
import helpers.LangStrings;
import config.FunkCfg;
import haxe.io.Path;
import helpers.ZipTools;
import haxe.Http;
import sys.FileSystem;
import sys.io.File;

class ProjectTasks {
    public static function assertTemplateZip():Bool {
        if(!FileSystem.exists("template.zip")){
            var input_url = Interaction.requestInput(LangStrings.SETUP_PROJECT_URL_PROMPT);
            var url = VSliceConfig.getTemplateUrl(input_url);
            Sys.println("Downloading from "+url);
            var client = new Http(url);
            client.request();
            if (client.responseBytes == null){
                return false;
            }
            File.saveBytes("template.zip",client.responseBytes);
        }
        return true;
    }
    public static function task_setupProject() {
        var name = Interaction.requestInput(LangStrings.PROJECT_NAME_PROMPT);
        Sys.println("Making project...");
        if (assertTemplateZip()){
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