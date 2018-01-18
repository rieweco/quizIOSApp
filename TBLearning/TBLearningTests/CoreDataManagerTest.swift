//
//  TBLearningTests.swift
//  TBLearningTests
//
//  Created by Liwei Jiao on 10/1/17.
//  Copyright © 2017 frontOfClassTeam. All rights reserved.
//

import XCTest
@testable import TBLearning //access internal variables, functions, classes, structs
                            //modules, can have namespaces, w/o testabe everything in the modules has to be public or open
class CoreDataManagerTest: XCTestCase {
    
    var testObject: CoreDataManager!
    
    override func setUp() {
        super.setUp()
        testObject = CoreDataManager()
    }
    
    override func tearDown() {
        testObject = nil
        super.tearDown()
    }
    
    func testThatCoreDataIsInitialized(){
        XCTAssertEqual(testObject.persistentContainer.name, "TBLearning")
        XCTAssertTrue(testObject.persistentContainer.persistentStoreDescriptions.count == 1)
        let storeUrl = testObject.persistentContainer.persistentStoreDescriptions.first?.url
        print(storeUrl ?? "")
        XCTAssertEqual(storeUrl?.lastPathComponent, "TBLearning.sqlite")
    }
    
}
