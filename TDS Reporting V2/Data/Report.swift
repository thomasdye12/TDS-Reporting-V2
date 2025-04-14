//
//  Report.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 13/04/2025.
//


import Foundation
struct Report: Codable, Identifiable,Equatable {
    let id: String
    var title: String
    var topic: String
    var type: String
    var severity: String
    var firstSeen: Date
    var description: String
    var status: ReportStatus
    var user: UserInfo
    var lastUpdated: Date?
    var editable: Bool?
    var comments: [Comments]?
    var customAnswers: [String: String]?
    var editableV2:String?
}

struct UserInfo: Codable,Equatable {
    let username: String
    let GUUID: String
    let apnsToken: APNSarray
}

struct Comments: Codable,Identifiable, Hashable,Equatable {
    let id:String
    let username: String
    let GUUID: String
    let Comments: String
    let timestamp: Date
}

struct FormOptionsResponse: Codable {
    let topics: [String]
    let typeOptions: [String: [String]]
    let customQuestions: [String: [String: [String]]]?
}
