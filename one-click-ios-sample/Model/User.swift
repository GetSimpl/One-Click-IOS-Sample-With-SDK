//
//  User.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 17/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import Foundation

struct User {
    let emailId: String
    let phoneNumber: String
    
    init(emailId: String, phoneNumber: String) {
        self.emailId = emailId
        self.phoneNumber = phoneNumber
    }
}
