//
//  HomeScreenInteractor.swift
//  Project_B
//
//  Created by Om on 5/29/26.
//

import Foundation
import UIKit
import Alamofire

class HomeScreenInteractor {
    
    private let baseURLString = StringConstants.shared.baseUrl
    private let bouquetBaseURL = StringConstants.shared.bouquetBaseUrl
    
    init() {}
    
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case serverError(statusCode: Int)
        case noData
    }
    
    func fetchAllEntities() async throws -> [HallResponseModel]? {
        guard let url = URL(string: baseURLString) else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let response = try await URLSession.shared.data(for: urlRequest)
        guard let res = response.1 as? HTTPURLResponse else { return nil }
        if let jsonString =
            String(
                data: response.0,
                encoding: .utf8
            ) {
            
            print("JSON RESPONSE:")
            print(jsonString)
        }
        
        if res.statusCode == 200 {
            let data = try JSONDecoder().decode([HallResponseModel].self, from: response.0)
            print("Successfully fetched all entities count: \(data.count)")
            return data
        }
        print("Fetch All Failed Status:", res.statusCode)
        return nil
    }
    
    // MARK: - 3. DELETE
    func deleteEntity(id: Int) async throws -> Bool? {
        let urlString = "\(baseURLString)/\(id)"
        guard let url = URL(string: urlString) else { return false }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        let response = try await URLSession.shared.data(for: urlRequest)
        guard let res = response.1 as? HTTPURLResponse else { return false }
        
        if res.statusCode == 200{
            return true
        }
        return false
    }
    
    func fetchLikedHallIds(userId: String) async throws -> [Int] {
        
        let urlString =
        "\(baseURLString)/liked"
        
        guard var components =
                URLComponents(string: urlString)
        else {
            return []
        }
        
        components.queryItems = [
            URLQueryItem(
                name: "userId",
                value: userId
            )
        ]
        
        guard let url = components.url
        else {
            return []
        }
        
        let (data,response) =
        try await URLSession.shared.data(
            from: url
        )
        
        guard let httpResponse =
                response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            
            return []
        }
        
        return try JSONDecoder()
            .decode([Int].self, from: data)
    }
}


extension HomeScreenInteractor{
    
    
    func fetchAllBouquets() async throws -> [BouquetDetailsEntity] {
        guard let url = URL(string: "http://localhost:8081/api/bouquets") else { throw NetworkError.invalidURL }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let response = try await URLSession.shared.data(for: urlRequest)
        if let jsonString =
            String(
                data: response.0,
                encoding: .utf8
            ) {
            
            print("bouquet JSON RESPONSE:")
            print(jsonString)
        }
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        let data = try JSONDecoder().decode([BouquetDetailsEntity].self, from: response.0)
        print("Successfully fetched all entities count: \(data.count)")
        return data
        
    }
    func deleteBouquet(id: Int) async throws -> Bool?{
        let urlString = "\(bouquetBaseURL)/\(id)"
        guard let url = URL(string: urlString) else { return false }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        let response = try await URLSession.shared.data(for: urlRequest)
        //        guard let res = response.1 as? HTTPURLResponse else { return false }
        
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        return true
    }
    
    func fetchLikedBouquetIds(userId: String) async throws -> [Int] {
        
        let urlString =
        "\(bouquetBaseURL)/liked"
        
        guard var components =
                URLComponents(string: urlString)
        else {
            return []
        }
        
        components.queryItems = [
            URLQueryItem(
                name: "userId",
                value: userId
            )
        ]
        
        guard let url = components.url
        else {
            return []
        }
        
        let (data,response) =
        try await URLSession.shared.data(
            from: url
        )
        
        guard let httpResponse =
                response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            
            return []
        }
        
        return try JSONDecoder()
            .decode([Int].self, from: data)
    }
}
