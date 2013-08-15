rollout renderSettingsRollout "Render Settings" width:301 height:300
(
	radioButtons timeOutput "Time Output:" pos:[14,11] width:124 height:62 enabled:true labels:#("Single Frame", "Active Time Segment", "Frames:")
	editText frameValues "" pos:[149,57] width:140 height:19
	checkbox chk1 "Save?" pos:[14,96] width:88 height:17
	button filePicker "Files ..." pos:[215,97] width:72 height:19
	editText fileNameViewer "" pos:[10,126] width:277 height:17 enabled:true
	checkbox hiddenObjectsToggle "Render Hidden Objects" pos:[14,167] width:142 height:18 checked:true
	checkbox force2Toggle "Force 2-Sided" pos:[14,187] width:142 height:18 checked:true
	checkbox skipRenderedToggle "Skip Rendered Frames" pos:[14,208] width:142 height:18 checked:true
	checkbox netRenderToggle "Net Render" pos:[14,229] width:142 height:18 checked:true
	button saveAndRender "Save and Render" pos:[198,264] width:93 height:25
	button exit "Exit" pos:[13,264] width:69 height:25
	button saveAndExit "Save and Exit" pos:[98,264] width:85 height:25
)