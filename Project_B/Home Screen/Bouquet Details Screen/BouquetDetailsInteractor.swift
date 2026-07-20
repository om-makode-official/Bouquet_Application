//
//  BouquetDetailsInteractor.swift
//  Project_B
//
//  Created by Om on 6/25/26.
//

import Foundation

class BouquetDetailsInteractor{
    
    let bouquetBaseUrl = StringConstants.shared.bouquetBaseUrl
    
    func postFeedback(bouquetId: Int, userId: String, rating: Int, feedback: String) async throws -> Bool{
        
        let urlString = "\(bouquetBaseUrl)/\(bouquetId)/rating"
        
        guard var components = URLComponents(string: urlString) else {
            throw URLError(.badURL)
        }
        
        components.queryItems = [URLQueryItem(name: "userId", value: userId)]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        let requestBody = HallRatingRequest(
                rating: rating,
                feedback: feedback,
                userName: ""
            )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(requestBody)
        

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            let serverMessage = String(data: data, encoding: .utf8) ?? "No error message"
            print(" POST FAILED - Status: \(httpResponse.statusCode)")
            print(" Backend says: \(serverMessage)")
            return false
        }

        return true
    }
    
    func getFeedback(bouquetId: Int) async throws -> HallRatingResponse{
        let urlString = "\(bouquetBaseUrl)/\(bouquetId)/rating"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let jsonString = String(data: data, encoding: .utf8) {
                    print("getFeedback RAW JSON from server: \(jsonString)")
                }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(HallRatingResponse.self,from: data)
    }
    func postViewCount(bouquetId: Int, userId: String) async throws -> Bool {
        let urlString = "\(bouquetBaseUrl)/\(bouquetId)/view"

        guard var components = URLComponents(string: urlString) else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(name: "userId", value: userId)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            let serverMessage = String(data: data, encoding: .utf8) ?? "No error message"
            print(" POST FAILED - Status: \(httpResponse.statusCode)")
            print(" Backend says: \(serverMessage)")
            return false
        }

        return true
    }
    
    func getViewCount(bouquetId: Int) async throws -> HallViewResponse {

        let urlString = "\(bouquetBaseUrl)/\(bouquetId)/views"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let jsonString = String(data: data, encoding: .utf8) {
                    print("RAW JSON from server: \(jsonString)")
                }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let res = try JSONDecoder().decode(
            HallViewResponse.self,
            from: data)

        return try JSONDecoder().decode(
            HallViewResponse.self,
            from: data
        )
    }
    func toggleLike(bouquetId: Int, userId: String, isLiked: Bool) async throws -> Bool {
        let urlString = "\(bouquetBaseUrl)/\(bouquetId)/like"
        guard var components = URLComponents(string: urlString) else { return false }
        
        components.queryItems = [
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "isLiked", value: String(isLiked))
        ]
        
        guard let url = components.url else { return false }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else { return false }
        
        return (200...299).contains(httpResponse.statusCode)
    }
    
    func fetchLikeStatus(bouquetId: Int, userId: String) async throws -> Bool {
        let urlString = "\(bouquetBaseUrl)/\(bouquetId)/like/status"
        guard var components = URLComponents(string: urlString) else { return false }
        
        components.queryItems = [
            URLQueryItem(name: "userId", value: userId)
        ]
        
        guard let url = components.url else { return false }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }
        
        if let statusString = String(data: data, encoding: .utf8),
           let isLiked = Bool(statusString.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return isLiked
        }
        
        return false
    }
}
