//
//  ProfileScreenEntity.swift
//  Project_B
//
//  Created by Om on 6/4/26.
//

import Foundation

struct UserDTO: Codable {
    let uid: String
    var name: String
    var email: String?
    var address: String?
    let mobileNumber: String
    var profileImagePath: String?
}
