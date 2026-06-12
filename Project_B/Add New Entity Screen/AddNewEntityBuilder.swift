//
//  AddNewEntityBuilder.swift
//  Project_B
//
//  Created by Sai Krishna on 5/28/26.
//

import Foundation
import UIKit
import SwiftUI

class AddNewEntityBuilder{
    func createModule(navigateToPreviousScreen: @escaping () -> Void, entity: HallResponseModel?, refreshDelegate: RefreshDataProtocol) -> UIViewController{
        let router = AddNewEntityRouter(navigateToPreviousScreen: navigateToPreviousScreen)
        let interactor = AddNewEntityInteractor()
        let presenter = AddNewEntityPresenter(interactor: interactor, router: router, entity: entity)
        presenter.refreshDelegate = refreshDelegate
        let view = AddNewEntityView(presenter: presenter)
        
        return UIHostingController(rootView: view)
    }
}
