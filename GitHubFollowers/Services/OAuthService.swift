//
//  OAuthService.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 27/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

protocol OAuthRefreshMessage: OAuthTokenMessage
{
    var refreshToken: String { get }
}

internal struct OAuthRefreshMessageRequest: OAuthRefreshMessage, Codable
{
    /// OAuthToken
    
    internal var clientSecret: String
    internal var clientID: String
    internal var redirectURI: String
    internal var grantType: GrantType
    
    /// OAuthRefreshMessage
    
    internal var refreshToken: String
    
    internal init(token: String)
    {
        self.refreshToken = token
        
        self.clientSecret = "clientSecret"
        self.clientID = "clientID"
        self.redirectURI = "asdfasdf"
        self.grantType = .refreshToken
    }
    


    /**
    */
    private enum CodingKeys: String, CodingKey
    {
        case refreshToken = "code"
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case redirectURI = "redirect_uri"
        case grantType = "grant_type"
    }
}

internal struct OAuthTokenResponse: Codable
{
    ///
    internal let accessToken: String
    ///
    internal let tokenType: String
    ///
    internal let refreshToken: String
    ///
    internal let expiresIn: Int
    ///
    internal let scope: String
    ///
    internal let createdAt: Int

    /**
    */
    private enum CodingKeys: String, CodingKey
    {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case scope = "scope"
        case createdAt = "created_at"
    }

}

public struct TrendyShow: Codable
{
    public private(set) var watchers: Int
    public private(set) var show: Show

    /**
    */
    private enum CodingKeys: String, CodingKey
    {
        case watchers
        case show
    }
}

public struct PostTrakt: Codable
{
    /// Shows que vamos a actualizar
    public private(set) var shows: [Show]?

    /**
    */
    private enum CodingKeys: String, CodingKey
    {
        case shows
    }
}

public struct Identifiers: Codable
{
    public private(set) var trakt: Int
    public private(set) var slug: String
    public private(set) var tvdb: Int
    public private(set) var imdb: String
    public private(set) var tmdb: Int
    public private(set) var tvRage: Int?

    /**
    */
    private enum CodingKeys: String, CodingKey
    {
        case trakt
        case slug
        case tvdb
        case imdb
        case tmdb
        case tvRage = "tvrage"
    }
}

public struct Show: Codable
{
    public private(set) var title: String
    public private(set) var year: Int
    public private(set) var identifiers: Identifiers

    /**
    */
    private enum CodingKeys: String, CodingKey
    {
        case title
        case year
        case identifiers = "ids"
    }
}

internal protocol OAuthTokenMessage
{
    var clientSecret: String { get }
    var clientID: String { get }
    var redirectURI: String { get }
    var grantType: GrantType { get }
}

protocol OAuthCodeMessage: OAuthTokenMessage
{
    var code: String { get }
}

internal enum GrantType: String, Codable
{
    /// Using to obtain access token
    case authorizationCode = "authorization_code"
    /// Using for refresh
    case refreshToken = "refresh_token"
}

internal enum HttpResult
{
    /// La operacion ha terminado bien.
    /// Devolvemos el stream de datos reacuperados
    case success(data: Data, pagination: Pagination?)
    /// Algo ha salido mal.
    /// Devolvemos un mensaje con la descripcion del error
    /// y el codigo HTTP asociado
    case requestError(code: Int, message: String)
    /// Problemas de conexión con el servidor
    ///
    case connectionError
}

public enum TraktError: Int
{
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotFound = 405
    case conflict = 409
    case preconditionFailed = 412
    case unprocessibleEntity = 422
    case rateLimitExceeded = 429
    case serverError = 500
    case serverOverloaded = 503
    case serverUnavailable = 504
    case cloudflareUnknownError = 520
    case serverIsDown = 521
    case connectionTimedOut = 522

    /**
    */
    internal init(httpCode code: Int)
    {
        if let error = TraktError(rawValue: code)
        {
            self = error
        }
        else
        {
            self = TraktError.badRequest
        }
    }
}

public enum PaginationFilter
{
    case limit(resultCount: Int)

    case page(page: Int)
}

extension PaginationFilter: FilterValue
{
    ///
    public var queryItem: URLQueryItem
    {
        var key: String
        var value: String
        
        switch self
        {
            case .limit(let resultCount):
                key = "limit"
                value = "\(resultCount)"
            
            case .page(let page):
                key = "page"
                value = "\(page)"
        }

        return URLQueryItem(name: key, value: value)
    }
}

