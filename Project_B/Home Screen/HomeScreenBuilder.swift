//
//  HomeScreenBuilder.swift
//  Project_B
//
//  Created by Sai Krishna on 5/27/26.
//

import Foundation
import UIKit
import SwiftUI

class HomeScreenBuilder{
    func createModule(openDetailsScreen: @escaping (_ entity: HallResponseModel) -> Void,
                      openAddNewEntityScreen: @escaping (_ entity: HallResponseModel?,
                                                         _ refreshDelegate: RefreshDataProtocol) -> Void,
                      openProfileScreen: @escaping (_ refreshDelegate: RefreshDataProtocol) -> Void) -> UIViewController{
        let interactor = HomeScreenInteractor()
        let router = HomeScreenRouter(openDetailsScreen: openDetailsScreen,
                                      openAddNewEntityScreen: openAddNewEntityScreen,
                                                       openProfileScreen: openProfileScreen)
        let presenter = HomeScreenPresenter(router: router,interactor: interactor)
        let view = HomeScreenView(presenter: presenter)
//        let view = CustomCalendarView()
//        let view = AddBookingScreen()
//        let view = FAQHelpScreenView()
        return UIHostingController(rootView: view)
    }
}
