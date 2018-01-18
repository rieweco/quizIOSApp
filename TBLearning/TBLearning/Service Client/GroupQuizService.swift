import Foundation

protocol GroupQuizServiceDelegate: class {
    func answerPassUIUpdate()
    func answerFailedUIUpdate()
    func duplicateAnswer()
    func invalidPostCall()
    func noPointsLeft()
}

protocol StartPullGroupStatusNetworkCallDelegate: class{
    func startPullingGroupStatus()
}

protocol GroupProgressDelegate: class {
    func updateLabel()
}

protocol GroupQuizProgressDelegate: class {
    func updateGroupQuizOnSameQuestion()
    func updateGroupQuizProgressData()
    func updateGroupQuizProgressFailed()
}

class GroupQuizService{
    weak var groupQuizServiceDelegate: GroupQuizServiceDelegate?
    weak var startPullGroupStatusDelegate: StartPullGroupStatusNetworkCallDelegate?
    weak var groupProgressDelegate: GroupProgressDelegate?
    weak var groupQuizProgressDelegate: GroupQuizProgressDelegate?
    var session = DataManager() //persist groupquiz reulst
    
    private let serviceClient = ServiceClient()
    
    static var groupInfo: Group? // /groupForUser network call
    static var grpId: String?
    static var groupQuizProgressInfo: GroupQuizProgress? // store groupQuizProgress data for member view
    static var groupQuizSubmittedAnswers: [AnswerResult] = [] // store submittedAnswers of specific Quiz
    static var groupQuizQuestionIndex: Int = 0;
    
    var groupId: String?{
        didSet{
            GroupQuizService.grpId = groupId
            startPullGroupStatusDelegate?.startPullingGroupStatus()
        }
    }  // /hold groupId
    static var groupMembers: [GroupMember] = []
    static var groupQuizResult: [GroupQuizAnswerResult] = []
    //group status info
    static var groupStatus: GroupStatus?
    static var groupMemberStatus:[GroupMemberStatus] = []
    static var groupLeaderStatus: GroupLeader?
    func loadGroupInfo(userId: String, courseId: String){
        serviceClient.getGroupInfo(userId: userId, courseId: courseId) { (groupInfo) in
            DispatchQueue.main.async {
                if let group = groupInfo {
                    self.groupId = group.id
                    GroupQuizService.groupInfo = group
                    
                    if let members = group.users{
                        for member in members{
                            GroupQuizService.groupMembers.append(member)
                        }
                    }
                }
            }
        }
    }
    
    func loadGroupStatus(groupId: String, courseId: String, quizId: String, sessionId: String){
        serviceClient.getGroupStatus(groupId: groupId, courseId: courseId, quizId: quizId, sessionId: sessionId) { (groupStatusInfo) in
            GroupQuizService.groupStatus = nil
            GroupQuizService.groupLeaderStatus = nil
            GroupQuizService.groupMemberStatus.removeAll()
            DispatchQueue.main.async {
                if let groupStatus = groupStatusInfo {
                    GroupQuizService.groupStatus = groupStatus
                    GroupQuizService.groupLeaderStatus = groupStatus.leader
                    for member in groupStatus.status{
                        GroupQuizService.groupMemberStatus.append(member)
                    }
                }
                self.groupProgressDelegate?.updateLabel()
                
            }
        }
    }
    
    
    
