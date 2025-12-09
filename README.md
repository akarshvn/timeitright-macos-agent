# TimeItRight macOS Agent

The **TimeItRight macOS Agent** is a lightweight background script that tracks the currently focused application and active browser tab URL on macOS.  
This is an early **Bash prototype** — the final production implementation will be rewritten in **Python** for improved reliability and maintainability.

---

## Features (Current Bash Prototype)

- Polls the system every second to detect:
  - Frontmost (focused) application  
  - Browser active tab URL (Arc for now)  
  - Whether the browser is running  
- Prints activity changes with timestamps  
- Handles basic error cases and edge scenarios

This Bash agent is designed for experimentation, to shape the APIs and logic that will later be implemented in Python.

---

## Known Limitations / Race Condition Notice

There is a **known short delay (usually ~4–5 seconds)** that may occur **right after the browser is closed**, caused by a macOS-level race condition:

- The script detects the browser as “running” using `pgrep`
- Immediately after that, the browser process terminates
- Then the script attempts to use AppleScript (`osascript`) or System Events to query minimized state or active tab
- macOS may take several seconds to time out these accessibility calls  
  → this causes a pause before the next log message appears

This behavior is temporary and should be eliminated in the Python rewrite.

---

## Repository Structure

```
timeitright-macos-agent/
│
├── agent.sh            # Main Bash agent (prototype)
├── README.md           # Documentation (this file)
└── .gitignore          # Git ignore file for macOS environment
```

---

## Running the Agent (Prototype)

```bash
chmod +x agent.sh
./agent.sh
```

Right now, you may need to grant **Accessibility permissions** to your terminal application because this script uses System Events–based checks.

---

## Contact / Contribution

This is an early work-in-progress. Contributions, suggestions, and architectural feedback are welcome.
