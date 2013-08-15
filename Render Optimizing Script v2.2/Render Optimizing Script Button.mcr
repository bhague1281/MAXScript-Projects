/*
Render Optimizing Script v2.2 by Brian Hague
Ideas for the function optimizeSettings from Thorsten Hartmann.
See code for more details.

Version History:
v1.0		Automatically sets the background color to the default off-white,
			sets output size, enables Net Render/Skip Existing Frames, 
			and optimizes the renderer via memory and IBitmapPager settings
			
v1.1		Added opening up the Rendered Frame Window and prompting to change
			Image Precision/Final Gather settings. Also gives runtime
			confirmation.
			
v2.0		Redesigns the code so that functionality is placed inside
			functions.
			
			frameSettings: encompasses the backgroundcolor, output size, and
			Mental Ray preset that automatically changes the
			Image Precision/Final Gather settings.
			
			optimizeSettings: consists of all the code that optimizes the
			renderer.
			
			openMainDialog: opens a rollout that simplifies render setup. You
			can choose between rendering a single frame or the active time
			segment; choosing one automatically determines if net render will
			be enabled. A save path can also be chosen, but the textbox that
			displays the file path is still under development.
			
v2.1		Options added to unhide all objects (set to true by default), force
			2 sided (set to false by default). The textbox that displays the
			file path was also removed. Development on that will be slated for
			v2.2/2.3. Also, all changes made in the program are temporary until
			either "Save and Exit" or "Render" are pressed.
			
v2.2		Efforts made to make code more robust and alterable, including
			making instant changes whenever possible and displaying various
			error/warning messages.

			Additional options added:
				-Background color     (alterable)
				-Frame width/height   (alterable)
				-Skip rendered frames (alterable)
				-Optimize renderer    (calls optimizeSettings())
				-Frames time ouput option
				-Switch to a camera   (if in perspective view)
				
			Also, an optional settings file will determine the default values
			for most settings. Otherwise, they will be set to their values in
			the corresponding 3ds Max file.
			
			NOTE: Mental ray must be used with all versions of ROS, which is
			enforced in loadSettings.
*/

