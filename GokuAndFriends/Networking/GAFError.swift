//
//  GAFError.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 6/4/25.
//

import Foundation

enum GAFError: Error {
    case barUrl
    case serverError(error: Error)
    case responseError(code: Int?)
    case noDataReceived
    case errorParsingData
    case sessionTokenMissed
}