public struct Pagination
{
    /// Current page.
    public internal(set) var currentPage: Int
    /// Items per page.
    public internal(set) var itemsPageCount: Int
    /// Total number of pages.
    public internal(set) var pageCount: Int
    /// Total number of items.
    public internal(set) var itemsCount: Int

    /**
    */
    public func nextPage() -> [PaginationFilter]?
    {
        guard self.currentPage < self.pageCount else
        {
            return nil
        }
        
        let nextPage = self.currentPage + 1
        
        let filters = [
            PaginationFilter.limit(resultCount: self.itemsPageCount),
            PaginationFilter.page(page: nextPage)
        ]
        
        return filters
    }

    /**
    */
    public func previousPage() -> [PaginationFilter]?
    {
        guard self.currentPage > 1 else
        {
            return nil
        }
        
        let previousPage = self.currentPage - 1
        
        let filters = [
            PaginationFilter.limit(resultCount: self.itemsPageCount),
            PaginationFilter.page(page: previousPage)
        ]
        
        return filters
    }
}

public protocol FilterValue
{
    ///
    var queryItem: URLQueryItem { get }
}

public typealias TraktPaginatedCompletionHandler<T> = (_ results: [T]?, _ pagination: Pagination?, _ error: TraktError?) -> (Void)

public typealias TraktCompletionHandler<T> = (_ result: [T]?, _ error: TraktError?) -> (Void)

public typealias TraktPostCompletionHandler = (_ validOperation: Bool, _ error: TraktError?) -> (Void)

///
/// All API request will be *returned* here
///
internal typealias HttpRequestCompletionHandler = (_ result: HttpResult) -> (Void)

public class OAuthService
{
    ///
    public static let shared = OAuthService()

    internal let clientID: String
    internal let clientSecret: String
    internal let redirecURL: URL

    internal var accessToken: String?
    internal var refreshToken: String?

    internal let encoder: JSONEncoder
    internal let decoder: JSONDecoder
    
    /// HTTP session ...
    private var httpSession: URLSession!
    /// ...and his configuración
    private var httpConfiguration: URLSessionConfiguration!

    /**
    */
    private init()
    {
        self.clientID = "## TRAKT.TV CLIENT ID ##"
        self.clientSecret = "## TRAKT.TV CLIENT SECRET ##"
        self.redirecURL = URL(string: "acseries://oauth")!

        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = .prettyPrinted
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.httpConfiguration = URLSessionConfiguration.default
        self.httpConfiguration.httpMaximumConnectionsPerHost = 10
        
        let http_queue: OperationQueue = OperationQueue()
        http_queue.maxConcurrentOperationCount = 10
        
        self.httpSession = URLSession(configuration:self.httpConfiguration,
                                      delegate:nil,
                                      delegateQueue:http_queue)
    }


    internal func makeURLRequest(string uri: String, withFilters filters: [FilterValue]? = nil, paginationOptions pagination: [FilterValue]? = nil, authenticationRequired: Bool = false) -> URLRequest?
    {
        guard let url = URL(string: uri) else
        {
            return nil
        }

        var request: URLRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue(self.clientID, forHTTPHeaderField: "trakt-api-key")

        if let accessToken = self.accessToken, authenticationRequired
        {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
    
    /**
 
    */
    private func recoverPaginationData(fromResponse response: HTTPURLResponse) -> Pagination?
    {
        guard let currentPageHeader = response.allHeaderFields["x-pagination-page"] as? String,
              let itemsPerPageHeader = response.allHeaderFields["x-pagination-limit"] as? String,
              let totalPagesHeader = response.allHeaderFields["x-pagination-page-count"] as? String,
              let totalItemsHeader = response.allHeaderFields["x-pagination-item-count"] as? String
        else
        {
            return nil
        }
        
        guard let currentPage = Int(currentPageHeader),
              let itemsPerPage = Int(itemsPerPageHeader),
              let totalPages = Int(totalPagesHeader),
              let totalItems = Int(totalItemsHeader)
        else
        {
            return nil
        }
        
        return Pagination(currentPage: currentPage, itemsPageCount: itemsPerPage, pageCount: totalPages, itemsCount: totalItems)
    }

    /**
        URL request operation
        - Parameters:
            - request: `URLRequest` requested
            - completionHandler: HTTP operation result
    */
    internal func processRequest(_ request: URLRequest, httpHandler: @escaping HttpRequestCompletionHandler) -> Void
    {
        let data_task: URLSessionDataTask = self.httpSession.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error
            {
                #if targetEnvironment(simulator)
                    print(error.localizedDescription)
                #endif
                
                httpHandler(HttpResult.connectionError)
                return
            }

            guard let data = data, let http_response = response as? HTTPURLResponse else
            {
                httpHandler(HttpResult.connectionError)
                return
            }

            switch http_response.statusCode
            {
                case 200:
                    let pagination = self.recoverPaginationData(fromResponse: http_response)
                    httpHandler(HttpResult.success(data: data, pagination: pagination))
                
                case 201...204:
                    httpHandler(HttpResult.success(data: data, pagination: nil))
                
                default:
                    let code: Int = http_response.statusCode
                    let message: String = HTTPURLResponse.localizedString(forStatusCode: code)

                    httpHandler(HttpResult.requestError(code: code, message: message))
            }
        })

        data_task.resume()
    }
}

