import subprocess
import time
import datetime

POLL_SECONDS = 2
supportedBrowsers = ("Arc", "Google Chrome", "Brave Browser", "Microsoft Edge", "Safari")

def runAppleScript(script: str, timeout: float = 2.0,) -> str | None:
    try:
            process = subprocess.run(
                  ["osascript", "-e", script],
                  capture_output=True,
                  text=True,
                  timeout=timeout,
                  check=False
            )
            out = process.stdout.strip()
            return out
    except subprocess.TimeoutExpired:
          return None
        
def getFrontmostApp() -> str | None:
      script = 'tell application "System Events" to get name of first application process whose frontmost is true'

      return runAppleScript(script)

def getActiveTabURL(browser: str) -> str | None:
      if browser in ("Arc", "Google Chrome", "Brave Browser", "Microsoft Edge"):
            script = f'''
            tell application "{browser}"
                  try
                        get URL of active tab of front window
                  on error
                        return ""
                  end try
            end tell
            '''
            return runAppleScript(script)
      elif browser == "Safari":
            script = '''
            tell application "Safari"
                  try
                        return URL of front document
                  on error
                        return ""
                  end try
            end tell            
            '''
            return runAppleScript(script)
      else:
            return None      

def main():
      print("Starting...\nClick Control + C to Stop.\n")

      lastFrontmostApp = ""
      lastActiveTabURL = ""

      while True:           
            timeStamp = datetime.datetime.now().replace(microsecond=0)
            frontmostApp = getFrontmostApp().strip()
            activeTabURL = getActiveTabURL(frontmostApp)

            if frontmostApp is None:
                  print("Frontmost App: (unknown error or applescript timed out)")
                  time.sleep(POLL_SECONDS)
                  
            if frontmostApp in supportedBrowsers and frontmostApp != lastFrontmostApp or lastActiveTabURL != activeTabURL:
                  lastFrontmostApp = frontmostApp
                  lastActiveTabURL = activeTabURL
                  
                  print("---"*20)
                  print(f"|{timeStamp} | Frontmost: {frontmostApp} | URL: {activeTabURL} |")
                  print("---"*20)

            elif frontmostApp != lastFrontmostApp:
                  lastFrontmostApp = frontmostApp
                  print("---"*20)
                  print(f"|{timeStamp} | Frontmost: {frontmostApp} | URL: (none) |")
                  print("---"*20)

            time.sleep(POLL_SECONDS)


if __name__ == "__main__":
    main()