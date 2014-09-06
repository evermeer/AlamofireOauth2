SwiftOAuth2
===========

#Description

A swift implementation of OAuth2 featuring 

- Authentication management via a provided UIViewController
- Tokens stored in Keychain
- Token Refresh handling

#Setup

CROAuth2Client relies on the Alamofire library, from the excellent Matt Thompson.
It is added as a submodule in this repository.

To use correctly CROAuth2Client, please add it as a submodule :

```
git subomdule init 
git submodule add git@github.com:crousselle/SwiftOAuth2.git 
// --recursive to get Alamofire
git submodule update —recursive
```


#Usage 

You first need to create a CROAuth2Client object via the following method :

```swift
// From a UIViewController (used to present the authentication webview if necessary)
CROAuth2Client.clientWithPresentingController(self)
```

Then simply  query the access token 

```swift
 self.client!.retrieveAuthToken({ (authToken) -> Void in
            
            if let optionnalAuthToken = authToken {
                println("Received access token " + optionnalAuthToken)
            }
            
        })
```
The client will automatically return a valid token from the authentication server, or the keychain.
