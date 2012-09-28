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

Since this script was written with the intent of being an in-house product, 
many of the settings in the first two files may need to be changed to suit
your project. The settings you may be interested in changing are listed below.

fn frameSettings
	-background color
	-frame width/height
	-skipping existing images during render
	-loading a mental ray preset