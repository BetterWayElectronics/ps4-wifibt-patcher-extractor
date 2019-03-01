
Hello!

This program, a micro version of my PS4 NOR Validator, is designed solely to validate and repair the WiFi/BT module of your PS4.

How do I know I need it repaired? Well if your controller does not sync anywhere but the safe mode menu then your module is corrupted.
Note: If your controller does not sync in safe mode, this program is not for you! You have a southbridge/usb port issue.
Note: If your module is VALID but there is still no controller sync anywhere other than safemode, you physically need a new module (match it based on its revision).

I have included a small sample of VALID patches for you to use, but you may have to source more yourself. 
Just place them in the /Patches/ directory with any file name.

If your patch isnt listed and you enjoy risk, my program will allow this. You can patch a mis-matched firmware for your WiFi/BT module.
Doing this will wipe c0020001.bin and its header from your PS4's NOR entirely and replace it with whatever you have chosen.
I recommend you stick with the correct Torus version, which will be displayed on screen. Slim & Pro models are generally Torus 2.

If you hate risk but still want to patch, simply ask around for your matching patch file. Just quote the file size.

If you have found a patch that is not on my list, let me know at bwe@betterwayelectronics.com.au and send me a link to it.
Feel free to use my EXTRACTOR to verify its validity and ensure proper extracting!

I will add any new patches to my program in future revisions.


Version History:
1.3.4 (1/3/19) - Added FW/BIOS Versioning, Prettied It Up (Behind The Scenes Too) & Released to GitHub!
1.3.3 (1/3/19) - Combined Patcher & Extractor, Added Additional Patch & Added Version Checker.
1.3 (22/12/18) - Converted to 32bit (Hello 3absiso!), No Other Changes (Because this program is GREAT)
1.2 (27/11/18) - Fixed Entropy + Added Better MD5 Validation + Added Better Header Validation
1.1 (25/11/18) - Added Entropy  
