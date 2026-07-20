//
//  AddNewEntityRouter.swift
//  Project_B
//
//  Created by Om on 5/29/26.
//

import Foundation

class AddNewEntityRouter{
    
    let navigateToPreviousScreen: () -> Void
    
    init(navigateToPreviousScreen: @escaping () -> Void) {
        self.navigateToPreviousScreen = navigateToPreviousScreen
    }
    
    func navigateBack(){
        navigateToPreviousScreen()
    }
}
