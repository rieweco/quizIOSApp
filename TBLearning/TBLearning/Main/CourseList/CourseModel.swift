import Foundation
struct CourseInfo: Codable{
    let courseId: String
    let extendedID: String
    let name: String
    let semester: String
    let instructor: String
    let quizInfo: QuizInfo
    
    enum CodingKeys: String, CodingKey{
        case courseId
        case extendedID
        case name
        case semester
        case instructor
        case quizInfo = "quiz"
    }
}

extension CourseInfo{
    static func createQuizInfo(dict: [String: Any]) -> CourseInfo?{
        guard
            let courseId = dict["courseId"] as? String,
            let extendedID = dict["extendedID"] as? String,
            let name = dict["name"] as? String,
            let semester = dict["semester"] as? String,
            let instructor = dict["instructor"] as? String,
            let quiz = dict["quiz"] as? QuizInfo
            else {
                return nil
        }
        
        return CourseInfo(courseId: courseId, extendedID: extendedID, name: name, semester: semester, instructor: instructor, quizInfo: quiz)
    }
}


struct QuizInfo: Codable{
    let _id: String
    let description: String
    let text: String
    let availableDate: String
    let expiryDate: String
    let timed: Bool
    let timedLength: Int16
    let numberOfQuestions: Int16
    
    //enforce to having enum CodingKeys even if no need to rename the Codingkey,
    //  Otherwise, you get not conform to encodable and decodable error
    enum CodingKeys: String, CodingKey{
        case _id
        case description
        case text
        case availableDate
        case expiryDate
        case timed
        case timedLength
        case numberOfQuestions
    }
}

extension QuizInfo {
    static func createQuizFrom(dict: [String:Any]) -> QuizInfo? {
        guard
            let id = dict["_id"] as? String,
            let description = dict["description"] as? String,
            let text = dict["text"] as? String,
            let availableDate = dict["availableDate"] as? String,
            let expiryDate = dict["expiryDate"] as? String,
            let timed = dict["timed"] as? Bool,
            let timedLength = dict["timedLength"] as? Int16,
            let numberOfQuestions = dict["numberOfQuestions"] as? Int16
            else {
                return nil
        }
        
        return QuizInfo(_id: id, description: description, text: text, availableDate: availableDate, expiryDate: expiryDate, timed: timed, timedLength: timedLength, numberOfQuestions: numberOfQuestions)
    }
}


