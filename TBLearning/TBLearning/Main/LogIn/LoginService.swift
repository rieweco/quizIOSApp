import Foundation

protocol GetCoursesDelegate: class {
    func dataUpdate()
}

protocol CheckCoursesExistDelegate: class {
    func checkCourseExist()
}

class LoginService {
    weak var getCourseDelegate: GetCoursesDelegate?
    weak var checkCourseDelegate: CheckCoursesExistDelegate?
    static var userId : String?
    static var quizes = [CourseInfo]()
    private let serviceClient = ServiceClient()
    
    func loadQuizes(with id: String){
        serviceClient.getAllCourses(namespace: id) { (coursesFromServer) in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else{return}
                guard let courses = coursesFromServer else {
                        weakSelf.checkCourseDelegate?.checkCourseExist()
                        return }
                    LoginService.quizes = courses
                    weakSelf.getCourseDelegate?.dataUpdate()
                }
        }
    }
}

