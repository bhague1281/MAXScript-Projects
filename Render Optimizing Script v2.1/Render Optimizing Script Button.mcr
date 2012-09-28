/*
Render Optimizing Script v2.0 by Brian Hague
Parts of the code originated from Thorsten Hartmann and were changed by Brian Hague. See credits below the specified code block.

Version History:
v1.0		Automatically sets the background color to the default off-white, sets output size, enables Net Render/Skip Existing Frames, 
		and optimizes the renderer via memory and IBitmapPager settings
v1.1		Added opening up the Rendered Frame Window and prompting to change Image Precision/Final Gather settings. Also gives runtime confirmation.
v2.0		Redesigns the code so that functionality is placed inside functions. The function frameSettings encompasses the background color, output size, 
		and Mental Ray preset that automatically changes the Image Precision/Final Gather settings. The function optimizeSettings consists of all the 
		code that optimizes the renderer. The function openMainDialog opens a rollout that simplifies render setup. You can choose between rendering a 
		single frame or the active time segment; choosing one automatically determines if net render will be enabled. A save path can also be chosen, 
		but the textbox that displays the file path is still under development.
v2.1		Options added to unhide all objects (set to true by default), force 2 sided (set to false by default). The textbox that displays the file path 
		was also removed. Development on that will be slated for v2.2/2.3. Also, all changes made in the program are temporary until either 
		"Save and Exit" or "Render" are pressed.
*/