internal struct OAuthTokenRequest: Codable
{
    ///
    internal var code: String
    ///
    internal let clientID: String
    ///
    internal let clientSecret: String
    ///
    internal let redirectURI: String
    ///
    internal let grantType: String

    /**
    */
    public init(code: String)
    {
        self.code = code

        self.clientID = OAuthService.shared.clientID
        self.clientSecret = OAuthService.shared.clientSecret
        self.redirectURI = OAuthService.shared.redirecURL.absoluteString
        self.grantType = GrantType.authorizationCode.rawValue
    }

}


internal struct OAuthCodeMessageRequest: OAuthCodeMessage, Codable
{
    /// OAuthToken
    
    public private(set) var clientSecret: String
    public private(set) var clientID: String
    public private(set) var redirectURI: String
    public var grantType: GrantType
    
    /// OAuthExchangeCodeToken
    
    public private(set) var code: String
    
    internal init(code: String)
    {
        self.code = code
        
        self.clientSecret = OAuthService.shared.clientSecret
        self.clientID = OAuthService.shared.clientID
        self.redirectURI = OAuthService.shared.redirecURL.absoluteString
        self.grantType = .authorizationCode
    }

    /**
    */
    private enum CodingKeys: String, CodingKey
    {
        case code = "code"
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case redirectURI = "redirect_uri"
        case grantType = "grant_type"
    }
}

extension OAuthService
{
    /**
    */
    public func appendToWatchlist(_ show: Show, handler: @escaping TraktPostCompletionHandler) -> Void
    {
        let watchlistURL = "https://api.trakt.tv/sync/watchlist"

        guard var request = self.makeURLRequest(string: watchlistURL, authenticationRequired: true) else
        {
            return
        }

        let postData = PostTrakt(shows: [ show ])

        request.httpMethod = "POST"
        request.httpBody = try? self.encoder.encode(postData)

        self.processRequest(request) { (result: HttpResult) -> Void in
            switch result
            {
            case .success( _, _):
                    handler(true, nil)

                case .requestError(let code, let message):
                    print(message)
                    if let error = TraktError(rawValue: code)
                    {
                        handler(false, error)
                    }
                    else
                    {
                        handler(false, TraktError.badRequest)
                    }
                    
                case .connectionError:
                    handler(false, TraktError.serverIsDown)
            }
        }
    }
}

extension OAuthService
{
    /**
    */
    public func trendingShows(filteringBy filters: [FilterValue]? = nil, pagination: [FilterValue]? = nil, handler: @escaping TraktPaginatedCompletionHandler<TrendyShow>) -> Void
    {
        let trendingURL = "https://api.trakt.tv/shows/trending"

        guard let request = self.makeURLRequest(string: trendingURL, withFilters: filters, paginationOptions: pagination) else
        {
            handler(nil, nil, .preconditionFailed)
            return
        }

        self.processRequest(request) { (result: HttpResult) -> Void in
            switch result
            {
                case .success(let data, let pagination):
                    if let shows = try? self.decoder.decode([TrendyShow].self, from: data)
                    {
                        handler(shows, pagination, nil)
                    }
                case .requestError(let code, let message):
                    #if targetEnvironment(simulator)
                        print(message)
                    #endif

                    let error = TraktError(httpCode: code)
                    handler(nil, nil, error)

                case .connectionError:
                    handler(nil, nil, TraktError.serverIsDown)
            }
        }
    }

