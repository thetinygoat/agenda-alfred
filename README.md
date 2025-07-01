# Agenda Alfred

A Python script that integrates with the `agenda` CLI tool to display calendar events in Alfred Script Filter format.

## What it does

This script:
- Runs the `agenda --date today` command to fetch today's calendar events
- Parses the JSON output from the agenda CLI tool
- Formats the events for Alfred workflows with proper relative time display
- Shows events with titles, time ranges, and relative timing (e.g., "in 2 hours" or "30 mins ago")

## Output Format

Each event is displayed with:
- **Title**: Event name
- **Subtitle**: Formatted as "Today 9:15 AM - 10:30 AM, in 2 hours"
- **Arg**: Complete event data in JSON format for further processing

## Event Data Structure

The script extracts and formats the following event details:
- `title` - Event title
- `startDate` - Start time in ISO 8601 format
- `endDate` - End time in ISO 8601 format  
- `location` - Event location
- `notes` - Event notes
- `meetingURL` - Extracted meeting URL (if found)

## Requirements

- Python 3.6+
- `agenda` CLI tool installed and configured
- Events should be in ISO 8601 format with UTC timezone (ending with 'Z')

## Usage

Make the script executable:
```bash
chmod +x main.py
```

Run directly:
```bash
./main.py
```

Or use in an Alfred workflow as a Script Filter.

## Time Display Features

- Converts UTC timestamps to local time
- Shows relative time for events (e.g., "in 30 minutes", "2 hours ago")
- Automatically converts minutes to hours when >= 60 minutes
- Handles timezone-aware datetime calculations
- Gracefully handles missing or null date fields