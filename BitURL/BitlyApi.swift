//
//  BitlyApi.swift
//  BitURL
//
//  Created by Roberto Mauro on 21/10/2019.
//  Copyright © 2019 Roberto Mauro. All rights reserved.
//

import Foundation

public class BitlyApi: IBitlyApi {
    static var shared: BitlyApi = BitlyApi()
    
    var userDefaults: UserDefaultsService!
    var notificationService: INotificationService!
    var apiEndpoint = "https://api-ssl.bitly.com/v4"
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
        
        // listen for apiKeyChanged events
        notificationService.addObserver(self, selector: #selector(apiKeyChanged(_:)), name: .apiKeyChanged)
    }
    
    /**
     Update the apiKey when the apiKeyChanged event is fired
     
     - Parameter aNotification: The event notification
     */
    @objc func apiKeyChanged(_ aNotification: Notification) {
        apiKey = aNotification.userInfo?["apiKey"] as! String
    }
    
    /**
     Shorten a long URL
     
     - Parameter url: The long url to be shortened
     - Parameter result: A closure to handle Result
     - Returns: `Void`
     */
    func shorten(url: String, result: @escaping (Result<BitlyShortLink, BitlyApiError>) -> Void) {
        let parameters: [String: Any] = [
            "domain": "bit.ly",
            "long_url": url
        ]
    
        request(FetchMethod.post, action: "shorten", parameters: parameters, completion: result)
    }
    
    /**
     Check if the current user is authorized based on the api key value.
     
     Since all API transactions require a valid API key, the authorization is verified by fetching the current authenticated user.
     If an invalid API Key was defined, the Result's success response will have a False value.
     
     - Parameter result: A closure that handle `Result` response.
     - Returns: `Void`
     */
    func isAuthorized(result: @escaping (Result<Bool, BitlyApiError>) -> Void) {
        self.user() { completion in
            switch completion {
            case .success( _):
                result(.success(true))
                return
            case .failure( _):
                result(.success(false))
                return
            }
        }
    }
    
    /**
     Get the current authenticated user
     
     - Parameter result: A closure to handle ` Result` response
     - Returns: `Void`
     */
    func user(result: @escaping (Result<BitlyUser, BitlyApiError>) -> Void) {
        request(FetchMethod.get, action: "user", parameters: [:], completion: result)
    }
    
    private func request<T: Decodable>(_ method: FetchMethod, action: String, parameters: [String: Any]? = [:], completion: @escaping (Result<T, BitlyApiError>) -> Void) {
        let url = apiEndpoint + "/" + action
        let options = FetchOptions(url: url, method: method, headers: ["Authorization": "Bearer " + self.apiKey], parameters: parameters!)
        
        FetchService.shared.fetch(options: options) { (result: Result<(HTTPURLResponse, JSONResponse),FetchError>) -> Void in
            switch result {
            case .success(let status, let response):
                guard let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted) else {
                    completion(.failure(.decodeError))
                    return
                }
                
                if (status.statusCode > 299) {
                    guard let errorResponse = try? self.jsonDecoder.decode(BitlyErrorResponse.self, from: data) else {
                        completion(.failure(.decodeError))
                        return
                    }

                    switch errorResponse.message {
                    case BitlyMessage.forbidden:
                        completion(.failure(.forbidden))
                        return
                    case BitlyMessage.invalidLongURL:
                        completion(.failure(.invalidArgument))
                        return
                    default:
                        completion(.failure(.apiError))
                        return
                    }
                }
                
                guard let values = try? self.jsonDecoder.decode(T.self, from: data) else {
                    completion(.failure(.decodeError))
                    return
                }
                completion(.success(values))
                break
            case .failure(let error):
                switch error {
                case .serverError:
                    completion(.failure(.serverError))
                    return
                case .responseDecoding:
                    completion(.failure(.decodeError))
                    return
                case .responseEncoding:
                    completion(.failure(.encodeError))
                default:
                    completion(.failure(.apiError))
                }
                break
            }
        }
    }
}

// MARK: Structs and Enums

struct BitlyShortLink: Decodable {
    var longUrl: String
    var link: String
}

struct BitlyUser: Decodable {
    var name: String
    var isActive: Bool
    var login: String
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
    case encodeError
}

// MARK: Protocols

protocol IBitlyApi {
    var apiKey: String { get set }
    func isAuthorized(result: @escaping (Result<Bool, BitlyApiError>) -> Void)
    func user(result: @escaping (Result<BitlyUser, BitlyApiError>) -> Void)
    func shorten(url: String, result: @escaping (Result<BitlyShortLink, BitlyApiError>) -> Void)
}

// MARK: Extensions

extension Notification.Name {
    static let apiKeyChanged = Notification.Name("apiKeyChanged")
}


