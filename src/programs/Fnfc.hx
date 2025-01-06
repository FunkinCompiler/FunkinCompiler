package programs;

import helpers.FileManager;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import haxe.zip.Reader;
using StringTools;

class Fnfc {
    private var path:String;
	  var mod_export_path:String;
    public function new(fnfc_path:String,mod_export_path:String) {
        path = fnfc_path;
        this.mod_export_path = mod_export_path; //baseGane_modDir, Mod_Directory
    }
    public function processDirectory() {
        FileManager.scanDirectory(path,processFile, s -> {});
    }
    public function processFile(file_path:String) {
        if (!file_path.endsWith(".fnfc"))
            {
              trace('[WARN] $file_path is not a valid chart file. Ignoring!');
              return;
            }
            var zip = Reader.readZip(File.read(Path.join([path, file_path])));
            trace(file_path.substr(1));
      
            var fnfc_manifestList = zip.filter(s -> s.fileName == "manifest.json");
            if (fnfc_manifestList.length != 1)
            {
              Interaction.displayError('File $file_path doesn\'t contain a valid "manifest.json" file');
              Sys.exit(0);
            }
            var fnfc_manifest = fnfc_manifestList.first().data.toString();
            var varGetter:EReg = ~/"songId": *"(.+)" */i;
            if (!varGetter.match(fnfc_manifest))
            {
              Interaction.displayError('It seems like "manifest.json" in $file_path is missing a "songId" attribute...');
              Sys.exit(0);
            }
            var songId = varGetter.matched(1);
            for (node in zip)
            {
              var target_File = "";
              if (node.fileName.endsWith(".json"))
              {
                target_File = Path.join([mod_export_path, "data/songs", songId, node.fileName]);
              }
              else if (node.fileName.endsWith(".ogg"))
              {
                target_File = Path.join([mod_export_path, "songs", songId, node.fileName]);
              }
              else
              {
                trace('[WARN] file ${node.fileName} is not known to be valid. Ignoring!');
                continue;
              }
              FileSystem.createDirectory(Path.directory(target_File));
              File.saveBytes(target_File, node.data);
            }
    }
}