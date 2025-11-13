//
//  File.swift
//  TravelAPI
//
//  Created by Isaque da Silva on 11/11/25.
//

import Vapor

extension CreateUserDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add(
            CreateUserDTO.CodingKeys.name.key,
            as: String.self,
            is: .count(2...),
            required: true,
            customFailureDescription: "Missing name."
        )
        
        validations.add(
            CreateUserDTO.CodingKeys.email.key,
            as: String.self,
            is: .email,
            required: true,
            customFailureDescription: "Email needs to be valid to proceed."
        )
        
        validations.add(
            CreateUserDTO.CodingKeys.password.key,
            as: String.self,
            is: .custom("Validate if passowrd follows the minum requirements of security.") { password in
                isValidPassword(password)
            },
            required: true,
            customFailureDescription: "Your password not match with the minimum security requirements."
        )
    }
    
    @Sendable
    private static func isValidPassword(_ password: String) -> Bool {
        let pattern = /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/
        return password.wholeMatch(of: pattern) != nil
    }
}
