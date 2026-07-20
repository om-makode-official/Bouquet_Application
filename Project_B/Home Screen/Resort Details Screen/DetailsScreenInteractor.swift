//
//  DetailsScreenInteractor.swift
//  Project_B
//
//  Created by Om on 6/1/26.
//

import Foundation

class DetailsScreenInteractor{
    
    private let baseURLString = StringConstants.shared.baseUrl
    
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case serverError(statusCode: Int)
        case noData
    }
    
    init(){}
    
    func toggleLike(hallId: Int, userId: String, isLiked: Bool) async throws -> Bool {
        let urlString = "\(baseURLString)/\(hallId)/like"
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
    
    func fetchLikeStatus(hallId: Int, userId: String) async throws -> Bool {
        let urlString = "\(baseURLString)/\(hallId)/like/status"
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
    
    
    // MARK: - READ (Fetch Bookings)
    func fetchBookings(forHallId hallId: Int?) async throws -> [Booking] {
        guard let id = hallId else { return [] }
        
        guard let url = URL(string: "\(baseURLString)/\(id)/bookings") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        try validateResponse(response)
        
        return try JSONDecoder().decode([Booking].self, from: data)
    }
    
    func postViewCount(hallId: Int, userId: String) async throws -> Bool {
        let urlString = "\(baseURLString)/\(hallId)/view"

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
    
    func getViewCount(hallId: Int) async throws -> HallViewResponse {

        let urlString = "\(baseURLString)/\(hallId)/views"

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

        return try JSONDecoder().decode(
            HallViewResponse.self,
            from: data
        )
    }
    
    func postFeedback(hallId: Int, userId: String, rating: Int, feedback: String) async throws -> Bool{
        let urlString = "\(baseURLString)/\(hallId)/rating"
        
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
    
    func getFeedback(hallId: Int) async throws -> HallRatingResponse{
        let urlString = "\(baseURLString)/\(hallId)/rating"

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
    
    // MARK: - Helper Response Validation
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
