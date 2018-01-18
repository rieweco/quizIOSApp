import Foundation

enum UserStatus : String{
    case inIndividualQuiz = "inIndividualQuiz",
        inWaitingRoom = "inWaitingRoom",
        inGroupQuiz = "inGroupQuiz",
        complete = "complete"
}


struct UserInfo: Codable{
    var userId: String
    var courseId: String?
    var token: String?
    var isLeader: Bool?
    var quizId: String?
    var quizStartTime: Date?
    var quizTimed: Bool?
    var quizTimeLength: Int16?
    var sessionId: String?
    var status: String?
    var groupId: String?
    
    
    init(userId: String, courseId: String? = nil, token: String? = nil, isLeader: Bool? = nil,
         quizId: String? = nil, quizStartTime: Date? = nil, quizTimed: Bool? = nil,
         quizTimeLength: Int16? = nil, sessionId: String? = nil, status: String? = nil, groupId: String? = nil) {
        self.userId = userId
        self.courseId = courseId
        self.token = token
        self.isLeader = isLeader
        self.quizId = quizId
        self.quizStartTime = quizStartTime
        self.quizTimed = quizTimed
        self.quizTimeLength = quizTimeLength
        self.sessionId = sessionId
        self.status = status
        self.groupId = groupId
    }
    
    mutating func populate(from user: User) throws{
        userId = user.userId!
        courseId = user.courseId
        token = user.token
        isLeader = user.isLeader
        quizId = user.quizId
        quizStartTime = user.quizStartTime
        quizTimed = user.quizTimed
        quizTimeLength = user.quizTimedLength
        sessionId = user.sessionId
        status = user.status
        groupId = user.groupId
    }
    
}


