
import Foundation

public class Oauth2Settings {
    var baseURL: String
    var authorizeURL: String
    var tokenURL: String
    var redirectURL: String
    var clientID: String
    var clientSecret: String
    var scope: String
    
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
