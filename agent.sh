#!/bin/bash

BROWSER_NAME="Arc" #Browser Name
POLL=1 #Time duration between polls

last_frontapp=""
last_activeTabURL=""
last_change_ts=0

is_running() {
	local name="$1"

	if pgrep -x "$name" >/dev/null; then
		echo "yes"
	else
		echo "no"
	fi
}

while true; do

	now_ts=$(date "+%Y-%m-%d %H:%M:%S")

	frontapp="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')"

	#<<<<<before running active tab url, check if window is opened first here>>>>
	#<<<<<if window is not opened yet, do not run activeTabURL and skip it wholly>>>>>

	browser_running=$(is_running "$BROWSER_NAME")


	if [[ "$browser_running" == "yes" ]]; then
		activeTabURL="$(osascript -e "tell application \"$BROWSER_NAME\" to try 
				get URL of active tab of front window
			on error
				return \"\"
			end try" 2>/dev/null || echo "" )"

		isBrowserMinimized="$(osascript -e "
		tell application \"System Events\"
			tell process \"$BROWSER_NAME\"
				if exists window 1 then
					return value of attribute \"AXMinimized\" of window 1
				end if
			end tell
		end tell
		")"

		# isBrowserMinimized="$(osascript -e "
		# tell application "System Events"
		#     tell process \"$BROWSER_NAME\"
		#         if exists window 1 then
		#             return value of attribute "AXMinimized" of window 1
		#         end if
		#     end tell
		# end tell")"
		# echo "isBrowserMinimized: " "$isBrowserMinimized"
	fi
	

	# echo "Frontmost App: " "$frontapp"
	# echo "ActiveURL: " "$activeTabURL"

	#have to trim whitespaces
	frontapp="${frontapp//$'\r'/}"
	activeTabURL="${activeTabURL//$'\r'/}"

	#echo "after trimming: $activeTabURL"
	#echo "after trimming: $frontapp"


	if [[ "$frontapp" != "$last_frontapp" || "$activeTabURL" != "$last_activeTabURL" ]]; then
		if [[ "$frontapp" == "$BROWSER_NAME" && -n "$activeTabURL" ]]; then
			echo -e "----------------------------------------------------------------------"
			echo -e "$now_ts | focus: $frontapp | url: $activeTabURL"
			echo -e "----------------------------------------------------------------------"
		else
			echo -e "----------------------------------------------------------------------"
			echo -e "$now_ts | focus: $frontapp | url: (none)"
			echo -e "----------------------------------------------------------------------"
		fi

		last_frontapp="$frontapp";
		last_activeTabURL="$activeTabURL"
		last_change_ts="$last_change_ts"
	fi

	#for debugging
	#echo "Frontmost App: " "$frontapp"
	#echo "ActiveURL: " "$activeTabURL"

	#Previously used code - should be removed once not needed
	# if [ "$frontapp" == "$BROWSER_NAME" ]; then
	# 	# echo -e "-------------------------------------"
	# 	# echo -e "$BROWSER_NAME is in focus."
	# 	# echo -e "Current URL: $activeTabURL"
	# 	# echo -e "------------------	-------------------"

	# 	echo -e "----------------------------------------------------------------------"
	# 	echo -e "$(date "+%Y-%m-%d %H:%M:%S") | focus: $frontapp | url: $activeTabURL"
	# 	echo -e "----------------------------------------------------------------------"
	# else
	# 	echo -e "Wrong App in Focus ($frontapp)\n"
	# fi

	sleep $POLL
done