//
//  HomeScreenRouter.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import Foundation
import SwiftUI

protocol HomeScreenRouterProtocol{
    func navigateToDetailsScreen(entity: HallResponseModel)
    func navigateToAddNewEntityScreen(resortEntity: HallResponseModel?, refreshDelegate: RefreshDataProtocol, identifier: String)
    func navigateToProfileScreen(refreshDelegate: RefreshDataProtocol)
    func navigateToAddNewBouquetScreen(bouquetEntity: BouquetDetailsEntity?, refreshDelegate: RefreshDataProtocol, identifier: String)
    func navigateToBouquetDetailsScreen(bouquetEntity: BouquetDetailsEntity)
}

class HomeScreenRouter: HomeScreenRouterProtocol {
    
    let openDetailsScreen: (_ entity: HallResponseModel) -> Void
    let openAddNewEntityScreen: (_ resortEntity: HallResponseModel?,
                                 _ refreshDelegate: RefreshDataProtocol,
                                 _ identifier: String) -> Void
    let openProfileScreen: (_ refreshDelegate: RefreshDataProtocol) -> Void
    
    let openAddNewBouquetScreen: (_ bouquetEntity: BouquetDetailsEntity?,
                                  _ refreshDelegate: RefreshDataProtocol,
                                  _ identifier: String) -> Void
    let openBouquetDetailsScreen: (_ bouquetEntity: BouquetDetailsEntity) -> Void
    
    init(openDetailsScreen: @escaping (_: HallResponseModel) -> Void, openAddNewEntityScreen: @escaping (_: HallResponseModel?, _: RefreshDataProtocol, _: String) -> Void, openProfileScreen: @escaping (_: RefreshDataProtocol) -> Void, openAddNewBouquetScreen: @escaping (_: BouquetDetailsEntity?, _: RefreshDataProtocol, _: String) -> Void, openBouquetDetailsScreen: @escaping (_: BouquetDetailsEntity) -> Void) {
        self.openDetailsScreen = openDetailsScreen
        self.openAddNewEntityScreen = openAddNewEntityScreen
        self.openProfileScreen = openProfileScreen
        self.openAddNewBouquetScreen = openAddNewBouquetScreen
        self.openBouquetDetailsScreen = openBouquetDetailsScreen
    }

    func navigateToDetailsScreen(entity: HallResponseModel){
        openDetailsScreen(entity)
    }
    
    func navigateToAddNewEntityScreen(resortEntity: HallResponseModel?, refreshDelegate: RefreshDataProtocol, identifier: String){
        self.openAddNewEntityScreen(resortEntity, refreshDelegate, identifier)
    }
    
    func navigateToProfileScreen(refreshDelegate: RefreshDataProtocol){
        self.openProfileScreen(refreshDelegate)
    }
    
    func navigateToAddNewBouquetScreen(bouquetEntity: BouquetDetailsEntity?, refreshDelegate: RefreshDataProtocol, identifier: String){
        self.openAddNewBouquetScreen(bouquetEntity, refreshDelegate, identifier)
    }
    
    func navigateToBouquetDetailsScreen(bouquetEntity: BouquetDetailsEntity){
        openBouquetDetailsScreen(bouquetEntity)
    }
}
