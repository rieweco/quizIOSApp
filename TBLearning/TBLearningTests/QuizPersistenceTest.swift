//
//  QuizPersistenceTest.swift
//  TBLearningTests
//
//  Created by Liwei Jiao on 10/1/17.
//  Copyright © 2017 frontOfClassTeam. All rights reserved.
//

import XCTest
@testable import TBLearning
class QuizPersistenceTest: XCTestCase {
    
//    var testObject : QuizPersistence!
    var testObject : UserPersistence!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
//
    func testWhenQuizIsDownload_thenTHeDataCanBePersistedToCoreData(){
//        guard let filePath = Bundle(for: type(of: self)).path(forResource: "quiz_payload", ofType: "json"),
//            let file = FileManager.default.contents(atPath: filePath) else {
//                XCTAssert(false, "Could not load file from the given path")
//                return
//        }
//
//        testObject = QuizPersistence(coreDataManager: CoreDataManager())
//        let expect = XCTestExpectation(description: "Quiz insert")
//        testObject.insertEmptyQuizFromService(with: file) {
//            expect.fulfill()
//        }
//        wait(for: [expect], timeout: 2.0)
//
//        let quiz = testObject.getQuiz()
//        XCTAssertNotNil(quiz)
//
////        XCTAssert(testObject.deleteQuiz(for: quiz!.id!))
//    }
    let userData = UserInfo(userId: "ljcnf",courseId: "cmpsci4220")
    testObject = UserPersistence(coreDataManager: CoreDataManager())
    let expect = XCTestExpectation(description: "User insert")
    testObject.insertEmptyQuizFromService(with: userData){
        expect.fulfill()
    }
    wait(for: [expect], timeout: 2.0)
    let users = testObject.getUser()
    XCTAssertNotNil(users)
    }
}
