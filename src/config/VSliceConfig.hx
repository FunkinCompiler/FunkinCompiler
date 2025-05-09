package config;
using StringTools;

class VSliceConfig {
    public static inline final funkinLib_url:String = "https://github.com/FunkinCompiler/Funkin-lib.git";
    public static inline final funkinLib_hash:String = "a9c2f30835bee2316147c6bfcf7922e75a3e8fa3";
    
    public static function getTemplateUrl(url:String) {
        url = url.trim();
        if (url == "" || url.contains(" ")) url = "0.6.3";
        else if(url.startsWith("http")) return url;
        return 'https://raw.githubusercontent.com/FunkinCompiler/template-binaries/refs/heads/main/${url}.zip';
    }
}