//
//  CompositionRoot.swift
//  Project_B
//
//  Created by Om on 5/27/26.
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
                                                  openProfileScreen: openProfileScreen,
                                                  openAddNewBouquetScreen: openAddNewBouquetScreen,
                                                  openBouquetDetailsScreen: openBouquetDetailsScreen)
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
    
    func openAddNewEntityScreen(resortEntity: HallResponseModel?, refreshDelegate: RefreshDataProtocol, identifier: String){
 
//===================================================================
        
        if identifier == "resort"{
            
        }else if identifier == "bouquet"{
            
        }
//===================================================================
        
        let vc = AddNewEntityBuilder().createModule(navigateToPreviousScreen: navigateToPreviousScreen, resortEntity: resortEntity, refreshDelegate: refreshDelegate, identifier: identifier, bouquetEntity: nil)
        navigationVC.pushViewController(vc, animated: true)
    }
    func openAddNewBouquetScreen(bouquetEntity: BouquetDetailsEntity?, refreshDelegate: RefreshDataProtocol, identifier: String){
        let vc = AddNewEntityBuilder().createModule(navigateToPreviousScreen: navigateToPreviousScreen, resortEntity: nil, refreshDelegate: refreshDelegate, identifier: identifier, bouquetEntity: bouquetEntity)
        navigationVC.pushViewController(vc, animated: true)
    }
//    func openBouquetDetailsScreen(bouquetEntity: BouquetDetailsEntity){
//        let vc =
//    }
    
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
    
    func openBouquetDetailsScreen(bouquetEntity: BouquetDetailsEntity){
        let vc = BouquetDetailsBuilder().createModule(bouquetEntity: bouquetEntity,
                                                      navigateToPreviousScreen: {[weak self] in
            self?.navigationVC.setNavigationBarHidden(false, animated: true)
            self?.navigationVC.popViewController(animated: true)
            
        })
        navigationVC.pushViewController(vc, animated: true)
    }
    
    func navigateToPreviousScreen(){
        navigationVC.popViewController(animated: true)
    }
}

