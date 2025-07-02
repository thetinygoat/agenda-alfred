#!/usr/bin/env python3

import subprocess
import json
from datetime import datetime
import os
import sys


def get_event_details(date, calendar):
    """Runs a CLI command to fetch event details and formats them as JSON."""
    try:
        workflow_dir = os.path.dirname(os.path.abspath(__file__))
        cli_path = os.path.join(workflow_dir, "agenda")
        cli_command = [cli_path, "--date", date]

        if calendar:
            cli_command.append("--calendar")
            cli_command.append(calendar)

        result = subprocess.run(
            cli_command, capture_output=True, text=True, check=True
        )

        # Parse the CLI output assuming it's JSON
        cli_output = json.loads(result.stdout)
        events = []
        for item in cli_output:
            event = {
                "title": item.get("title"),
                "startDate": item.get("startDate"),
                "endDate": item.get("endDate"),
                "location": item.get("location"),
                "notes": item.get("notes"),
                "meetingURL": item.get("meetingURL"),
            }
            events.append(event)

        def format_date_range(start, end):
            """Formats the date range to include relative time."""
            if not start or not end:
                return "Time not available"

            # Parse UTC timestamps and convert to local time
            start_dt = datetime.fromisoformat(start.replace("Z", "+00:00")).astimezone()
            end_dt = datetime.fromisoformat(end.replace("Z", "+00:00")).astimezone()
            now = datetime.now().astimezone()

            # Calculate relative time using total_seconds for accurate calculation
            time_diff = start_dt - now
            total_minutes = int(time_diff.total_seconds() / 60)

            if total_minutes < 0:
                abs_minutes = abs(total_minutes)
                if abs_minutes >= 60:
                    hours = abs_minutes // 60
                    relative_time = f"{hours} hour{'s' if hours != 1 else ''} ago"
                else:
                    relative_time = f"{abs_minutes} mins ago"
            else:
                if total_minutes >= 60:
                    hours = total_minutes // 60
                    relative_time = f"in {hours} hour{'s' if hours != 1 else ''}"
                else:
                    relative_time = f"in {total_minutes} minutes"

            # Format date range
            formatted_start = start_dt.strftime("%I:%M %p").lstrip("0")
            formatted_end = end_dt.strftime("%I:%M %p").lstrip("0")
            return f"Today {formatted_start} - {formatted_end}, {relative_time}"

        # Convert to Alfred Script Filter format
        alfred_items = []
        for event in events:
            subtitle = format_date_range(event["startDate"], event["endDate"])
            alfred_item = {
                "title": event["title"],
                "subtitle": subtitle,
                "arg": event["meetingURL"],
                "text": {"copy": json.dumps(event), "largetype": event["title"]},
            }
            alfred_items.append(alfred_item)
        
        if not alfred_items:
            alfred_items = [{
                "title": "No events",
                "subtitle": "Please try another query",
                "valid": False,
            }]

        return json.dumps({"items": alfred_items}, indent=4)

    except Exception as e:
        alfred_items = [{
            "title": "No events",
            "subtitle": "Please try another query",
            "valid": False,
        }]
        return json.dumps({"items": alfred_items}, indent=4)


if __name__ == "__main__":
    date = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else "today"
    calendar = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] else None
    event_json = get_event_details(date, calendar)
    print(event_json)
