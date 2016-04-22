//
//  ClientRepository.swift
//  Loopback-Swift-Example
//
//  Created by Kevin Goedecke on 12/9/15.
//  Copyright © 2015 kevingoedecke. All rights reserved.
//

import Foundation

class ClientRepository: LBUserRepository {
    
    var mutableCurrentUserId: String?
    override var currentUserId: String! {
        // ^ had to override this val so we can set it from the FB linked login request
        get {
            return mutableCurrentUserId
        }
        set {
            mutableCurrentUserId = newValue
        }
    }

    override init!(className name: String!) {
        super.init(className: "users")
    }
    override init() {
        super.init(className: "users")
    }
}

class Client: LBUser {
    
}