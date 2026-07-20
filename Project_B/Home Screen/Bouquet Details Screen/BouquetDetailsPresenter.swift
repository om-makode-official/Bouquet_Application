//
//  BouquetDetailsPresenter.swift
//  Project_B
//
//  Created by Om on 6/19/26.
//

import Foundation
import UIKit
import FirebaseAuth

class BouquetDetailsPresenter: ObservableObject {

    @Published var entity: BouquetDetailsEntity
    @Published var selectedImageIndex = 0
    @Published var openSheet: Bool = false
    @Published var selectedIndex: Int?
    
    @Published var rating: Int = 0
    @Published var feedback: String = ""
    @Published var showFeedbackArea: Bool = false
    @Published var showPostFeedbackButton: Bool = false
    @Published var feedbackResponse: HallRatingResponse?
    @Published var userId: String?
    @Published var viewCount: HallViewResponse?
    @Published var isLiked: Bool = false

    let router: BouquetDetailsRouter
    let interactor: BouquetDetailsInteractor

    init(entity: BouquetDetailsEntity, router: BouquetDetailsRouter,interactor: BouquetDetailsInteractor) {
        self.entity = entity
        self.router = router
        self.interactor = interactor
        
        
        self.userId = Auth.auth().currentUser?.uid
        fetchLikeStatus()
        postViewCountStatus()
        getViewCount()
        getAllFeedbacks()
    }

    var galleryImages: [String] {
        entity.galleryImages ?? []
    }

    var selectedImage: String {

        if selectedImageIndex == 0 {
            return entity.mainScreenImage ?? ""
        }

        let galleryIndex = selectedImageIndex - 1

        if galleryImages.indices.contains(galleryIndex) {
            return galleryImages[galleryIndex]
        }

        return entity.mainScreenImage ?? ""
    }

    var previewImages: [String] {

        var images = [entity.mainScreenImage ?? ""]

        images.append(contentsOf: galleryImages.prefix(4))

        return images
    }
    var firstFiveImages: [String]{
        if galleryImages.count > 5{
            return Array(galleryImages.prefix(5))
        }else{
            return []
        }
    }
    func onTapCallButton(number: String){
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
    func postFeedback(){
        Task{
            do{
                let response = try await interactor.postFeedback(bouquetId: entity.id ?? 0, userId: userId ?? "", rating: self.rating, feedback: self.feedback)
                
                await MainActor.run{
                    self.getAllFeedbacks()
                }
                print(" feedback posted: ", response)
            }catch let error{
                print("post feedback error : ",error.localizedDescription)
            }
        }
    }
    
    func getAllFeedbacks(){
        Task{
            do{
                let response = try await interactor.getFeedback(bouquetId: entity.id ?? 0)
                await MainActor.run{
                    self.feedbackResponse = response
                    if let feedback = response.getCurrentUserFeedback(userId: userId ?? ""){
                        self.rating = feedback.rating
                        self.feedback = feedback.feedback
                    }
                    
                    print("get feedback response: ======", response)
                }
            }catch let error{
                print("get feedback error: ", error.localizedDescription)
            }
        }
    }
    func postViewCountStatus() {
        
        
        Task {
            do {
                let response = try await interactor.postViewCount(bouquetId: entity.id ?? 0, userId: userId ?? "")
                print("view count updated: ", response)
                
                if response {
                    self.getViewCount()
                }
            } catch let error {
                print("postViewCountStatus Error: ", error.localizedDescription)
            }
        }
    }
    func getViewCount(){
        Task{
            do{
                let response = try await interactor.getViewCount(bouquetId: entity.id ?? 0)
                await MainActor.run{
                    self.viewCount = response
                    print("totalViews %%%%%%%%%%%",response.totalViews)
                    print("uniqueUsers %%%%%%%%%%%",response.uniqueUsers)
//                    print("lastViewedAt %%%%%%%%%%%",response.viewTimestamps)
                }
            }catch let error{
                print("getViewCount", error.localizedDescription)
            }
        }
    }
    func fetchLikeStatus(){
        Task{
            do{
                let likedStatus = try await interactor.fetchLikeStatus(bouquetId: entity.id ?? 0, userId: userId ?? "")
                
                await MainActor.run {
                    self.isLiked = likedStatus
                }
            }catch let error{
                await MainActor.run{
                    
                }
                
                print(" fetchLikeStatus error",error.localizedDescription)
            }
        }
    }
    func handleLikeButtonTapped(bouquetId: Int, currentLikeState: Bool) {
        
        Task {
            do {
                let success = try await interactor.toggleLike(
                    bouquetId: bouquetId,
                    userId: userId ?? "",
                    isLiked: currentLikeState
                )
                
                if success {
                    await MainActor.run {
                        
                        print("Successfully updated like status to: \(currentLikeState)")
                    }
                }
            } catch {
                print("Failed to toggle like status: \(error.localizedDescription)")
            }
        }
    }

    func navigateToListScreen() {
        router.navigateToListScreen()
    }
}

