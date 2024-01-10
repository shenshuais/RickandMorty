//
//  RESTClient.swift
//  RickAndMortySwiftUI
//
//  Created by Diplomado on 02/12/23.
//

import Foundation

struct RESTClient<T: Codable> {
    
    let client: Client
    let decoder: JSONDecoder = {
       var decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    init(client: Client) {
        self.client = client
    }
    
    func show(_ path: String, query: [String: String], success: @escaping ((T) -> Void)) {
        client.get(path, query: query) { data in
            guard let data = data else { return }
            do {
                let json = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async { success(json) }
            } catch {
                return
            }
        }
    }
    
}
