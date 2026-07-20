//
//  DetailsScreenRouter.swift
//  Project_B
//
//  Created by Om on 6/5/26.
//

import Foundation

protocol DetailsScreenRouterProtocol{
    func navigateBack()
    func navigateToAddNewBookingScreen(hallId: Int, refreshDelegate: RefreshBookingStatusDelegateProtocol,bookingId: Int?, startDate: Date?, endDate: Date?)
}

class DetailsScreenRouter: DetailsScreenRouterProtocol{
    
    let navigateToPreviousScreen: () -> Void
    let openAddNewBookingScreen: (_ hallId: Int, _ refreshDelegate: RefreshBookingStatusDelegateProtocol,_ bookingId: Int?,_ startDate: Date?, _ endDate: Date?) -> Void
    
    init(navigateToPreviousScreen: @escaping () -> Void, openAddNewBookingScreen: @escaping (_ hallId: Int, _ refreshDelegate: RefreshBookingStatusDelegateProtocol,_ bookingId: Int?,_ startDate: Date?, _ endDate: Date?) -> Void) {
        self.navigateToPreviousScreen = navigateToPreviousScreen
        self.openAddNewBookingScreen = openAddNewBookingScreen
    }
    
    func navigateBack(){
        self.navigateToPreviousScreen()
    }
    
    func navigateToAddNewBookingScreen(hallId: Int, refreshDelegate: RefreshBookingStatusDelegateProtocol,bookingId: Int?, startDate: Date?, endDate: Date?){
        self.openAddNewBookingScreen(hallId, refreshDelegate,bookingId, startDate, endDate)
    }
}
