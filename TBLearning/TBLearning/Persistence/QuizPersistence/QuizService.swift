import Foundation

//: Decodable Extension
enum DateError: String, Error {
    case invalidDate
}
extension Decodable {
    static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DateError.invalidDate
        })
        return try decoder.decode(Self.self, from: data)
    }
}

//: Encodable Extension

extension Encodable {
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
}


struct GetQuizWithToken: Codable{
    let sessionId: String
    let quiz: ServiceQuiz
}

struct ServiceCourse: Codable{
    let courseId: String
    let extendedID: String
    let name: String
    let semester: String
    let instructor: String
    let quiz: ServiceQuiz
    
    enum CodingKeys: String, CodingKey{
        case courseId
        case extendedID
        case name
        case semester
        case instructor
        case quiz = "quiz"
    }
}


struct ServiceQuiz: Codable{
    let id: String
    let desc: String
    let text: String
    let availableDate: Date
    let expiryDate: Date
    let timed: Bool
    let timedLength: Int16
    let questions: [ServiceQuestion]?
    
    //if you do change one key, you have to do all even if you don't change it.
    enum CodingKeys: String, CodingKey{
        case id = "_id"
        case desc = "description"
        case text
        case availableDate, expiryDate
        case timed
        case timedLength
        case questions
    }
}

struct ServiceQuestion: Codable{
    let id: String
    let title: String
    let text: String
    let pointsPossible: Int16
    let availableAnswers: [ServiceAnswers]?
    
    enum CodingKeys: String, CodingKey{
        case id = "_id"
        case title, text
        case pointsPossible
        case availableAnswers
    }
}

struct ServiceAnswers: Codable{
    let value: String
    let text: String
    let sortOrder: Int16
    let imageUri: String?
}

//for post body payload

//extension QuizPayLoad {
//    func encode(to encoder: Encoder) throws{
//        var container = enc
//    }
//}


struct QuizPayLoad: Codable{
    let quizId: String
    let questions: [QuestionPayLoad]?
    
    enum CodingKeys: String, CodingKey{
        case quizId = "id"
        case questions
    }
}

struct QuestionPayLoad: Codable{
    var quesId: String
    var submittedAnswers: [SubmittedAnswers]?
    
    enum CodingKeys: String, CodingKey{
        case quesId = "id"
        case submittedAnswers
    }
}



struct SubmittedAnswers: Codable {
    let value: String
    var allocatedPoints: Int16 = 0
    
    
    enum CodingKeys: String, CodingKey{
        case value
        case allocatedPoints
    }
}

//for post response

struct QuizResult: Codable {
//    enum submitType: String{ case individual, group}??????????????????????/
    let version: Int16
    let submitType: String
    let quizSessionId: String
    let userId: String
    let courseId: String
    let quizId: String
    let answers: [AnswerResult]
    let submitTime: String

    enum CodingKeys: String, CodingKey{
        case version = "__v"
        case submitType
        case quizSessionId = "sessionId"
        case userId = "user"
        case courseId = "course"
        case quizId
        case answers
        case submitTime
    }
}


//for individual post response result,
// for groupQuiz post response result (additional, pointsRemaining)
struct AnswerResult: Codable {
    let question: String
    let submittedAnswers: [SubmitAnswer]
    let pointsRemaining: Int16?
    let numberOfAtempts: Int16?
    let answeredCorrectly: Bool?

}



struct SubmitAnswer: Codable{
    let value: String?
    let points: Int16
    let isCorrect: Bool
}


