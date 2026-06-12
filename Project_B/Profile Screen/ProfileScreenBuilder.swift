//
//  ProfileScreenBuilder.swift
//  Project_B
//
//  Created by Sai Krishna on 6/3/26.
//

import Foundation
import UIKit
import SwiftUI

class ProfileScreenBuilder{
    func createModule(refreshDelegate: RefreshDataProtocol, navigateLoginScreen: @escaping () -> Void, navigateToPreviousScreen: @escaping () -> Void, openFAQScreen: @escaping () -> Void) -> UIViewController{
        
        let interactor = ProfileScreenInteractor()
        let router = ProfileScreenRouter(navigateLoginScreen: navigateLoginScreen, navigateToPreviousScreen: navigateToPreviousScreen, openFAQScreen: openFAQScreen)
        let presenter = ProfileScreenPresenter(router: router, interactor: interactor)
        presenter.refreshDelegate = refreshDelegate
        let view = ProfileScreenView(presenter: presenter)
        
        return UIHostingController(rootView: view)
    }
}
