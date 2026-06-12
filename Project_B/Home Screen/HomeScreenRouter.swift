//
//  HomeScreenRouter.swift
//  Project_B
//
//  Created by Sai Krishna on 5/27/26.
//

import Foundation
import SwiftUI

protocol HomeScreenRouterProtocol{
    func navigateToDetailsScreen(entity: HallResponseModel)
    func navigateToAddNewEntityScreen(entity: HallResponseModel?, refreshDelegate: RefreshDataProtocol)
    func navigateToProfileScreen(refreshDelegate: RefreshDataProtocol)
}

class HomeScreenRouter: HomeScreenRouterProtocol {
    
    let openDetailsScreen: (_ entity: HallResponseModel) -> Void
    let openAddNewEntityScreen: (_ entity: HallResponseModel?,
                                 _ refreshDelegate: RefreshDataProtocol) -> Void
    let openProfileScreen: (_ refreshDelegate: RefreshDataProtocol) -> Void
    
    init(openDetailsScreen: @escaping (_: HallResponseModel) -> Void, openAddNewEntityScreen: @escaping (_: HallResponseModel?, _: RefreshDataProtocol) -> Void, openProfileScreen: @escaping (_ refreshDelegate: RefreshDataProtocol) -> Void) {
        self.openDetailsScreen = openDetailsScreen
        self.openAddNewEntityScreen = openAddNewEntityScreen
        self.openProfileScreen = openProfileScreen
    }

    func navigateToDetailsScreen(entity: HallResponseModel){
        openDetailsScreen(entity)
    }
    
    func navigateToAddNewEntityScreen(entity: HallResponseModel?, refreshDelegate: RefreshDataProtocol){
        self.openAddNewEntityScreen(entity, refreshDelegate)
    }
    
    func navigateToProfileScreen(refreshDelegate: RefreshDataProtocol){
        self.openProfileScreen(refreshDelegate)
    }
}
