//
//  ProfileScreenInteractor.swift
//  Project_B
//
//  Created by Om on 6/4/26.
//

import Foundation

protocol ProfileScreenInteractorProtocol: AnyObject {
    func fetchUser(uid: String) async throws -> UserDTO
    func updateUser(user: UserDTO) async throws -> UserDTO
//    func deleteUser(uid: String) async throws
}

class ProfileScreenInteractor: ProfileScreenInteractorProtocol {

    private let baseURLString = StringConstants.shared.usersBaseUrl

    func fetchUser(uid: String) async throws -> UserDTO {

        guard let url = URL(string: "\(baseURLString)/\(uid)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(UserDTO.self, from: data)
    }

    func updateUser(user: UserDTO) async throws -> UserDTO {
        guard let url = URL(string: "\(baseURLString)/update") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(user)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(UserDTO.self, from: data)
    }

//    func deleteUser(uid: String) async throws {
//
//        guard let url = URL(string: "\(baseURLString)/\(uid)") else {
//            throw URLError(.badURL)
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//
//        let (_, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse,
//              (200...299).contains(httpResponse.statusCode) else {
//            throw URLError(.badServerResponse)
//        }
//    }
}
