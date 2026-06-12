//
//  HomeScreenPresenter.swift
//  Project_B
//
//  Created by Sai Krishna on 5/28/26.
//

import Foundation
import MapKit
import FirebaseAuth

protocol RefreshDataProtocol{
    func fetchAllEntities()
}

class HomeScreenPresenter: ObservableObject, RefreshDataProtocol{
    
    @Published var loadingState: HomeScreenLoadingState = .idle
    @Published var alertType: HomeScreenAlertEnum?
    @Published var isLikedHallsListView: Bool = false
//    @Published var isAdmin: Bool = false
    @Published var hallsData: [HallResponseModel] = []
    @Published var filteredHallList: [HallResponseModel] = []
    
    let router: HomeScreenRouterProtocol
    let interactor: HomeScreenInteractor
 
    init(router: HomeScreenRouterProtocol, interactor: HomeScreenInteractor) {
        self.router = router
        self.interactor = interactor
        
        fetchAllEntities()
        checkRoleStatus()
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
        self.alertType = .action(title: "Delete", message: "Are you sure to delete this hall?", action: {
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
//                        self.filteredHallList = filtered
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
    func navigateToAddEntityScreen(entity: HallResponseModel?){
        router.navigateToAddNewEntityScreen(entity: entity, refreshDelegate: self)
    }
    func navigateToProfileScreen(){
        self.router.navigateToProfileScreen(refreshDelegate: self)
    }
}
