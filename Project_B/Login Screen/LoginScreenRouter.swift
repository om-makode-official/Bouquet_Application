//
//  LoginScreenRouter.swift
//  Project_B
//
//  Created by Sai Krishna on 5/27/26.
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
