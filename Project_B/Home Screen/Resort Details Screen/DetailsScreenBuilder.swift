//
//  DetailsScreenBuilder.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import Foundation
import SwiftUI
import UIKit

class DetailsScreenBuilder{
    func createModule(entity: HallResponseModel, navigateToPreviousScreen: @escaping () -> Void, openAddNewBookingScreen: @escaping (_ hallId: Int, _ refreshDelegate: RefreshBookingStatusDelegateProtocol,_ bookingId: Int?, _ startDate: Date?,_ endDate: Date?) -> Void) -> UIViewController{
        let router = DetailsScreenRouter(navigateToPreviousScreen: navigateToPreviousScreen, openAddNewBookingScreen: openAddNewBookingScreen)
        let interactor = DetailsScreenInteractor()
        let presenter = DetailsScreenPresenter(entity: entity, interactor: interactor, router: router)
        let view = DetailsScreenView(presenter: presenter)
        return UIHostingController(rootView: view)
    }
}