macroScript RenderOptimizingScript
Category: "Scripts"
toolTip: "Render Optimizing Script"
buttonText: "Render Optimizing Script"
icon:#("Exposure", 1)
(
	/*
		Function loads settings from an optional settings.ini file. Also checks
		that the mental ray renderer is selected (otherwise, will automatically
		change the renderer)
	*/
	fn loadSettings =
	(
		try
		(
			settingsFile = openFile "settings.ini"
			if settingsFile == undefined then throw "File not found/Error"
			
			/*
				Read the file and parse settings.
				File format:
			
				settingName1
				theSetting
			
				settingName2
				theSetting
				
				...
			*/
			while not (eof settingsFile) do
			(
				aSetting = readLine settingsFile
				case aSetting of
				(
					--load mental ray preset and print confirmation
					"mentalRayPreset":
					(
						renderPresets.LoadAll 0 (readLine settingsFile)
						print "Render preset has been loaded."
					)
					--set and print background color
					"backgroundColor":
					(
						r = readLine settingsFile as float
						g = readLine settingsFile as float
						b = readLine settingsFile as float
						
						backgroundColor = color r g b
						print backgroundColor
					)
					--set and print frame width
					"frameWidth":
					(
						renderWidth = readLine settingsFile as integer
						print renderWidth
					)
					--set and print frame height
					"frameHeight":
					(
						renderHeight = readLine settingsFile as integer
						print renderHeight
					)
					--set and print whether to save rendered files
					"saveState":
					(
						theState = readLine settingsFile
						if theState == "true" then rendSaveFile = true
							else rendSaveFile = false
						
						print rendSaveFile
					)
					--set and print whether to render hidden objects
					"renderHiddenObjects":
					(
						aBoolean = readLine settingsFile
						if aBoolean == "true" then rendHidden = true
							else rendHidden = false
						
						print rendHidden
					)
					--set and print whether to force 2 sided
					"force2Sided":
					(
						aBoolean = readLine settingsFile
						if aBoolean == "true" then rendForce2Side = true
							else rendForce2Side = false
						
						print rendForce2Side
					)
					--set and print whether to skip rendered frames
					"skipRenderedFrames":
					(
						aBoolean = readLine settingsFile
						if aBoolean == "true" then skipRenderedFrames = true
							else skipRenderedFrames = false
						
						print skipRenderedFrames
					)
					--set and print time output (single/active segment/frames)
					"timeType":
					(
						rendTimeType = readLine settingsfile as integer
						
						print rendTimeType
					)
					--set and print whether to net render
					"netRender":
					(
						aBoolean = readLine settingsFile
						if aBoolean == "true" then rendUseNet = true
							else rendUseNet = false
						
						print rendUseNet
					)
				)
			)
		)
		catch
		(
			"File not found/Error"
		)
	)

	/*
	These settings optimize the renderer so that job/frame failures are
	(ideally) eliminated. Ideas for this code originated from the RAM Optimizer
	(see credits inside) and was altered by eliminating GUI elements and
	simplifying implementation.
	*/
	fn optimizeSettings =
	(
		IBitmapPager.enabled = true 
		IBitmapPager.memoryLimitAutoMode = 
			renderers.current.Memory_Limit_Auto = true
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

			###################################################################
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
			###################################################################
		*/
	)
	
	--Return an array consisting of camera names and "Perspective"
	fn getCameraStringArray =
	(
		--create list of views (perspective + cameras)
		views = #("Perspective")
		
		--for each camera
		for aCamera in cameras do
		(
			if aCamera == undefined then continue
			
			/*
				This superClassID identifies a camera (not a target)
				and adds it to views as a string
			*/
			if aCamera.superClassID == 32 then append views aCamera.name
		)
		
		return views
	)
	
	--parse a cameraString, returning its corresponding camera
	fn parseCameraString cameraString =
	(
		for aCamera in cameras do
		(
			if aCamera.name == cameraString then return aCamera
		)
		
		return undefined
	)
	
	--
	
	/*
		Displays a warning dialog if in perspective view, asking if you want
		to change to a camera view. A drop-down list of cameras is provided.
	*/
	fn perspectiveWarning =
	(
		global PerspectiveWarningDialog = newRolloutFloater "Perspective Warning" 350 230
		global views = getCameraStringArray()
		global cameraNodeTemp = undefined
		
		rollout perspectiveWarningRollout "Perspective Warning" width:338 height:204
		(
			--Warning label
			label warning "WARNING: Perspective view is currently enabled." pos:[49,6] width:239 height:19
			
			--Camera drop-down list
			dropDownList viewportSelection "Current Viewport Selection:" pos:[96,59] items:views width:146 height:40
			on viewportSelection selected aView do
			(
				cameraNodeTemp = parseCameraString(aView)
			)				
			
			--Continue without changing cameras
			button saveAndContinue "Continue" pos:[253,159] width:78 height:34
			on saveAndContinue pressed do
			(
				max quick render
				closeRolloutFloater PerspectiveWarningDialog
			)
			
			--Continue with saving camera changes
			button saveCamerasAndContinue "Save Changes and Continue" pos:[94,158] width:150 height:34
			on saveCamerasAndContinue pressed do
			(
				if cameraNodeTemp != undefined then viewport.setCamera cameraNodeTemp
				max quick render
				closeRolloutFloater PerspectiveWarningDialog
			)
			
			--Exit
			button exitButton "Exit" pos:[8,159] width:79 height:33
			on exitButton pressed do closeRolloutFloater PerspectiveWarningDialog
		)
		
		addRollout perspectiveWarningRollout PerspectiveWarningDialog
	)
	
	-- Function opens a dialog with save settings
	fn openMainDialog =
	(
		-- Creates new RolloutFloater MainDialog
		global MainDialog = newRolloutFloater "Render Optimizer" 310 410
		
		--Stores temporary variables for various options
		global backgroundColorTemp = getBackGround()
		global frameWidthTemp = renderWidth
		global frameHeightTemp = renderHeight
		global timeTypeTemp = rendTimeType
		global frameValuesTemp = rendPickupFrames
		global saveStateTemp = rendSaveFile
		global fileOutputTemp = rendOutputFilename
		global renderHiddenObjectsTemp = rendHidden
		global force2SidedTemp = rendForce2Side
		global skipRenderedFramesTemp = skipRenderedFrames
		global optimizeTemp = true
		global netRenderTemp = rendUseNet
		
		global maxFileJPGType
		
		--finds the ".max" substring at the end of the file name and replaces it with .jpg
		maxFileMAXType = copy maxFileName
		maxIndex = findString maxFileMAXType ".max"
		if (maxIndex == 'undefined') then maxFileJPGType = "*.jpg"
		else
		(
			maxIndex -= 1
			global maxFileJPGType = substring maxFileMAXType 1 maxIndex + ".jpg"
		)
		
		--Manages frame settings: background color and frame width/height
		rollout frameSettingsRollout "Frame Settings" width:301 height:74
		(
			--Background Color
			colorPicker backgroundColorPicker "Background:" pos:[13,10] width:110 height:44 color:backgroundColorTemp
			on backgroundColorPicker changed newColor do backgroundColorTemp = newColor
			
			--Frame Width
			spinner frameWidth "Width:" pos:[204,11] width:87 height:16 range:[0,10000,frameWidthTemp] type:#integer
			on frameWidth changed val do frameWidthTemp = val
			
			--Frame Height
			spinner frameHeight "Height:" pos:[201,39] width:90 height:16 range:[0,10000,frameHeightTemp] type:#integer
			on frameHeight chnaged val do frameHeightTemp = val
		)
		
		rollout renderSettingsRollout "Render Settings" width:301 height:300
		(
			--Time output
			radioButtons timeOutput "Time Output:" pos:[14,11] width:124 height:62 enabled:true default:timeTypeTemp labels:#("Single Frame", "Active Time Segment", "Frames:")
			on timeOutput changed theState do
			(
				case theState of
				(
					-- Single Frame
					1: timeTypeTemp = 1
					-- Active time segment
					2: timeTypeTemp = 2
					-- Specific Frames
					3: timeTypeTemp = 4
				)
			)
			
			--Frame values (if time output is 4)
			editText frameValues "" pos:[149,57] width:140 height:19
			on frameValues changed newValues do frameValuesTemp = newValues
			
			--Save rendered files?
			checkbox saveFilesState "Save?" pos:[14,96] checked:saveStateTemp width:88 height:17
			on saveFilesState changed theState do saveStateTemp = theState
			
			--Display file name/path
			editText fileNameViewer "" pos:[10,126] width:277 height:17 text:rendOutputFileName enabled:true readOnly:true
			
			--Choose file name/path
			button filePicker "Files ..." pos:[215,97] width:72 height:19
			on filePicker pressed do
				(
					try
					(
						fileOutputTemp = getBitmapSaveFileName caption:"Render Output Path" filename: (maxFilePath + maxFileJPGType) types:"JPEG(*.jpg)|*.jpg|"
						fileNameViewer.text = fileOutputTemp
					)
					catch()
				)
				
			--Render Hidden Objects
			checkbox hiddenObjectsToggle "Render Hidden Objects" pos:[14,167] width:142 height:18 checked:renderHiddenObjectsTemp
			on hiddenObjectsToggle changed theState do renderHiddenObjectsTemp = theState
			
			--Force 2-Sided
			checkbox force2Toggle "Force 2-Sided" pos:[14,187] width:142 height:18 checked:force2SidedTemp
			on force2Toggle changed theState do force2SidedTemp = theState
			
			--Skip Rendered Frames
			checkbox skipRenderedToggle "Skip Rendered Frames" pos:[14,208] width:142 height:18 checked:skipRenderedFramesTemp
			on skipRenderedToggle changed theState do skipRenderedFramesTemp = theState
			
			--Optimize via optimizeSettings()
			checkbox optimizeToggle "Optimize Renderer?" pos:[161,167] width:108 height:18 checked:optimizeTemp
			on optimizeToggle changed theState do optimizeTemp = theState
			
			--Net Render
			checkbox netRenderToggle "Net Render" pos:[14,229] width:142 height:18 checked:netRenderTemp
			on netRenderToggle changed theState do netRenderTemp = theState
			
			--Exit (don't save anything)
			button exitButton "Exit" pos:[13,264] width:69 height:25
			on exitButton pressed do closeRolloutFloater MainDialog
			
			--Exit (Save current settings)
			button saveAndExit "Save and Exit" pos:[98,264] width:85 height:25
			on saveAndExit pressed do
			(
				backgroundColor = backgroundColorTemp
				renderWidth = frameWidthTemp
				renderHeight = frameHeightTemp
				rendTimeType = timeTypeTemp
				if rendTimeType == 4 then rendPickupFrames = frameValuesTemp
				rendSaveFile = saveStateTemp
				rendOutputFileName = fileOutputTemp
				rendHidden = renderHiddenObjectsTemp
				rendForce2Side = force2SidedTemp
				skipRenderedFrames = skipRenderedFramesTemp
				if optimizeTemp then optimizeSettings()
				rendUseNet = netRenderTemp
				
				closeRolloutFloater MainDialog
			)
			
			--Save and Render
			button saveAndRender "Save and Render" pos:[198,264] width:93 height:25
			on saveAndRender pressed do
			(
				try
				(
					rendSaveFile = saveStateTemp
					if rendSaveFile then rendOutputFileName = fileOutputTemp
					backgroundColor = backgroundColorTemp
					renderWidth = frameWidthTemp
					renderHeight = frameHeightTemp
					rendTimeType = timeTypeTemp
					rendPickupFrames = frameValuesTemp
					rendHidden = renderHiddenObjectsTemp
					rendForce2Side = force2SidedTemp
					skipRenderedFrames = skipRenderedFramesTemp
					if optimizeTemp then optimizeSettings()
					rendUseNet = netRenderTemp
					
					if viewport.getCamera() == undefined then
					(
						perspectiveWarning()
					)					
					else
					(
						max quick render
					)
					
					closeRolloutFloater MainDialog
				)
				catch
				(
					--dialog in case of an invalid file name
					global FileErrorDialog = newRolloutFloater "Error" 205 90
					rollout fileErrorRollout "Error" width:205 height:77
					(
						label fileWarning "Invalid file name. Please try again." pos:[19,6] width:166 height:19
						
						button okButton "OK" pos:[60,36] width:84 height:26
						on okButton pressed do closeRolloutFloater FileErrorDialog
					)
					
					addrollout fileErrorRollout FileErrorDialog
				)
			)
		)
		
		addrollout frameSettingsRollout MainDialog
		addrollout renderSettingsRollout MainDialog
	)

	-- Execute the functions defined previously
	loadSettings()
	openMainDialog()
)