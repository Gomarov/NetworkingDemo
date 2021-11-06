//
//  UserProfile.swift
//  JsonApp
//
//  Created by  Pavel on 22.08.2021.
//

import Foundation

struct UserProfile {
    let id: Int?
    let name: String?
    let email: String?
    
    init(data: [String: Any]) {
        id = data["id"] as? Int
        name = data["name"] as? String
        email = data["email"] as? String
    }
}
