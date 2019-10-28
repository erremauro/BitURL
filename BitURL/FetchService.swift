//
//  FetchService.swift
//  BitURL
//
//  Created by Roberto Mauro on 27/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Foundation

enum FetchMethod: String {
    case get = "GET"
    case post = "POST"
    case update = "UPDATE"
    case delete = "DELETE"
}

struct FetchOptions {
    var url: String
    var method: FetchMethod = .get
    var headers: [String: String] = [:]
    var parameters: [String: Any] = [:]
}

enum FetchError: Error {
    case invalidUrlFormat
    case responseEncoding
    case responseDecoding
    case serverError
    case fetchError
}

typealias JSONResponse = Dictionary<String,Any>

protocol IFetchService {
    func fetch(options: FetchOptions, completion: @escaping (Result<(HTTPURLResponse, JSONResponse), FetchError>) -> Void)
}

class FetchService: IFetchService {
    static let shared: FetchService = FetchService()
    private let urlSession = URLSession.shared

    func fetch(options: FetchOptions, completion: @escaping (Result<(HTTPURLResponse, JSONResponse), FetchError>) -> Void) {
        guard let request = try? createRequest(options: options) else {
            completion(.failure(.invalidUrlFormat))
            return
        }
        
        urlSession.dataTask(with: request) { (result: Result<(URLResponse, Data), Error>) -> Void in
                switch result {
                case .success(let (response, data)):
                    guard let status = response as? HTTPURLResponse else {
                        completion(.failure(.responseDecoding))
                        return
                    }
                    
                    if (status.statusCode > 499) {
                        completion(.failure(.serverError))
                        return
                    }
                    
                    guard let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                        completion(.failure(.responseEncoding))
                        return
                    }
                    
                    completion(.success((status, response)))
                    break
                case .failure(_ ):
                    completion(.failure(.fetchError))
                }
        }.resume()
    }
    
    private func createRequest(options: FetchOptions) throws -> URLRequest? {
        guard var urlComponents = URLComponents(string: options.url) else {
            throw FetchError.invalidUrlFormat
        }
        
        // if this is a GET request, convert parameters to URL's query items
        if (options.method == .get && options.parameters.count > 0) {
            for param in options.parameters {
                urlComponents.queryItems?.append(URLQueryItem(name: param.key, value: param.value as? String))
            }
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = options.method.rawValue
        
        // convert parameters to json when method is not GET
        if (options.method != .get) {
            request.httpBody = jsonToData(json: options.parameters)
        }
        
        // Default Content-Type to application/json
        if (options.parameters["Content-Type"] == nil) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        for header in options.headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        return request
    }
    
    private func jsonToData(json: Any) -> Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return data
        } catch {
            return nil
        }
    }
}

// MARK: Extensions

extension URLSession {
    func dataTask(with request: URLRequest, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: request) { data, response, error in
            if let error = error {
                result(.failure(error))
                return
            }
            
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            
            result(.success((response, data)))
        }
    }
}
