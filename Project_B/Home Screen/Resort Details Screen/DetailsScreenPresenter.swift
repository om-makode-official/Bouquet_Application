//
//  DetailsScreenPresenter.swift
//  Project_B
//
//  Created by Om on 5/27/26.
//

import Foundation
import UIKit
import FirebaseAuth
import MapKit

class DetailsScreenPresenter: ObservableObject, RefreshBookingStatusDelegateProtocol{
    @Published var openSheet: Bool = false
    @Published var selectedIndex: Int?
    @Published var isLiked: Bool = false
    @Published var bookedDates: [(Int?, Double?, Double?)]?
    
//    @Published var loadingState: DetailsScreenLoadingState = .idle
    @Published var rating: Int = 0
    @Published var feedback: String = ""
    @Published var showFeedbackArea: Bool = false
    @Published var showPostFeedbackButton: Bool = false
    
    @Published var viewCount: HallViewResponse?
    @Published var refetchBooking: Bool = false
    @Published var isCalendarLoadingCompleted: Bool = false
    @Published var feedbackResponse: HallRatingResponse?
    @Published var userId: String?
    
    @Published var galleryImages: [String] = []
    @Published var firstFiveImages: [String] = []
//    @Published var isAdmin: Bool = false
    
    let entity: HallResponseModel
    
    let interactor: DetailsScreenInteractor
    let router: DetailsScreenRouterProtocol
    
    init(entity: HallResponseModel, interactor: DetailsScreenInteractor, router: DetailsScreenRouterProtocol) {
        self.entity = entity
        self.interactor = interactor
        self.router = router
        
        initialLoad()
        self.userId = Auth.auth().currentUser?.uid
        
    }
    func initialLoad(){
        fetchBookings()
        fetchLikeStatus()
        postViewCountStatus()
        getViewCount()
        
        getAllFeedbacks()
        getImageGallery()
    }
    
    func fetchBookings(){
        Task{
            do{
                let response = try await interactor.fetchBookings(forHallId: entity.id)
                await MainActor.run {
                    self.bookedDates = response.map { ($0.id ,$0.startDateMs, $0.endDateMs)}
                    self.isCalendarLoadingCompleted = true
                }
                print("bookings: ========",response)
            }catch let error{
                await MainActor.run{
                    self.refetchBooking = true
                }
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchLikeStatus(){
        let userId = Auth.auth().currentUser?.uid ?? ""
        Task{
            do{
                let likedStatus = try await interactor.fetchLikeStatus(hallId: entity.id ?? 0, userId: userId)
                
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
    
    func postViewCountStatus() {
        
        let userId = Auth.auth().currentUser?.uid ?? ""
        
        Task {
            do {
                let response = try await interactor.postViewCount(hallId: entity.id ?? 0, userId: userId)
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
                let response = try await interactor.getViewCount(hallId: entity.id ?? 0)
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
    
    func onTapCallButton(number: String){
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
    
    func getImageGallery(){
        guard let urls = entity.galleryImagePaths else{ return }
        
        var urlArray = [String]()
        for url in urls{
            urlArray.append(url)
        }
        self.galleryImages = urlArray
        
        if urlArray.count > 5{
            for index in 1...5{
                firstFiveImages.append(urlArray[index])
            }
        }
        
    }
    
    func handleLikeButtonTapped(hallId: Int, currentLikeState: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                let success = try await interactor.toggleLike(
                    hallId: hallId,
                    userId: userId,
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
    
    func postFeedback(){
        guard let userId = Auth.auth().currentUser?.uid else {return}
        Task{
            do{
                let response = try await interactor.postFeedback(hallId: entity.id ?? 0, userId: userId, rating: self.rating, feedback: self.feedback)
                
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
                let response = try await interactor.getFeedback(hallId: entity.id ?? 0)
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
    
    
    func navigateToAddNewBookingScreen(bookingId: Int?, startDate: Date?, endDate: Date?){
        router.navigateToAddNewBookingScreen(hallId: entity.id ?? 0, refreshDelegate: self, bookingId: bookingId, startDate: startDate, endDate: endDate)
    }
    
    func navigateBack(){
        self.router.navigateBack()
    }
}