    func loadGroupQuizResult(quizId: String, groupId: String, sessionId: String, groupQuizData: Data){
        serviceClient.postGroupQuizAnswer(quizId: quizId, groupId: groupId, sessionId: sessionId, groupQuizData: groupQuizData){ (postResponseGroupQuizResult,errCode)  in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                if let error = errCode{
                    if error == 404{
                        weakSelf.groupQuizServiceDelegate?.duplicateAnswer()
                    }else{
                        weakSelf.groupQuizServiceDelegate?.invalidPostCall()
                    }
                }else{
                    
                    if let singleGroupQuizAnswer = postResponseGroupQuizResult {
                        let userAttemptsCount = singleGroupQuizAnswer.submittedAnswers.count
                        if singleGroupQuizAnswer.pointsRemaining != 0{
                            if singleGroupQuizAnswer.submittedAnswers[userAttemptsCount-1].isCorrect{
                                GroupQuizService.groupQuizResult.append(singleGroupQuizAnswer)
                                //presist groupQuiz Result into CoreData
                                let result = GroupQuizAnswerForCD(isCorrect: singleGroupQuizAnswer.submittedAnswers[userAttemptsCount-1].isCorrect, points: singleGroupQuizAnswer.submittedAnswers[userAttemptsCount-1].points, questionId: singleGroupQuizAnswer.question, quizId: IndividualQuizService.quizId!, value: singleGroupQuizAnswer.submittedAnswers[userAttemptsCount-1].value ?? "")
                                
                                weakSelf.session.groupQuizPersistence.saveGroupQuizResult(groupQuiz: result, complete: nil)
                                
                                weakSelf.groupQuizServiceDelegate?.answerPassUIUpdate()
                            }else{
                                NotificationCenter.default.post(name:Notification.Name(rawValue:"groupQuizQuestionPointsRemain"),
                                                                object: nil,
                                                                userInfo: ["pointLeft": String(describing: singleGroupQuizAnswer.pointsRemaining!)])
                                weakSelf.groupQuizServiceDelegate?.answerFailedUIUpdate()
                            }
                        }else{
                            //presist groupQuiz Result into CoreData
                            Log.info(IndividualQuizService.quizId!)
                            guard let answerValue = singleGroupQuizAnswer.submittedAnswers[userAttemptsCount-1].value  else {
                                weakSelf.groupQuizServiceDelegate?.noPointsLeft()
                                return
                            }
                            let result = GroupQuizAnswerForCD(isCorrect: singleGroupQuizAnswer.submittedAnswers[userAttemptsCount-1].isCorrect, points: singleGroupQuizAnswer.submittedAnswers[userAttemptsCount-1].points, questionId: singleGroupQuizAnswer.question, quizId: IndividualQuizService.quizId!, value: answerValue)
                            
                            weakSelf.session.groupQuizPersistence.saveGroupQuizResult(groupQuiz: result, complete: nil)
                            weakSelf.groupQuizServiceDelegate?.noPointsLeft()
                        }
                    }
                }
                
            }
            
        }
    }
    func resetGroupQuizData(){
        GroupQuizService.groupQuizProgressInfo = nil
        GroupQuizService.groupMembers.removeAll()
        GroupQuizService.groupQuizResult.removeAll()
        GroupQuizService.groupMemberStatus.removeAll()
        GroupQuizService.groupQuizSubmittedAnswers.removeAll()
        GroupQuizService.groupQuizQuestionIndex = 0;
    }
    
    
    func loadGroupQuizProgress(quizId: String, groupId: String, sessionId: String){
        serviceClient.getGroupQuizProgress(quizId: quizId, groupId: groupId, sessionId: sessionId) { (groupQuizProgressInfo) in
            DispatchQueue.main.async {[weak self] in
                guard let weakSelf = self else { return }
                if let group = groupQuizProgressInfo {
                    GroupQuizService.groupQuizProgressInfo = group
                    if group.givenAnswers.count != 0{
                        if GroupQuizService.groupQuizSubmittedAnswers.count != 0 && group.givenAnswers[group.givenAnswers.count - 1].question ==
                            GroupQuizService.groupQuizSubmittedAnswers[GroupQuizService.groupQuizSubmittedAnswers.count - 1].question{
                            GroupQuizService.groupQuizSubmittedAnswers[GroupQuizService.groupQuizSubmittedAnswers.count - 1] = group.givenAnswers[group.givenAnswers.count - 1]
                            weakSelf.groupQuizProgressDelegate?.updateGroupQuizOnSameQuestion()
                        }else{
                            let newQuestionResult = group.givenAnswers[group.givenAnswers.count - 1]; GroupQuizService.groupQuizSubmittedAnswers.append(newQuestionResult)
                            weakSelf.groupQuizProgressDelegate?.updateGroupQuizProgressData()
                        }
                    }
                    
                }else{
                    weakSelf.groupQuizProgressDelegate?.updateGroupQuizProgressFailed()
                }
                
            }
        }
        
    }
    
    
    
    
    
    
    
    
}
