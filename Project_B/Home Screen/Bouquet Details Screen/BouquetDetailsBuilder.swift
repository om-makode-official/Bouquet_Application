//
//  BouquetDetailsBuilder.swift
//  Project_B
//
//  Created by Om on 6/19/26.
//

import Foundation
import UIKit
import SwiftUI

class BouquetDetailsBuilder{
    func createModule(bouquetEntity: BouquetDetailsEntity, navigateToPreviousScreen: @escaping () -> Void) -> UIViewController{
        let router = BouquetDetailsRouter(navigateToPreviousScreen: navigateToPreviousScreen)
        let interactor = BouquetDetailsInteractor()
        let presenter = BouquetDetailsPresenter(entity: bouquetEntity, router: router, interactor: interactor)
        let view = BouquetDetailsView(presenter: presenter)
        
        return UIHostingController(rootView: view)
    }
}
