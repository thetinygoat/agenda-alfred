# Agenda

A lightweight Alfred workflow to display calendar events for a given date and calendar.

## Trigger

**Keyword:** configurable (default: `agenda`)

## Variables (Optional)

### Date

- **Format:** `YYYY-MM-DD`, `today`, `tomorrow`, etc.
- **Default:** `today`

### Calendar

- **Name or identifier** of a specific calendar (e.g., `Work`, `Personal`)
- **Default:** all calendars

> **Note:** The first argument is always treated as the date. The second argument is for the calendar. Both are optional. If you omit the date, it defaults to `today`. If you omit the calendar, it shows events from all calendars.

## Usage Examples

### Show today’s events from all calendars
```
agenda
```

### Show events on a specific date
```
agenda 2025-07-02
```

### Show today’s events for a specific calendar
```
agenda today Work
```

### Show events on a specific date and calendar
```
agenda 2025-07-02 Personal
```

## Features

- Pressing <kbd>Enter</kbd> on an event will open its associated meeting URL in your default browser.

## Installation

1. Import the workflow (`.alfredworkflow`).
2. Open Alfred Preferences → Workflows → Agenda.
3. Adjust the Keyword if you want a custom trigger.
4. (Optional) In the Script Filter’s Variables panel, set default date or calendar values.