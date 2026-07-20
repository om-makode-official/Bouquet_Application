//
//  AddNewBookingBuilder.swift
//  Project_B
//
//  Created by Om on 6/6/26.
//

import Foundation
import UIKit
import SwiftUI

class AddNewBookingBuilder{
    
    func createModule(hallId: Int, navigateToPreviousScreen: @escaping () -> Void, refreshDelegate: RefreshBookingStatusDelegateProtocol,bookingId: Int?, startDate: Date?, endDate: Date?) -> UIViewController{
        let router = AddNewBookingRouter(navigateToPreviousScreen: navigateToPreviousScreen)
        let interactor = AddNewBookingInteractor()
        let presenter = AddNewBookingPresenter(interactor: interactor,router: router, hallId: hallId,bookingId: bookingId, startDate: startDate, endDate: endDate)
        presenter.refreshDelegate = refreshDelegate
        let view = AddNewBookingView(presenter: presenter)
        
        return UIHostingController(rootView: view)
    }
}
