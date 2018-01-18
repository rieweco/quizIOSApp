import Foundation

extension String {
	func removingWhiteSpaces() -> String {
		return self.replacingOccurrences(of: " ", with: "")
	}
	
	func trimWhiteSpace() -> String {
		return self.trimmingCharacters(in: CharacterSet(charactersIn: " "))
	}
}
