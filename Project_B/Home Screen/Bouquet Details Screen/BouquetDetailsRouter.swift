//
//  BouquetDetailsRouter.swift
//  Project_B
//
//  Created by Om on 6/24/26.
//

import Foundation

class BouquetDetailsRouter{
    let navigateToPreviousScreen: () -> Void
    
    init(navigateToPreviousScreen: @escaping () -> Void) {
        self.navigateToPreviousScreen = navigateToPreviousScreen
    }
    
    func navigateToListScreen(){
        self.navigateToPreviousScreen()
    }
}
