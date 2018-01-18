import Foundation

//enum NetworkCallResponseStatus{
//    case success, fail
//}

class ServiceClient {
    private let baseServiceClient = BaseServiceClient()
    private let baseUrl = URL(string: "http://tblearn-api.vigilantestudio.com/v1")!
    
    func getAllCourses(namespace: String, completion: @escaping (_ courses: [CourseInfo]?) -> ()) {
        let url = baseUrl.appendingPathComponent("/quizzes/\(namespace)")
        baseServiceClient.get(from: url, httpHeaders: [:], queryParams: [:], serviceType: "getCourses") { (result) in
            switch result {
            case .success(let json):
                guard let coursesRaw = json as? [CourseInfo] else {
                    completion(nil)
                    Log.error("Could not parse successful JSON response")
                    return
                }
                completion(coursesRaw)
            case .error(let error):
                Log.error(error)
                completion(nil)
            }
        }
    }
    
    func getAllQuizes(userName user: String, classId id: String, quizId qzId: String, token tk: String, completion: @escaping (_ quizes: GetQuizWithToken?) -> ()) {
        let url = baseUrl.appendingPathComponent("/quiz/")
        baseServiceClient.get(from: url, httpHeaders: [:], queryParams: ["user_id":user,"course_id":id, "quiz_id":qzId, "token":tk], serviceType: "getQuizes") { (result) in
            switch result {
            case .success(let json):
                guard let quizesRaw = json as? GetQuizWithToken else {
                    
                    completion(nil)
                    Log.error("Could not parse successful JSON response")
                    return
                }
                completion(quizesRaw)
            case .error(let error):
                Log.error(error)
                completion(nil)
            }
        }
        
    }
    
    

    
    func getGroupInfo(userId: String, courseId: String, completion: @escaping (_ groupInfo: Group?) -> ()){
        let url = baseUrl.appendingPathComponent("/groupForUser/")
        baseServiceClient.get(from: url, httpHeaders: [:], queryParams: ["user_id":userId,"course_id":courseId], serviceType: "getGroupInfo") { (result) in
            switch result {
            case .success(let json):
                guard let groupInfo = json as? Group else {
                    completion(nil)
                    Log.error("Could not parse successful JSON response")
                    return
                }
                completion(groupInfo)
            case .error(let error):
                Log.error(error)
                completion(nil)
            }
        }
    }

    func  getGroupStatus(groupId: String, courseId: String, quizId: String, sessionId: String, completion: @escaping (_ groupStatus: GroupStatus?) -> ()){
        let url = baseUrl.appendingPathComponent("/groupStatus/")
        baseServiceClient.get(from: url, httpHeaders: [:], queryParams: ["group_id":groupId,"course_id":courseId,"quiz_id":quizId,"session_id":sessionId], serviceType: "getGroupStatus") { (result) in
            switch result {
            case .success(let json):
                guard let groupStatusInfo = json as? GroupStatus else {
                    completion(nil)
                    Log.error("Could not parse successful JSON response")
                    return
                }
                
                completion(groupStatusInfo)
            case .error(let error):
                Log.error(error)
                completion(nil)
            }
        }
    }
    
    
    func postAnswers(userId: String, courseId: String, sessionId: String,quiz: Data, completion: @escaping (_ quizResult: QuizResult?) -> ()) {
        let componentPath = baseUrl.absoluteString + "/quiz/?user_id=\(userId)&course_id=\(courseId)&session_id=\(sessionId)"
        let url = URL(string: componentPath)
        
        baseServiceClient.post(to: url!, httpHeaders: ["Content-Type":"application/json;charset=utf-8","Accept":"application/json"], httpBody: quiz, serviceType: "postAnswers") { (result) in
            switch result {
            case .success(let json):
                guard let quizResultRaw = json as? QuizResult else {
                    completion(nil)
                    Log.error("Could not parse successful JSON response")
                    return
                }
                completion(quizResultRaw)
            case .error(let error):
                print("Post Answers error")
                Log.error(error)
                completion(nil)
            }
        }
    }

    func postGroupQuizAnswer(quizId: String, groupId: String, sessionId: String, groupQuizData: Data, completion: @escaping (_ groupQuizResult: GroupQuizAnswerResult?,_ errCode: Int?) -> ()){
        let componentPath = baseUrl.absoluteString + "/groupQuiz/?quiz_id=\(quizId)&group_id=\(groupId)&session_id=\(sessionId)"
        let url = URL(string: componentPath)
        baseServiceClient.post(to: url!, httpHeaders:["Content-Type":"application/json;charset=utf-8","Accept":"application/json"], httpBody: groupQuizData, serviceType: "postGroupAnswer"){ (result) in
            switch result {
            case .success(let json):
                Log.info(json)
                guard let groupQuizResultRaw = json as? GroupQuizAnswerResult else {
                    completion(nil, nil)
                    Log.error(json)
                    Log.error("Could not parse successful JSON response")
                    return
                }
                completion(groupQuizResultRaw, nil)
            case .error(let error):
                print("Post Answers error")
                Log.error(error)
                completion(nil,error.code)
            }
        }
    }
    
    func getGroupQuizProgress(quizId: String, groupId: String, sessionId: String, completion: @escaping (_ groupQuizProgress: GroupQuizProgress?) -> ()){
        let componentPath = baseUrl.absoluteString + "/groupQuizProgress/"
        let url = URL(string: componentPath)
        baseServiceClient.get(from: url!, httpHeaders: [:], queryParams: ["quiz_id":quizId,"group_id":groupId,"session_id":sessionId], serviceType: "groupQuizProgress") { (result) in
            switch result {
            case .success(let json):
                guard let groupStatusInfo = json as? GroupQuizProgress else {
                    completion(nil)
                    Log.error("Could not parse successful JSON response")
                    return
                }
                
                completion(groupStatusInfo)
            case .error(let error):
                Log.error(error)
                completion(nil)
            }
        }
    }
}


