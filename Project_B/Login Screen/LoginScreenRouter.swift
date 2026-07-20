//
//  LoginScreenRouter.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import Foundation

class LoginScreenRouter{
    
    let openHomeScreen: () -> Void
    
    init(openHomeScreen: @escaping () -> Void) {
        self.openHomeScreen = openHomeScreen
    }
    
    
    func navigateToHomeScreen(){
        openHomeScreen()
    }
}
