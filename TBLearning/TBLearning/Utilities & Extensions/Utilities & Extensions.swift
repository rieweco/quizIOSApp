import Foundation

extension Date {
    func toString(format: DateFormatOption, timeZone: TimeZone = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: self)
    }
}


extension Array {
    func element(at index: Int) -> Element? {
        if index < 0 { return nil }
        if index >= self.count { return nil }
        return self[index]
    }
}

enum DateFormatOption: String {
    case dateTime = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    case yearMonthDay = "yyyy-MM-dd"
    case prettyDateTime = "yyyy-MM-dd @ h:mm:ss a"
}

extension URL {
    var baseName: String {
        return lastPathComponent.components(separatedBy: ".").dropLast().joined()
    }
}



