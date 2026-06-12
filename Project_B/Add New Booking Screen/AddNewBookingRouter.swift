//
//  AddNewBookingRouter.swift
//  Project_B
//
//  Created by Sai Krishna on 6/6/26.
//

import Foundation

protocol AddNewBookingRouterProtocol{
    func navigateBack()
}


class AddNewBookingRouter: AddNewBookingRouterProtocol{
    
    let navigateToPreviousScreen: () -> Void
    
    init(navigateToPreviousScreen: @escaping () -> Void) {
        self.navigateToPreviousScreen = navigateToPreviousScreen
    }
    
    func navigateBack(){
        self.navigateToPreviousScreen()
    }
}
