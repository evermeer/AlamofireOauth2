
import Foundation

public class Oauth2Settings {
    public var baseURL: String
    public var authorizeURL: String
    public var tokenURL: String
    public var redirectURL: String
    public var clientID: String
    public var clientSecret: String
    public var scope: String
    
    public init(baseURL: String, authorizeURL: String, tokenURL: String, redirectURL: String, clientID: String, clientSecret: String, scope: String = "") {
        self.baseURL = baseURL
        self.authorizeURL = authorizeURL
        self.tokenURL = tokenURL
        self.redirectURL = redirectURL
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.scope = scope
    }
}
