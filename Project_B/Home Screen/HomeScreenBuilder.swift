//
//  HomeScreenBuilder.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import Foundation
import UIKit
import SwiftUI

class HomeScreenBuilder{
    func createModule(openDetailsScreen: @escaping (_ entity: HallResponseModel) -> Void,
                      openAddNewEntityScreen: @escaping (_ resortEntity: HallResponseModel?,
                                                         _ refreshDelegate: RefreshDataProtocol,
                                                         _ identifier: String) -> Void,
                      openProfileScreen: @escaping (_ refreshDelegate: RefreshDataProtocol) -> Void,
                      openAddNewBouquetScreen: @escaping (_ bouquetEntity: BouquetDetailsEntity?,
                                                          _ refreshDelegate: RefreshDataProtocol,
                                                          _ identifier: String) -> Void,
                      openBouquetDetailsScreen: @escaping (_ bouquetEntity: BouquetDetailsEntity) -> Void) -> UIViewController{
        let interactor = HomeScreenInteractor()
        let router = HomeScreenRouter(openDetailsScreen: openDetailsScreen,
                                      openAddNewEntityScreen: openAddNewEntityScreen,
                                      openProfileScreen: openProfileScreen,
                                      openAddNewBouquetScreen: openAddNewBouquetScreen,
                                      openBouquetDetailsScreen: openBouquetDetailsScreen)
        let presenter = HomeScreenPresenter(router: router,interactor: interactor)
        let view = HomeScreenView(presenter: presenter)
        return UIHostingController(rootView: view)
    }
}
