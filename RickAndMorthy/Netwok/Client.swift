//
//  Client.swift
//  RickAndMortySwiftUI
//
//  Created by Diplomado on 02/12/23.
//

import Foundation

struct Client {
    
    let session = URLSession.shared
    let baseURL: String
    private let contentType: String
    
    init(baseURL: String, contentType: String) {
        self.baseURL = baseURL
        self.contentType = contentType
    }
    
    enum NetworkError {
        case Connection, Invalid, Client, Server
    }
    
    func request(method: String, path: String, query: [String: String], body: Data?, success: ((Data?) -> Void)?, failure: ((NetworkError) -> Void)? = nil) {
        guard let request = buildRequest(method: method, path: path, query: query, body: body) else {
            failure?(NetworkError.Invalid)
            return
        }
        let task = session.dataTask(with: request) { data, response, error in
            if let _ = error, let fail = failure {
                fail(NetworkError.Connection)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                failure?(NetworkError.Invalid)
                return
            }
            let status = StatusCode(rawValue: httpResponse.statusCode)
            switch status {
            case .success:
                success?(data)
            case .clientError:
                failure?(NetworkError.Client)
            case .serverError:
                failure?(NetworkError.Server)
            default:
                failure?(NetworkError.Invalid)
            }
        }
        task.resume()
    }
    
    private func buildRequest(method: String, path: String, query: [String: String], body: Data?) -> URLRequest? {
        var urlComponent = URLComponents(string: baseURL)!
        urlComponent.path = path
        urlComponent.queryItems = query.map { URLQueryItem(name: $0, value: $1) }
        guard let url = urlComponent.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.addValue(self.contentType, forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func get(_ path: String, query: [String: String], success: ((Data?) -> Void)?, failure: ((NetworkError) -> Void)? = nil) {
        request(method: "GET", path: path, query: query, body: nil, success: success, failure: failure)
    }
    
}
