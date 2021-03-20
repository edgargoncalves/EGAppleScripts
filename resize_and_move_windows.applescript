(* This AppleScript will resize the current application window and cycle its position between maximized, halves or thirds of the whole screen, vertically or horizontally *)

on abs(x)
	if x > 0 then return x
	return -x
end abs

on closest(x, direction)
	set y to x div 1
	
	if direction < 0 then
		if x > 0 and x mod 1 is not 0 then
			set y to y + 1
		end if
		if y < 1 then set y to 1
	end if
	
	return y
end closest

global appXi, appXf, appYi, appYf, posX, posY

on resize_and_move(dock_width, screenWidth, divisions, directionX, directionY)
	if directionX ­ 0 then
		set posX to ((appXi - dock_width) / ((screenWidth - dock_width) / divisions) as integer) + directionX
		-- Ensure it doesn't go outside the screen:
		if appXi < dock_width or posX < 0 then set posX to 0
		if posX ³ divisions then set posX to divisions - 1
		-- Recalculate horizontal bounds:
		set appXi to ((screenWidth - dock_width) / divisions) * posX + dock_width as integer
		set appXf to appXi + ((screenWidth - dock_width) / divisions) as integer
	end if
	if directionY ­ 0 then
		set posY to ((appYi - dock_width) / ((screenWidth - dock_width) / divisions) as integer) + directionY
		log {"debug: ", posY, "Yi", appYi, "unusedTop", dock_width, "screenWidth", screenWidth, "divisions", divisions}
		-- Ensure it doesn't go outside the screen:
		if appYi < dock_width then set posY to 0
		if posY ³ divisions then set posY to divisions - 1
		-- Recalculate horizontal bounds:
		set appYi to ((screenWidth - dock_width) / divisions) * posY + dock_width as integer
		set appYf to appYi + ((screenWidth - dock_width) / divisions) as integer
	end if
end resize_and_move

on run argv
	set directionX to item 1 of argv as integer
	set directionY to item 2 of argv as integer
	
	set the_application to (path to frontmost application as Unicode text)
	
	tell application "Finder"
		set screenResolution to bounds of window of desktop
	end tell
	
	tell application the_application
		set appInitialBounds to bounds of the first window
	end tell
	
	tell application "System Events"
		set dock_hidden to the autohide of the dock preferences
		set dock_position to the screen edge of the dock preferences
	end tell
	set unusable_left to 0
	set unusable_right to 0
	set unusable_bottom to 0
	set unusable_top to 25
	
	if dock_hidden then
		set dock_width to 0
		set dock_height to 0
	else
		tell application "System Events" to tell process "Dock"
			set dock_dimensions to size in list 1
			set dock_width to (item 1 of dock_dimensions) + 5
			set dock_height to item 2 of dock_dimensions
		end tell
	end if
	
	if dock_hidden is not true then
		tell application "System Events" to tell process "Dock"
			set dock_dimensions to size in list 1
			if dock_position = left then set unusable_left to (item 1 of dock_dimensions) + 5
			if dock_position = right then set unusable_right to (item 1 of dock_dimensions) + 5
			if dock_position = bottom then set unusable_bottom to (item 2 of dock_dimensions) + 5
		end tell
	end if
	
	
	set screenWidth to item 3 of screenResolution
	set screenHeight to item 4 of screenResolution
	set appXi to item 1 of appInitialBounds
	set appYi to item 2 of appInitialBounds
	set appXf to item 3 of appInitialBounds
	set appYf to item 4 of appInitialBounds
	set i_appXi to appXi
	set i_appXf to appXf
	set i_appYi to appYi
	set i_appYf to appYf
	set posX to 0
	
	log {"Unusable bits (left, right, bottom): ", unusable_left, unusable_right, unusable_bottom}
	log {"Screen width, height: ", screenWidth, screenHeight}
	log {"Initial window Xi-f Yi-f: ", appXi, appXf, appYi, appYf}
	
	if directionX ­ 0 then
		set currently_at_one_third to abs(3 * (i_appXf - i_appXi) + unusable_left + unusable_right - screenWidth) < 2
		set currently_at_one_half to abs(2 * (i_appXf - i_appXi) + unusable_left + unusable_right - screenWidth) < 2
		set currently_maximized to i_appXi - unusable_left = 0 and i_appXf - unusable_right = screenWidth
		set currently_on_same_edge to ((directionX > 0 and abs(screenWidth - i_appXf - unusable_right) < 2) or (directionX < 0 and i_appXi - unusable_left = 0))
		log {"Horizontal: max, 1/2, 1/3, edge: ", currently_maximized, currently_at_one_half, currently_at_one_third, currently_on_same_edge}
		set divisions to 3
		if currently_maximized then set divisions to 2
		if currently_at_one_half and currently_on_same_edge then set divisions to 1
		if currently_at_one_third and currently_on_same_edge then set divisions to 2
		
		resize_and_move(unusable_left, (screenWidth - unusable_right), divisions, directionX, 0)
	end if
	
	if directionY ­ 0 then
		
		set currently_at_one_third to abs(3 * (i_appYf - i_appYi) + unusable_top + unusable_bottom - screenHeight) < 2
		set currently_at_one_half to abs(2 * (i_appYf - i_appYi) + unusable_top + unusable_bottom - screenHeight) < 2
		set currently_maximized to i_appYi - unusable_top = 0 and i_appYf - unusable_bottom = screenHeight
		set currently_on_same_edge to ((directionY > 0 and i_appYf + unusable_bottom = screenHeight) or (directionY < 0 and i_appYi - unusable_top = 0))
		log {"Vertical: max, 1/2, 1/3, edge: ", currently_maximized, currently_at_one_half, currently_at_one_third, currently_on_same_edge}
		set divisions to 3
		if currently_maximized then set divisions to 2
		if currently_at_one_half and currently_on_same_edge then set divisions to 1
		if currently_at_one_third and currently_on_same_edge then set divisions to 2
		
		resize_and_move(unusable_top, (screenHeight - unusable_bottom), divisions, 0, directionY)
	end if
	
	log {"Final window bounds: ", appXi, appXf, appYi, appYf}
	
	tell application the_application
		activate
		reopen
		set the bounds of the first window to {appXi, appYi, appXf, appYf}
	end tell
	
end run
