--Optimize those RAM settings! Designed to help prevent exception errors on Backburner.

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
		Credits for parts of the code block above:

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

optimizeSettings()