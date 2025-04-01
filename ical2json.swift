import EventKit
import Foundation

func formatEventDetails(event: EKEvent) -> String {
    let now = Date()
    let calendar = Calendar.current
    let startDate = event.startDate!
    let endDate = event.endDate!

    // Formatters
    let timeFormatter = DateFormatter()
    timeFormatter.timeStyle = .short
    timeFormatter.dateStyle = .none

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none

    let relativeFormatter = RelativeDateTimeFormatter()
    relativeFormatter.unitsStyle = .short

    let durationFormatter = DateComponentsFormatter()
    durationFormatter.allowedUnits = [.hour, .minute]
    durationFormatter.unitsStyle = .abbreviated
    durationFormatter.maximumUnitCount = 2

    // Start/end time string
    var timeString = ""
    let sameDay = calendar.isDate(startDate, inSameDayAs: endDate)

    if event.isAllDay {
        if calendar.isDateInToday(startDate) {
            timeString = "All day today"
        } else if calendar.isDateInTomorrow(startDate) {
            timeString = "All day tomorrow"
        } else {
            timeString = "All day \(dateFormatter.string(from: startDate))"
        }
    } else if sameDay {
        let dayString: String
        if calendar.isDateInToday(startDate) {
            dayString = "Today"
        } else if calendar.isDateInTomorrow(startDate) {
            dayString = "Tomorrow"
        } else {
            dayString = dateFormatter.string(from: startDate)
        }
        timeString =
            "\(dayString), \(timeFormatter.string(from: startDate)) - \(timeFormatter.string(from: endDate))"
    } else {
        timeString =
            "\(dateFormatter.string(from: startDate)) \(timeFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate)) \(timeFormatter.string(from: endDate))"
    }

    // Time until event
    let timeUntil: String
    if startDate < now {
        timeUntil = "\(relativeFormatter.localizedString(for: startDate, relativeTo: now))"
    } else {
        timeUntil = "\(relativeFormatter.localizedString(for: startDate, relativeTo: now))"
    }

    // Combine information - skip duration for all-day events
    if event.isAllDay {
        return "\(timeString) • \(timeUntil)"
    } else {
        let duration = durationFormatter.string(from: startDate, to: endDate) ?? ""
        return "\(timeString) • \(duration) • \(timeUntil)"
    }
}

struct CalendarEvent: Codable {
    let uid: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let location: String?
    let notes: String?
    let arg: URL?
    let calendar: String
    let subtitle: String

    // Create from EKEvent
    init(from event: EKEvent) {
        self.uid = event.eventIdentifier ?? UUID().uuidString
        self.title = event.title ?? "Untitled"
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.isAllDay = event.isAllDay
        self.location = event.location
        self.notes = event.notes
        self.arg = event.meetingURL
        self.calendar = event.calendar.title
        self.subtitle = formatEventDetails(event: event)
    }
}

struct AlfredItems: Codable {
    let items: [CalendarEvent]
    init(from events: [CalendarEvent]) {
        self.items = events
    }
}

extension Array where Element == EKEvent {
    func toJSON() -> String? {
        // Convert EKEvents to our Codable struct
        let events = self.map { CalendarEvent(from: $0) }
        let items = AlfredItems(from: events)

        // Create JSON encoder with formatting
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        // Encode to JSON data then to string
        guard let jsonData = try? encoder.encode(items) else {
            return nil
        }

        return String(data: jsonData, encoding: .utf8)
    }
}

enum MeetingPlatform: String, CaseIterable {
    case zoom = "zoom"
    case googleMeet = "meet.google"
    case microsoftTeams = "teams.microsoft"
    case webex = "webex"
    case jitsi = "meet.jit.si"
    case gotomeeting = "gotomeeting"
    case skype = "skype"
    case bluejeans = "bluejeans"
    case whereby = "whereby"
    case chime = "chime.aws"
    
    var patterns: [String] {
        switch self {
        case .zoom:
            return [
                "https?://[a-zA-Z0-9.-]+\\.zoom\\.us/[a-zA-Z0-9/?.=&-]+",
                "zoom\\.us/[a-zA-Z0-9/?.=&-]+"
            ]
        case .googleMeet:
            return [
                "https?://meet\\.google\\.com/[a-zA-Z0-9-]+",
                "meet\\.google\\.com/[a-zA-Z0-9-]+"
            ]
        case .microsoftTeams:
            return [
                "https?://teams\\.microsoft\\.com/l/meetup-join/[a-zA-Z0-9%_.~=-]+",
                "teams\\.microsoft\\.com/l/meetup-join/[a-zA-Z0-9%_.~=-]+"
            ]
        case .webex:
            return [
                "https?://[a-zA-Z0-9.-]+\\.webex\\.com/[a-zA-Z0-9/?.=&%-]+",
                "webex\\.com/[a-zA-Z0-9/?.=&%-]+"
            ]
        case .jitsi:
            return [
                "https?://meet\\.jit\\.si/[a-zA-Z0-9-]+",
                "meet\\.jit\\.si/[a-zA-Z0-9-]+"
            ]
        case .gotomeeting:
            return [
                "https?://[a-zA-Z0-9.-]*gotomeeting\\.com/[a-zA-Z0-9/?.=&-]+",
                "gotomeeting\\.com/[a-zA-Z0-9/?.=&-]+"
            ]
        case .skype:
            return [
                "https?://join\\.skype\\.com/[a-zA-Z0-9]+",
                "join\\.skype\\.com/[a-zA-Z0-9]+"
            ]
        case .bluejeans:
            return [
                "https?://[a-zA-Z0-9.-]*bluejeans\\.com/[a-zA-Z0-9/?.=&-]+",
                "bluejeans\\.com/[a-zA-Z0-9/?.=&-]+"
            ]
        case .whereby:
            return [
                "https?://whereby\\.com/[a-zA-Z0-9-]+",
                "whereby\\.com/[a-zA-Z0-9-]+"
            ]
        case .chime:
            return [
                "https?://[a-zA-Z0-9.-]*\\.chime\\.aws/[a-zA-Z0-9/?.=&-]+",
                "chime\\.aws/[a-zA-Z0-9/?.=&-]+"
            ]
        }
    }
}

