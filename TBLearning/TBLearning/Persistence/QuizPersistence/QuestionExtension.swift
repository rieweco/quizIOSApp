import Foundation
import CoreData

extension Question{
    func populate(with question: ServiceQuestion){
        self.id = question.id
        self.text = question.text
        self.title = question.title
        self.points = question.pointsPossible
    }
}
