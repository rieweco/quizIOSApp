//
//  Answer+CoreDataProperties.swift
//  
//
//  Created by Kaci Wang on 2017/12/10.
//
//

import Foundation
import CoreData


extension Answer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Answer> {
        return NSFetchRequest<Answer>(entityName: "Answer")
    }

    @NSManaged public var imageUri: String?
    @NSManaged public var points: Int16
    @NSManaged public var questionId: String?
    @NSManaged public var sortId: Int16
    @NSManaged public var text: String?
    @NSManaged public var value: String?
    @NSManaged public var question: Question?

}
