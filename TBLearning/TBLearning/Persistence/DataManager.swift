import Foundation

/*
 //poster
 NotificationCenter.default.post(name: Notification.Name.UIApplicationWillTerminate, object: self    )
 //receiver
 NotificationCenter.default.addObserver(self, selector: #selector(testEnd), name: Notification.Name.UIApplicationWillTerminate, object: nil)
 */


class DataManager {
    
    let userPersistence: UserPersistence
    let individualQuizPersistence: QuizPersistence
    let groupQuizPersistence: GroupQuizPersistence
    
//    private var _username: String?
//    var username: String? {
//        get { return _username }
//        set {
//            if !isUserLoggedIn { _username = newValue }
//        }
//    }
    
    init() {
        let coreDataManager = CoreDataManager()
        self.userPersistence = UserPersistence(coreDataManager: coreDataManager)
        self.individualQuizPersistence = QuizPersistence(coreDataManager: coreDataManager)
        self.groupQuizPersistence = GroupQuizPersistence(coreDataManager: coreDataManager)
    }
    
//    private var _isUserLoggedIn: Bool = false
//    var isUserLoggedIn: Bool {
//        return _isUserLoggedIn
//    }
//
//    func attemptLogin(_ complete: (Bool) -> Void) {
//        _isUserLoggedIn = true
//        complete(isUserLoggedIn)
//    }
//
//    private var _isUserInQuiz: Bool = false
//    var isUserInQuiz: Bool{
//        return _isUserInQuiz
//    }
//
//    func attemptContinueQuiz(_ complete: (Bool) -> Void){
//        _isUserInQuiz = true
//        complete(isUserInQuiz)
//    }
//
//    private var _isLeader: Bool = false
//    var isLeader: Bool{
//        return _isLeader
//    }
//
//    func attemptTakeGroupQuiz(_ complete: (Bool) -> Void){
//        _isLeader = true
//        complete(isLeader)
//    }
}
