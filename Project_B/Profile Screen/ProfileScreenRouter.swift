//
//  ProfileScreenRouter.swift
//  Project_B
//
//  Created by Sai Krishna on 6/3/26.
//

import Foundation

protocol ProfileScreenRouterProtocol{
    func navigateToLoginScreen()
    func navigateBack()
    func navigateToFAQScreen()
}

class ProfileScreenRouter: ProfileScreenRouterProtocol{
    
    let navigateLoginScreen: () -> Void
    let navigateToPreviousScreen: () -> Void
    let openFAQScreen: () -> Void
    
    init(navigateLoginScreen: @escaping () -> Void, navigateToPreviousScreen: @escaping () -> Void, openFAQScreen: @escaping () -> Void) {
        self.navigateLoginScreen = navigateLoginScreen
        self.navigateToPreviousScreen = navigateToPreviousScreen
        self.openFAQScreen = openFAQScreen
    }
    
    func navigateToLoginScreen(){
        self.navigateLoginScreen()
    }
    
    func navigateBack(){
        self.navigateToPreviousScreen()
    }
    
    func navigateToFAQScreen(){
        self.openFAQScreen()
    }
}
