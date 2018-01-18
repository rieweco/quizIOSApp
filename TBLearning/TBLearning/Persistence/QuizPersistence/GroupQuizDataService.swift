//
//  GroupQuizService.swift
//  TBLearning
//
//  Created by Liwei Jiao on 12/7/17.
//  Copyright © 2017 frontOfClassTeam. All rights reserved.
//

import Foundation
//groupQuizProgress

struct GroupQuizProgress: Codable{
    let totalQuestions: Int16
    let questionsAnswered: Int16
    let givenAnswers: [AnswerResult]
}


struct GroupQuizAnswerResult: Codable {
    let question: String
    let submittedAnswers: [SubmitAnswer]
    let pointsRemaining: Int16?
    enum CodingKeys: String, CodingKey{
        case question
        case submittedAnswers
        case pointsRemaining
    }
}

//GroupQuizResult for coreData
struct GroupQuizAnswerForCD: Codable{
    let isCorrect: Bool
    let points: Int16
    let questionId: String
    let quizId: String
    let value: String
}




//GroupQuiz post body
struct GroupQuizPostBody: Codable{
    let question_id: String
    let answerValue: String
    
    enum CodingKeys: String, CodingKey{
        case question_id, answerValue
    }
}



//get groupForUser
struct Group: Codable{
    let id: String
    let name: String
    let courseIds: [String]
    let users: [GroupMember]?
    
    enum CodingKeys: String,CodingKey {
        case id = "_id"
        case name
        case courseIds
        case users
    }
}

struct GroupMember: Codable{
    let userID: String
    let email: String
    let first: String
    let last: String
}


//for post groupQuiz Resposne same as AnswerResult of individual quiz


//for get groupMember response
//groupQuizProgress?quiz_id= &group_id= &session_id=
struct QuizProgressForMember: Codable{
    let totalQuestions: Int16
    let questionsAnswered: Int16
    let givenAsnwers: [QuizGivenAnswerForMember]
}

struct QuizGivenAnswerForMember: Codable{
    let question: String
    let submittedAnswers: [SubmitAnswer]
    let numberOfAttempts: Int16
    let AnsweredCorrectly: Bool
}


//get groupStatus /v1/groupStatus

struct GroupMemberStatus: Decodable{
    let status: String
    let userId: String
    let first: String
    let last: String
    let timeStarted: Date
    let timeLimit: Int16
    let groupName: String
}
struct GroupLeader: Decodable{
    let userId: String
    let first: String
    let last: String
}

struct GroupStatus: Decodable{
    let leader: GroupLeader
    let status: [GroupMemberStatus]
    enum GroupStatusKeys: String, CodingKey{
        case status
        case leader
    }
    
    
}

