using System;
using System.Threading.Tasks;
using Windows.Storage;
using Windows.Storage.Streams;
using System.IO;
using System.Threading;

namespace Change_Lockscreen
{
    class Program
    {
        private const String webdav = "-Webdav";
        private const String fullPath = "-FullPath";

        static void printUsage()
        {
            Console.WriteLine("It is required to set the Webdav or the FullPath parameter:\n" +
                   "Examples:\n" +
                   "Change-Lockscreen.exe -FullPath \\\\imageserver@80\\fakePath\\image.jpg \n" +
                   "Change-Lockscreen.exe -Webdav \\\\imageserver@80\\ \n");
        }

        static void Main(string[] args)
        {
            if (args.Length == 2)
            {
                if (args[0] == webdav || args[0] == fullPath)
                {
                    MainAsync(args[0], args[1]).Wait();
                }
                else
                {
                    printUsage();
                }
            }
            else
            {
                printUsage();
            }
        }

        static async Task MainAsync(String type, String path)
        {
            var oldImageStream = Windows.System.UserProfile.LockScreen.GetImageStream();
            StorageFile newImage;
            String finalPath = path;
            if (type == webdav)
            {
                string randomPath = Path.GetRandomFileName();
                randomPath = randomPath.Replace(".", "");
                finalPath = path + randomPath + "\\image.jpg";
            }

            try
            {
                newImage = await StorageFile.GetFileFromPathAsync(finalPath);
            }
            catch
            {
                Console.WriteLine("Sorry, something went wrong. \n" +
                    "Possible solutions: \n" +
                    "1 - Check if specified path is correct \n" +
                    "2 - Wait one minute and try again \n" +
                    "3 - Restart WebDAV server and try again");
                return;

            }

            
            try
            {
                await Windows.System.UserProfile.LockScreen.SetImageStreamAsync(oldImageStream);
            }
            catch
            {
                Console.WriteLine("Windows Spotlight mode in use");
            }
            Thread.Sleep(2000);
            await Windows.System.UserProfile.LockScreen.SetImageFileAsync(newImage);
        }
    }
}