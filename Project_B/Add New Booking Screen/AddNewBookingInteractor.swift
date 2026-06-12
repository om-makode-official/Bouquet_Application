//
//  AddNewBookingInteractor.swift
//  Project_B
//
//  Created by Sai Krishna on 6/6/26.
//

import Foundation

protocol AddNewBookingInteractorProtocol{
    func createBooking(forHallId hallId: Int, booking: Booking) async throws -> Booking
    func updateBooking(forHallId hallId: Int, bookingId: Int, booking: Booking) async throws -> Booking
    func deleteBooking(forHallId hallId: Int, bookingId: Int) async throws -> Bool
}

class AddNewBookingInteractor: AddNewBookingInteractorProtocol{
    
    private let baseURLString = StringConstants.shared.baseUrl
    
    enum NetworkError: Error {
            case invalidURL
            case invalidResponse
            case serverError(statusCode: Int)
            case noData
        }
    
    init(){}
    // MARK: - CREATE (Post New Booking)
    func createBooking(forHallId hallId: Int, booking: Booking) async throws -> Booking {
        
        guard let url = URL(string: "\(baseURLString)/\(hallId)/bookings") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(booking)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        
        return try JSONDecoder().decode(Booking.self, from: data)
    }
    
    // MARK: - UPDATE (Put Booking Changes)
    func updateBooking(forHallId hallId: Int, bookingId: Int, booking: Booking) async throws -> Booking {
        guard let url = URL(string: "\(baseURLString)/\(hallId)/bookings/\(bookingId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(booking)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validateResponse(response)
        
        return try JSONDecoder().decode(Booking.self, from: data)
    }
    
    // MARK: - DELETE (Drop Booking Assignment)
    func deleteBooking(forHallId hallId: Int, bookingId: Int) async throws -> Bool {
        guard let url = URL(string: "\(baseURLString)/\(hallId)/bookings/\(bookingId)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        return true
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
