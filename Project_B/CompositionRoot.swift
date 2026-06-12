//
//  CompositionRoot.swift
//  Project_B
//
//  Created by Sai Krishna on 5/27/26.
//

import Foundation
import UIKit
import SwiftUI

class CompositionRoot{
    
    private lazy var navigationVC: UINavigationController = {
        let vc = UINavigationController.init()
        return vc
    }()
    
    func getNavVC() -> UIViewController{
        return navigationVC
    }
    
    func navigateLoginScreen(){
        let vc = LoginScreenBuilder().createModule(openHomeScreen: openHomeScreen)
        navigationVC.setViewControllers([vc], animated: true)
    }
    
    func openHomeScreen(){
        let vc = HomeScreenBuilder().createModule(openDetailsScreen: openDetailsScreen,
                                                  openAddNewEntityScreen: openAddNewEntityScreen,
                                                  openProfileScreen: openProfileScreen)
        navigationVC.pushViewController(vc, animated: true)
    }
    
    func openDetailsScreen(entity: HallResponseModel){
        let vc = DetailsScreenBuilder().createModule(entity: entity, navigateToPreviousScreen: { [weak self] in
            self?.navigationVC.setNavigationBarHidden(false, animated: true)
            self?.navigationVC.popViewController(animated: true)
        },
                                                     openAddNewBookingScreen: openAddNewBookingScreen)
        navigationVC.pushViewController(vc, animated: true)
    }
    
    func openAddNewEntityScreen(entity: HallResponseModel?, refreshDelegate: RefreshDataProtocol){
        let vc = AddNewEntityBuilder().createModule(navigateToPreviousScreen: navigateToPreviousScreen, entity: entity, refreshDelegate: refreshDelegate)
        navigationVC.pushViewController(vc, animated: true)
    }
    
    func openProfileScreen(refreshDelegate: RefreshDataProtocol){
        let vc = ProfileScreenBuilder().createModule(refreshDelegate: refreshDelegate, navigateLoginScreen: { [weak self] in
            self?.navigationVC.setNavigationBarHidden(false, animated: true)
            self?.navigateLoginScreen()
        }, navigateToPreviousScreen: { [weak self] in
            self?.navigationVC.setNavigationBarHidden(false, animated: true)
            self?.navigationVC.popViewController(animated: true)
        }, openFAQScreen: {[weak self] in
            self?.navigationVC.setNavigationBarHidden(false, animated: true)
            self?.openFAQScreen()
            
        })
        navigationVC.pushViewController(vc, animated: true)
    }
    
    func openAddNewBookingScreen(hallId: Int, refreshDelegate: RefreshBookingStatusDelegateProtocol,bookingId: Int?, startDate: Date?, endDate: Date?){
        let vc = AddNewBookingBuilder().createModule(hallId: hallId, navigateToPreviousScreen: navigateToPreviousScreen, refreshDelegate: refreshDelegate, bookingId: bookingId, startDate: startDate, endDate: endDate)
        navigationVC.pushViewController(vc, animated: true)
    }
    
    func openFAQScreen(){
        let vc = UIHostingController(rootView: FAQHelpScreenView())
        navigationVC.pushViewController(vc, animated: true)
    }
    
    func navigateToPreviousScreen(){
        navigationVC.popViewController(animated: true)
    }
}

