//
//  BitlyApi.swift
//  Bitly
//
//  Created by Roberto Mauro on 21/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Foundation

public class BitlyApi: IBitlyApi {
    static var shared: BitlyApi = BitlyApi()
    
    var apiEndpoint = URL(string: "https://api-ssl.bitly.com/v4/shorten")!
    var userDefaults: UserDefaultsService!
    var notificationService: INotificationService!
    var apiKey = "";
    
    private let urlSession = URLSession.shared
    private let jsonDecoder: JSONDecoder = {
       let jsonDecoder = JSONDecoder()
       jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "yyyy-mm-dd"
       jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
       return jsonDecoder
    }()
    
    init(userDefaults: UserDefaultsService = UserDefaultsService(), notificationService: INotificationService = NotificationService()) {
        self.userDefaults = userDefaults
        self.notificationService = notificationService
        self.apiKey = userDefaults.apiKey 
        
        notificationService.addObserver(self, selector: #selector(apiKeyChanged(_:)), name: .apiKeyChanged)
    }
    
    @objc func apiKeyChanged(_ aNotification: Notification) {
        apiKey = aNotification.userInfo?["apiKey"] as! String
    }
    
    /**
     Shorten a long URL using bit.ly API
     
     - Parameter url: The long url to be shortened
     - Parameter successHandler: A closure that handle a successful url shortening
     - Parameter errorHandler: A closure that manages errors
     */
    func shorten(url: String, result: @escaping (Result<BitlyShortLink, BitlyApiError>) -> Void) {
        
        let parameters: [String: Any] = [
            "domain": "bit.ly",
            "long_url": url
        ]
    
        postRequest(parameters: parameters, completion: result)
    }
    
    private func postRequest<T: Decodable>(parameters: [String: Any], completion: @escaping (Result<T, BitlyApiError>) -> Void) {
        let urlRequest = request(with: parameters)
        urlSession.dataTask(with: urlRequest) { result in
            switch result {
            case .success(let (response, data)):
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<499 ~= statusCode else {
                    completion(.failure(BitlyApiError.serverError))
                    return
                }
                
                do {
                    if (statusCode > 299) {
                        let errorResponse = try self.jsonDecoder.decode(BitlyErrorResponse.self, from: data)
                        print("[statusCode: \(statusCode)] \(errorResponse)")
                        switch errorResponse.message {
                        case BitlyMessage.forbidden:
                            completion(.failure(BitlyApiError.forbidden))
                            return
                        case BitlyMessage.invalidLongURL:
                            completion(.failure(BitlyApiError.invalidArgument))
                            return
                        default:
                            completion(.failure(BitlyApiError.apiError))
                            return
                        }
                    }
                    
                    let values = try self.jsonDecoder.decode(T.self, from: data)
                    completion(.success(values))
                } catch {
                    completion(.failure(.decodeError))
                }

                break
            case .failure(_ ):
                completion(.failure(.apiError))
            }
        }.resume()
    }
    
    private func request(with parameters: [String: Any]) -> URLRequest {
        var request = URLRequest(url: apiEndpoint)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = jsonToData(json: parameters)
        
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

// MARK: Structs and Enums

struct BitlyShortLink: Decodable {
    var longUrl: String
    var link: String
}

struct BitlyMessage {
    static let forbidden = "FORBIDDEN"
    static let invalidLongURL = "INVALID_ARG_LONG_URL"
}

struct BitlyErrorResponse: Decodable {
    var message: String
    var description: String?
}

enum BitlyApiError: Error {
    case apiError
    case invalidEndpoint
    case serverError
    case forbidden
    case invalidArgument
    case noData
    case decodeError
}

// MARK: Protocols

protocol IBitlyApi {
    var apiKey: String { get set }
    func shorten(url: String, result: @escaping (Result<BitlyShortLink, BitlyApiError>) -> Void)
}

// MARK: Extensions

extension Notification.Name {
    static let apiKeyChanged = Notification.Name("apiKeyChanged")
}

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