    /**
    */
    public func popularShows(filteringBy filters: [FilterValue]? = nil, pagination: [FilterValue]? = nil, handler: @escaping TraktPaginatedCompletionHandler<Show>) -> Void
    {
        let trendingURL = "https://api.trakt.tv/shows/popular"

        guard let request = self.makeURLRequest(string: trendingURL, withFilters: filters, paginationOptions: pagination) else
        {
            handler(nil, nil, .preconditionFailed)
            return
        }

        self.processRequest(request) { (result: HttpResult) -> Void in
            switch result
            {
            case .success(let data, let pagination):
                if let shows = try? self.decoder.decode([Show].self, from: data)
                {
                    handler(shows, pagination, nil)
                }
            case .requestError(let code, let message):
                #if targetEnvironment(simulator)
                    print(message)
                #endif
                
                let error = TraktError(httpCode: code)
                handler(nil, nil, error)

            case .connectionError:
                handler(nil, nil, TraktError.serverIsDown)
            }
        }
    }
}


public typealias TraktOAuthCompletionHandler = (_ authenticated: Bool, _ error: TraktError?) -> Void

//
// OAuth Operations
//
extension OAuthService
{
    /**
        Returns the *login for authorition* URL
        in order to gain access for your app
        You should open this URL in a `SFSafariViewController`
        and register a *Custom URL Scheme* in your `Info.plist`
        - Parameter clienteID: Your app clientID
        - Returns: The login URL in Trakt.TV
    */
    public func authorizationURL() -> URL?
    {
        var components = URLComponents(string: "https://api.trakt.tv/oauth/authorize")

        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: self.clientID),
            URLQueryItem(name: "redirect_uri", value: self.redirecURL.absoluteString),
            URLQueryItem(name: "state", value: " ")
        ]

        components?.queryItems = queryItems

        return components?.url
    }

    /**
    */
    public func exchange(code: String, handler: @escaping TraktOAuthCompletionHandler) -> Void
    {
        guard let exchangeURL = URL(string: "https://api.trakt.tv/oauth/token") else
        {
            return
        }

        let message = OAuthCodeMessageRequest(code: code)

        guard let bodyData = try? self.encoder.encode(message) else
        {
            return
        }

        var request = URLRequest(url: exchangeURL)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = bodyData

        self.processTokenRequest(request, handler: handler)
    }

    /**
    */
    public func exchange(refreshToken: String, handler: @escaping TraktOAuthCompletionHandler) -> Void
    {
        guard let exchangeURL = URL(string: "https://api.trakt.tv/oauth/token") else
        {
            return
        }

        let message = OAuthRefreshMessageRequest(token: refreshToken)

        guard let bodyData = try? self.encoder.encode(message) else
        {
            return
        }

        var request = URLRequest(url: exchangeURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = bodyData

        self.processTokenRequest(request, handler: handler)
    }

    /**
    */
    private func processTokenRequest(_ request: URLRequest, handler: @escaping TraktOAuthCompletionHandler) -> Void
    {
        self.processRequest(request) { (result: HttpResult) -> Void in
            switch result
            {
                case .success(let data, _):
                    if let tokenResponse = try? self.decoder.decode(OAuthTokenResponse.self, from: data)
                    {
                        self.accessToken = tokenResponse.accessToken
                        self.refreshToken = tokenResponse.refreshToken

                        handler(true, nil)
                    }
                    else
                    {
                        handler(false, TraktError.preconditionFailed)
                    }

                case .requestError(let code, let message):
                    #if targetEnvironment(simulator)
                        print(message)
                    #endif

                    let error = TraktError(httpCode: code)
                    handler(false, error)

                case .connectionError:
                    handler(false, TraktError.serverIsDown)
            }
        }
    }

    /**
    */
    public func revoke(accessToken: String) -> Void
    {
        guard let exchangeURL = URL(string: "https://api.trakt.tv/oauth/revoke") else
        {
            return
        }

        var request = URLRequest(url: exchangeURL)
        request.httpMethod = "POST"

        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer [access_token]", forHTTPHeaderField: "Authorization")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue("[client_id]", forHTTPHeaderField: "trakt-api-key")

        request.httpBody = "token=\(accessToken)".data(using: .utf8)

    }
}
