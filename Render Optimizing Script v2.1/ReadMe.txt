Thank you for downloading Render Optimizing Script (ROS). This MAXScript 
was originally designed to reduce the number of failures when rendering 
scenes using 3ds Max. In addition, settings were added in order to make 
rendering easier (e.g. render a single frame/an active time segment, 
render hidden objects, force two-sided, etc.). In order to make the code 
more reusable, I have made a couple different files that you can implement. 
They include...

-Render Optimizing Script Autorun
	This file runs the MAXScript 

-Render Optimizing Script Button
	This file allows you to add ROS as a button within 3ds Max. A
	tutorial on how to do this is given below.

-mental_ray_preset_rps
	This file stores the presets for the mental ray renderer. However,
	you can change these presets very easily in order to suit your
	particular needs. Google or check the 3DS MAX Help file for information
	on how to make a preset.

There is also a settings file titled settings.ini, where you can add values
that ROS will automatically load during startup. File creation capabilities
have not been added as of now (slated for 2.3 or later). Until then, you can
open the settings.ini file and change settings by hand. The file is set up
in the following simple format:

<Setting name>
<Setting value>

<Setting name>
<Setting value>

...<repeat>...

Also, you can currently change the following:
mentalRayPreset
backgroundColor
frameWidth
frameHeight
saveState
renderHiddenObjects
force2Sided
skipRenderedFrames
timeType
netRender


How to Add a Button in 3ds Max (using 3ds Max 2011)
-------------------------------
1. Go to C:\Program Files\Autodesk\3ds Max 2011\Scripts\Startup
2. Copy Render Optimizing Script Button and settings.ini (if available) to this folder.
3. Open 3ds Max.
4. Go to Customize -> Customize User Interface
5. Select the Toolbars tab.
6. Via the Category drop-down box, select Scripts
7. ROS should appear in the window.
8. Drag the icon/text for ROS and drop it into the top toolbar
   (or whatever toolbar is convenient).
9. You're done! Now go render some stuff!