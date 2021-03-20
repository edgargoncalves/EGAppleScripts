tell application "Finder"
	set file_path to (path to me)
	set scriptFile to (container of (path to me) as string) & "resize_and_move_windows.scpt"
end tell
run script file scriptFile with parameters {1, 0}