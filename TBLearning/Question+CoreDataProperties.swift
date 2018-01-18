//
//  Question+CoreDataProperties.swift
//  
//
//  Created by Kaci Wang on 2017/12/10.
//
//

import Foundation
import CoreData


extension Question {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question")
    }

    @NSManaged public var id: String?
    @NSManaged public var points: Int16
    @NSManaged public var score: Int16
    @NSManaged public var status: String?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var answer: Set<Answer>?
    @NSManaged public var quiz: Quiz?

}

// MARK: Generated accessors for answer
extension Question {

    @objc(addAnswerObject:)
    @NSManaged public func addToAnswer(_ value: Answer)

    @objc(removeAnswerObject:)
    @NSManaged public func removeFromAnswer(_ value: Answer)

    @objc(addAnswer:)
    @NSManaged public func addToAnswer(_ values: NSSet)

    @objc(removeAnswer:)
    @NSManaged public func removeFromAnswer(_ values: NSSet)

}