macroScript RenderOptimizingScript
Category:" IPSScripts"
toolTip:"Render Optimizing Script"
buttonText:"Render Optimizing Script"
icon:#("Exposure", 1)
(
	-- Function adjusts settings for frames: background color, frame size, and whether to skip existing images during render. Also chooses the mental ray preset.
	fn frameSettings =
	(
		-- Sets the background color and output size
		setBackGround(color 235 245 247)
		renderWidth = 928
		renderHeight = 714
		
		-- Skips existing images during render
		skipRenderedFrames = false
		
		-- Loads the Mental Ray preset      CHANGE THIS BEFORE RUNNING THE SCRIPT
		renderPresets.LoadAll 0 ("Z:/Backups/Interns Backups/Resources/softwares/Scripts/Render Optimizing Script v2.1/mental_ray_preset.rps")
	)

	/*
	These settings optimize the renderer so that job/frame failures are (ideally) eliminated. This code originated from the RAM Optimizer (see credits inside) 
	and was altered by eliminating GUI elements and simplifying implementation. If you would like to know how each function works, try Google or the 3ds Max 
	MAXScript Help file.
	*/
	fn optimizeSettings =
	(
		IBitmapPager.enabled = true 
		IBitmapPager.memoryLimitAutoMode = renderers.current.Memory_Limit_Auto = true
		IBitmapPager.memoryLimit_percent = .6
		IBitmapPager.memoryPadding_percent = .2
		renderers.current.Conserve_Memory = true
		renderers.current.Memory_Limit  =  IBitmapPager.memoryLimit_megabytes
		renderers.current.SlavesOnly = true
		renderers.current.Use_Placeholders = true
		renderers.current.TaskSizeAuto = true
		for obj in getClassInstances mr_Proxy do obj.Flags = 1
		/*
		Credits for the code block above:

		######################################################################################
		#
		# RAM Optimizer V1.4 (2010) by thorsten Hartmann 25.02.2010
		#
		#
		# Thorsten Hartmann
		# Krummestr. 52-53
		# 10627 Berlin
		#
		# www.infinity-vision.de  
		# hartmann@infinity-vision.de   
		############################################################
		*/
	)
	
	-- Function opens a dialog with save settings
	fn openMainDialog =
	(
		-- Creates new RolloutFloater MainDialog
		global MainDialog = newRolloutFloater "Render Optimizer" 290 240
		
		/* 
		Stores variables for the temporary save state (determined by the saveOption checkbox), the temporary output file path 
		(currently cannot be shown in the text box), the temporary state of render hidden objects, the temporary state of force 
		2-sided, the temporary state of the rendering time output, and the temporary state of net render
		*/
		global saveStateTemp = rendSaveFile
		global outputTemp = rendOutputFilename
		global renderHiddenStateTemp = true
		global forceTwoSidedTemp = false
		global rendTypeTemp = 2
		global netRenderTemp = true
		
		--this code finds the ".max" substring at the end of the file name and replaces it with .jpg
		maxFileMAXType = copy maxFileName
		maxIndex = findString maxFileMAXType ".max"
		if (maxIndex == 'undefined') then global maxFileJPGType = "*.jpg"
		else
		(
			maxIndex -= 1
			global maxFileJPGType = substring maxFileMAXType 1 maxIndex + ".jpg"
		)
		
		-- Creates a new rollout that will be added to MainDialog
		rollout renderOptimizerRollout "Save Settings" width:279 height:211
		(
			-- Creates two radio buttons so you can switch between rendering a single frame or the active time segment
			radioButtons timeOutputOptions "Time Output:" pos:[10,10] width:249 height:62 labels:#("Single Frame", "Active Time Segment") default:rendTypeTemp columns:1
			on timeOutputOptions changed state do 
			(
				case state of
				(
					-- Single Frame sets net render to false
					1: (global rendTypeTemp = 1 global netRenderTemp = false)
					-- Active time segment sets net render to true
					2: (global rendTypeTemp = 2 global netRenderTemp = true)
				)
			)
			
			-- Creates a new checkbox. If checked, the rendered frame(s) will be saved.
			checkbox saveOption "Save? (Do it)" pos:[10,75] width:97 height:20 enabled:true checked: rendSaveFile
				on saveOption changed true do
				(
					saveStateTemp = true
				)
				on saveOption changed false do
				(
					saveStateTemp = false
				)
			
			-- Opens a file browser so a save path/file name can be specified
			button browseForFilesButton "Files..." pos:[189,75] width:76 height:18
				on browseForFilesButton pressed do
				(
					try
					(
						outputTemp = getBitmapSaveFileName caption:"Render Output Path" filename: (maxFilePath + maxFileJPGType) types:"JPEG(*.jpg)|*.jpg|"
					)
					catch()
				)
				
			--Creates a new checkbox that is checked by default. If checked, all objects are unhidden.
			checkbox renderHiddenObjects "Render hidden objects" pos:[10, 130] width:130 height:20 enabled:true checked:renderHiddenStateTemp
				on renderHiddenObjects changed true do
				(
					renderHiddenStateTemp = true
				)
				on renderHiddenObjects changed false do
				(
					renderHiddenStateTemp = false
				)
				
			-- Creates a new checkbox that is unchecked by default. If checked, force two-sided will be set to true.
			checkbox forceTwoSided "Force 2-Sided" pos:[160, 130] width:130 height:20 enabled:true checked:forceTwoSidedTemp
				on forceTwoSided changed true do
				(
					forceTwoSidedTemp = true
				)
				on forceTwoSided changed false do
				(
					forceTwoSidedTemp = false
				)
			
			-- Closes the window
			button exitButton "Exit" pos:[8,172] width:79 height:26
				on exitButton pressed do 
				(
					closeRolloutFloater MainDialog
				)
				
			-- Saves settings and closes the window
			button saveAndExitButton "Save & Exit" pos:[95,172] width:79 height:26
				on saveAndExitButton pressed do 
				(
					rendOutputFilename = outputTemp
					rendSaveFile = saveStateTemp
					rendHidden = renderHiddenStateTemp
					rendForce2Side = forceTwoSidedTemp
					rendUseNet = netRenderTemp
					rendTimeType = rendTypeTemp
					closeRolloutFloater MainDialog
				)
					
			--applies the output path and determines whether to save the file or not, then starts rendering
			button renderButton "Render" pos:[182,172] width:91 height:26
				on renderButton pressed do
				(
					rendOutputFilename = outputTemp
					rendSaveFile = saveStateTemp
					rendHidden = renderHiddenStateTemp
					rendForce2Side = forceTwoSidedTemp
					rendUseNet = netRenderTemp
					rendTimeType = rendTypeTemp
					max quick render
					closeRolloutFloater MainDialog
				)
		)
		addrollout renderOptimizerRollout MainDialog
	)

	-- Execute the three functions defined previously
	frameSettings()
	optimizeSettings()
	openMainDialog()
)