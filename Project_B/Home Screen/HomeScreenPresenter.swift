//
//  HomeScreenPresenter.swift
//  Project_B
//
//  Created by Om on 5/28/26.
//

import Foundation
import MapKit
import FirebaseAuth
import SwiftUI

protocol RefreshDataProtocol{
    func fetchAllEntities()
    func fetchAllBouquets()
}

class HomeScreenPresenter: ObservableObject, RefreshDataProtocol{
    
    @Published var loadingState: HomeScreenLoadingState = .idle
    @Published var bouquetLoadingState: BouquetLoadingState = .idle
    @Published var alertType: HomeScreenAlertEnum?
    @Published var bouquetAlertType: HomeScreenAlertEnum?
    @Published var isLikedHallsListView: Bool = false
    @Published var hallsData: [HallResponseModel] = []
    @Published var filteredHallList: [HallResponseModel] = []
    @Published var contentTabs: [ContentTabsEnum] = [.halls, .bouquet, .items, .other]
    @Published var selectedTab: ContentTabsEnum = .halls
    
    @Published var bouquets: [BouquetDetailsEntity] = []
    
    @Published var isLikedBouquetListView: Bool = false
    
    
    let router: HomeScreenRouterProtocol
    let interactor: HomeScreenInteractor
 
    init(router: HomeScreenRouterProtocol, interactor: HomeScreenInteractor) {
        self.router = router
        self.interactor = interactor
        
        fetchAllEntities()
        checkRoleStatus()
        
        fetchAllBouquets()
    }
    

    
    func fetchAllEntities(){
        self.loadingState = .loading
        Task{
            do{
                guard let response = try await interactor.fetchAllEntities() else { return }
                await MainActor.run{
                    self.loadingState = .loaded(response)
                    self.hallsData = response
                }
            }catch let error{
                await MainActor.run{
                    self.loadingState = .error
                    print(error.localizedDescription)
                }
            }
        }
    }
    func deleteEntityById(id: Int){
        self.alertType = .action(title: "Delete", message: "Are you sure to delete this Resort?", action: {
            self.deleteEntity(id: id)
        })
    }
    
    func deleteEntity(id: Int){
        Task{
            do{
                let response = try await interactor.deleteEntity(id: id)
                
                await MainActor.run{
                    if response == true{
                        self.alertType = .message(title: "", message: "Deleted Successfully")
                        self.fetchAllEntities()
                    }
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    func checkRoleStatus(){
        Task{
            do{
                let response = await AuthManager.checkAdminStatus()
                await MainActor.run{
                    AuthManager.shared.isAdmin = response
                }
            }
        }
    }
    
    func getLikedHallList(){
        loadingState = .loading
        Task{
            do{
                let likedIds = try await interactor.fetchLikedHallIds(userId: Auth.auth().currentUser?.uid ?? "")
                await MainActor.run{
                    if !hallsData.isEmpty{
                        let filtered = hallsData.filter {
                            likedIds.contains($0.id ?? 0)
                        }
                        self.loadingState = .loaded(filtered)
                    }
                }
            }catch let error{
                print(error)
            }
        }
    }
    func getAllHallList(){
        loadingState = .loaded(hallsData)
    }
    
    func navigateToDetailsScreen(entity: HallResponseModel){
        router.navigateToDetailsScreen(entity: entity)
    }
    func navigateToAddResortScreen(entity: HallResponseModel?){
        router.navigateToAddNewEntityScreen(resortEntity: entity, refreshDelegate: self, identifier: "resort")
    }
    func navigateToProfileScreen(){
        self.router.navigateToProfileScreen(refreshDelegate: self)
    }
}

extension HomeScreenPresenter{
    func fetchAllBouquets() {
        self.bouquetLoadingState = .loading
        Task{
            do{
                let response = try await interactor.fetchAllBouquets()
                await MainActor.run{
                    self.bouquetLoadingState = .loaded(response)
                    self.bouquets = response
                }
                print("bouquet response",response)
            }catch let error{
                print(error.localizedDescription)
                await MainActor.run{
                    self.bouquetLoadingState = .error
                }
            }
        }
    }
    func deleteBouquetById(id: Int){
        self.bouquetAlertType = .action(title: "Delete", message: "Are you sure to delete this Bouquet?", action: {
            self.deleteBouquet(id: id)
        })
    }
    
    func deleteBouquet(id: Int){
        Task{
            do{
                let response = try await interactor.deleteBouquet(id: id)
                
                await MainActor.run{
                    if response == true{
                        self.bouquetAlertType = .message(title: "", message: "Deleted Successfully")
                        self.fetchAllBouquets()
                    }
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    func getLikedBouquetList(){
        bouquetLoadingState = .loading
        Task{
            do{
                let likedIds = try await interactor.fetchLikedBouquetIds(userId: Auth.auth().currentUser?.uid ?? "")
                await MainActor.run{
                    if !bouquets.isEmpty{
                        let filtered = bouquets.filter {
                            likedIds.contains($0.id ?? 0)
                        }
                        bouquetLoadingState = .loaded(filtered)
                    }
                }
            }catch let error{
                await MainActor.run{
                    bouquetLoadingState = .error
                    print(error)
                }
            }
        }
    }
    func getAllBouquetList(){
        bouquetLoadingState = .loaded(bouquets)
    }
    
    func navigateToAddBouquetScreen(bouquetEntity: BouquetDetailsEntity?){
        router.navigateToAddNewBouquetScreen(bouquetEntity: bouquetEntity, refreshDelegate: self, identifier: "bouquet")
    }
    
    func navigateToBouquetDetailsScreen(bouquetEntity: BouquetDetailsEntity){
        router.navigateToBouquetDetailsScreen(bouquetEntity: bouquetEntity)
    }
}
