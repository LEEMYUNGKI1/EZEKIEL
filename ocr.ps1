Add-Type -AssemblyName System.Runtime.WindowsRuntime
$code = @"
using System;
using System.IO;
using System.Threading.Tasks;
using Windows.Graphics.Imaging;
using Windows.Media.Ocr;
using Windows.Storage;

public class OcrHelper {
    public static async Task<string> ExtractText(string path) {
        try {
            StorageFile file = await StorageFile.GetFileFromPathAsync(path);
            using (var stream = await file.OpenAsync(FileAccessMode.Read)) {
                BitmapDecoder decoder = await BitmapDecoder.CreateAsync(stream);
                SoftwareBitmap bitmap = await decoder.GetSoftwareBitmapAsync();
                
                OcrEngine engine = OcrEngine.TryCreateFromLanguage(new Windows.Globalization.Language("ko-KR"));
                if (engine == null) {
                    engine = OcrEngine.TryCreateFromUserProfileLanguages();
                }
                
                OcrResult result = await engine.RecognizeAsync(bitmap);
                return result.Text;
            }
        } catch (Exception ex) {
            return "Error: " + ex.Message;
        }
    }
}
"@
# Save and compile in C# using Add-Type
Add-Type -TypeDefinition $code -Language CSharp
$result = [OcrHelper]::ExtractText("f:\home\부서.jpg").GetAwaiter().GetResult()
Write-Output $result
