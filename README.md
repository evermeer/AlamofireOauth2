SwiftOAuth2
===========

#Description

A Swift implementation of Oath featuring 

- User authentication management via UIViewController
- Retrieval of access & refresh token
- Keychain storage for tokens

#Setup

CROAuth2Client relies on ([Alamofire](https://github.com/Alamofire/Alamofire)), from the excellent ([Mattt](https://github.com/mattt))

It is added as a submodule in this repository.

To use correctly CROAuth2Client, please add it as a submodule :

```
git subomdule init 
git submodule add git@github.com:crousselle/SwiftOAuth2.git 
// --recursive to get Alamofire
git submodule update —recursive
```
Please follow instructions at https://github.com/Alamofire/Alamofire to setup Alamofire in your project.

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

#Creator 
Clément Rousselle ([@clemrousselle](https://twitter.com/clemrousselle))

