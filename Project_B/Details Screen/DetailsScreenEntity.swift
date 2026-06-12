//
//  DetailsScreenEntity.swift
//  Project_B
//
//  Created by Sai Krishna on 6/5/26.
//

import Foundation

protocol RefreshBookingStatusDelegateProtocol{
    func initialLoad()
}

enum DetailsScreenLoadingState{
    case idle
    case loading
    case loaded
    case error
}


struct Booking: Codable, Identifiable {
    var id: Int?
    var hallId: Int?
    var startDateMs: Double?
    var endDateMs: Double?
}

struct HallViewResponse: Codable {
    let totalViews: Int
    let uniqueUsers: Int
    let viewTimestamps: [String]
    
    func getViewsCount() -> String{
        return totalViews == 1 ? "\(totalViews) view" : "\(totalViews) views"
    }
}
struct HallRatingRequest: Codable {
    let rating: Int
    let feedback: String
    let userName: String
}

struct HallRatingResponse: Codable {
    let averageRating: Double
    let totalRatings: Int
    let feedbacks: [FeedbackResponse]
    
    func getTotalRatings() -> String{
        return totalRatings == 1 ? "\(totalRatings) rating" : "\(totalRatings) ratings"
    }
    
    func getAverageRating() -> Int{
        return Int(averageRating)
    }
    
    func getCurrentUserFeedback(userId: String) -> FeedbackResponse?{
        let feedback = feedbacks.filter { $0.userId == userId }
        return feedback.first
    }
    func getFeedbacksWithoutCurrentUser(userId: String) -> [FeedbackResponse]{
        let feedback = feedbacks.filter { $0.userId != userId }
        return feedback
    }
}

struct FeedbackResponse: Codable {
    let userId: String
    let userName: String
    let feedback: String
    let rating: Int
}
