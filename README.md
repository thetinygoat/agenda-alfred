# Calendar Events Alfred Workflow

A fast and lightweight Alfred workflow to view your upcoming calendar events directly from Alfred.

## Features
- View upcoming calendar events with a simple command
- Quickly join meetings by selecting an event with a URL
- Specify how many days of events to display
- Built with Swift using Apple's EventKit for optimal performance

## Requirements
- Alfred with Powerpack
- The `ical2json` binary (available in the GitHub releases section or can be built from source)

## Usage

Basic command structure:
```
sch [number of days]
```

### Examples

- `sch` - Show events for the next 1 day (default)
- `sch 3` - Show events for the next 3 days
- `sch 7` - Show events for the next week

Press Enter on any event with a meeting URL to open it in your default browser.

## Installation

1. Download the workflow file
2. Double-click to install in Alfred
3. Download the `ical2json` binary from the GitHub releases section or build it from source
4. install jq from homebrew `brew install jq`
4. First run may require calendar access permissions

## Technical Details

This workflow is extremely fast due to being written in Swift and leveraging Apple's native EventKit framework for calendar access.

## Links
- [thetinygoat](https://x.com/thetinygoat)