class MeetingURLExtractor {
    
    /// Extract meeting URL from an EKEvent
    /// - Parameter event: The calendar event
    /// - Returns: The meeting URL if found, otherwise nil
    static func extractMeetingURL(from event: EKEvent) -> URL? {
        // First check if the event already has a URL
        if let existingURL = event.url, isMeetingURL(existingURL.absoluteString) {
            return existingURL
        }
        
        // If there are no notes, we can't extract a URL
        guard let notes = event.notes else {
            return nil
        }
        
        return findMeetingURLInText(notes)
    }
    
    /// Find a meeting URL in a text
    /// - Parameter text: The text to search in
    /// - Returns: The meeting URL if found, otherwise nil
    static func findMeetingURLInText(_ text: String) -> URL? {
        // First look for full URLs
        if let url = extractFullURL(from: text) {
            return url
        }
        
        // Then try to extract partial URLs and prepend "https://"
        if let partialURL = extractPartialURL(from: text) {
            return URL(string: "https://\(partialURL)")
        }
        
        return nil
    }
    
    /// Extract a full URL from text
    /// - Parameter text: The text to search in
    /// - Returns: The URL if found, otherwise nil
    private static func extractFullURL(from text: String) -> URL? {
        for platform in MeetingPlatform.allCases {
            for pattern in platform.patterns {
                if let range = text.range(of: "https?://\(pattern)", options: .regularExpression) {
                    let urlString = String(text[range])
                    return URL(string: urlString)
                }
            }
        }
        
        // Generic URL pattern (fallback)
        let urlDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = urlDetector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        if let match = matches?.first,
           let range = Range(match.range, in: text),
           let url = URL(string: String(text[range])),
           isMeetingURL(url.absoluteString) {
            return url
        }
        
        return nil
    }
    
    /// Extract a partial URL (without protocol) from text
    /// - Parameter text: The text to search in
    /// - Returns: The partial URL if found, otherwise nil
    private static func extractPartialURL(from text: String) -> String? {
        for platform in MeetingPlatform.allCases {
            for pattern in platform.patterns.filter({ !$0.hasPrefix("https?://") }) {
                if let range = text.range(of: pattern, options: .regularExpression) {
                    return String(text[range])
                }
            }
        }
        return nil
    }
    
    /// Check if a URL is a meeting URL
    /// - Parameter urlString: The URL string to check
    /// - Returns: True if it's a meeting URL
    static func isMeetingURL(_ urlString: String) -> Bool {
        for platform in MeetingPlatform.allCases {
            if urlString.lowercased().contains(platform.rawValue) {
                return true
            }
        }
        return false
    }
}

// Extension to EKEvent for easier access
extension EKEvent {
    var meetingURL: URL? {
        return MeetingURLExtractor.extractMeetingURL(from: self)
    }
}


class CalendarManager {
    let eventStore = EKEventStore()
    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(macOS 14, *) {
            self.eventStore.requestFullAccessToEvents { granted, error in
                if let error {
                    print(error)
                    completion(false)
                    return
                }
                completion(granted)
            }
        } else {
            self.eventStore.requestAccess(to: .event) { granted, error in
                if let error {
                    print(error)
                    completion(false)
                    return
                }
                completion(granted)
            }
        }
    }

    func fetchEvents(days: Int) -> [EKEvent] {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)!
        let predicate = self.eventStore.predicateForEvents(
            withStart: startDate, end: endDate, calendars: nil)

        return self.eventStore.events(matching: predicate)
    }

}

func main() {
    let manager = CalendarManager()
    let days =
        CommandLine.arguments.count > 1 && Int(CommandLine.arguments[1]) != nil
        ? Int(CommandLine.arguments[1])! : 1
    // Create semaphore to wait for async completion
    let semaphore = DispatchSemaphore(value: 0)

    var accessGranted = false
    manager.requestAccess { granted in
        accessGranted = granted
        semaphore.signal()
    }

    // Wait for calendar access request to complete
    semaphore.wait()

    if accessGranted {
        print(manager.fetchEvents(days: days).toJSON() ?? "failed to fetch events")
    } else {
        print("access denied")
    }

}

main()
