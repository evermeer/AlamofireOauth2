#AlamofireOauth2

A Swift implementation of OAuth2 for iOS using Alamofire.

<!---
 [![Circle CI](https://img.shields.io/circleci/project/evermeer/AlamofireOauth2.svg?style=flat)](https://circleci.com/gh/evermeer/AlamofireOauth2)
 -->
[![Build Status](https://travis-ci.org/evermeer/AlamofireOauth2.svg?style=flat)](https://travis-ci.org/evermeer/AlamofireOauth2)
[![Issues](https://img.shields.io/github/issues-raw/evermeer/AlamofireOauth2.svg?style=flat)](https://github.com/evermeer/AlamofireOauth2/issues)
[![Stars](https://img.shields.io/github/stars/evermeer/AlamofireOauth2.svg?style=flat)](https://github.com/evermeer/AlamofireOauth2/stargazers)
[![Version](https://img.shields.io/cocoapods/v/AlamofireOauth2.svg?style=flat)](http://cocoadocs.org/docsets/EVReflection)
[![License](https://img.shields.io/cocoapods/l/AlamofireOauth2.svg?style=flat)](http://cocoadocs.org/docsets/AlamofireOauth2)
[![Platform](https://img.shields.io/cocoapods/p/AlamofireOauth2.svg?style=flat)](http://cocoadocs.org/docsets/AlamofireOauth2)

[![Git](https://img.shields.io/badge/GitHub-evermeer-blue.svg?style=flat)](https://github.com/evermeer)
[![Twitter](https://img.shields.io/badge/twitter-@evermeer-blue.svg?style=flat)](http://twitter.com/evermeer)
[![LinkedIn](https://img.shields.io/badge/linkedin-Edwin Vermeer-blue.svg?style=flat)](http://nl.linkedin.com/in/evermeer/en)
[![Website](https://img.shields.io/badge/website-evict.nl-blue.svg?style=flat)](http://evict.nl)
[![eMail](https://img.shields.io/badge/email-edwin@evict.nl-blue.svg?style=flat)](mailto:edwin@evict.nl?SUBJECT=About EVReflection)


#Intro

This is a fork of the [SwiftOAuth2 repository from crousselle](https://github.com/crousselle/SwiftOAuth2)

AlamofireOauth2 relies on [Alamofire](https://github.com/Alamofire/Alamofire), and [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess)


## Using AlamofireOauth2 in your own App 

'AlamofireOauth2' is now available through the dependency manager [CocoaPods](http://cocoapods.org). 
You do have to use cocoapods version 0.36. At this moment this can be installed by executing:

```
[sudo] gem install cocoapods
```

If you have installed cocoapods version 0.36 or later, then you can just add EVCloudKitDao to your workspace by adding the folowing 2 lines to your Podfile:

```
use_frameworks!
pod "AlamofireOauth2"
```

I have now moved on to Swift 2. If you want to use AlamofireOauth2, then get that version by using the podfile command:
```
use_frameworks!
pod "AlamofireOauth2", '~> 1.0'
```

Version 0.36 of cocoapods will make a dynamic framework of all the pods that you use. Because of that it's only supported in iOS 8.0 or later. When using a framework, you also have to add an import at the top of your swift file like this:

```
import AlamofireOauth2
```

If you want support for older versions than iOS 8.0, then you can also just copy the AlamofireOauth2 folder containing the 4 classes to your app. besides that you also have to embed the [Alamofire](https://github.com/Alamofire/Alamofire), and [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) libraries


## Building the AlamofireOaut2Test demo

1) Clone the repo to a working directory

2) [CocoaPods](http://cocoapods.org) is used to manage dependencies. Pods are setup easily and are distributed via a ruby gem. Follow the simple instructions on the website to setup. After setup, run the following command from the toplevel directory of AlamofireOauth to download the dependencies for AlamofireOauth:

```sh
pod install
```

3) Open the `AlamofireOauth.xcworkspace` in Xcode and.

4) Create your own clientID and clientSecret at https://developer.wordpress.com/docs/oauth2/ 

5) set the clientID and clientSecret in the wordpressOauth2Settings object in the ViewController

and you are ready to go!

## How to use the AlamofireOauth
Below is the sample code for a simple call to the WorPress API while authenticating using OAuth2


```
class ViewController: UIViewController {

    @IBOutlet weak var result: UITextView!

    @IBAction func startWordpressOauth2Test(sender: AnyObject) {
        self.result.text = ""
        UsingOauth2(wordpressOauth2Settings, self, { token in
            WordPressRequestConvertible.OAuthToken = token
            Alamofire.request(WordPressRequestConvertible.Me())
                .responseJSON { (request, response, json, error ) -> Void in
                self.result.text = "\(json)"
                println("JSON = \(json)")
            }
        }, {
            println("Oauth2 failed")
        })
    }
}

// Create your own clientID and clientSecret at https://developer.wordpress.com/docs/oauth2/
let wordpressOauth2Settings = Oauth2Settings(
    baseURL: "https://public-api.wordpress.com/rest/v1",
    authorizeURL: "https://public-api.wordpress.com/oauth2/authorize",
    tokenURL: "https://public-api.wordpress.com/oauth2/token",
    redirectURL: "alamofireoauth2://wordpress/oauth_callback",
    clientID: "????????????",
    clientSecret: "????????????"
)

// Minimal Alamofire implementation. For more info see https://github.com/Alamofire/Alamofire#crud--authorization
public enum WordPressRequestConvertible: URLRequestConvertible {
    static var baseURLString: String? = wordpressOauth2Settings.baseURL
    static var OAuthToken: String?

    case Me()

    public var URLRequest: NSURLRequest {
        let URL = NSURL(string: WordPressRequestConvertible.baseURLString!)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent("/me"))
        mutableURLRequest.HTTPMethod = "GET"

        if let token = WordPressRequestConvertible.OAuthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return mutableURLRequest
    }
}
```
## License

AlamofireOauth2 is available under the MIT 3 license. See the LICENSE file for more info.

## My other libraries:
Also see my other open source iOS libraries:

- [EVReflection](https://github.com/evermeer/EVReflection) - Swift library with reflection functions with support for NSCoding, Printable, Hashable, Equatable and JSON 
- [EVCloudKitDao](https://github.com/evermeer/EVCloudKitDao) - Simplified access to Apple's CloudKit
- [EVFaceTracker](https://github.com/evermeer/EVFaceTracker) - Calculate the distance and angle of your device with regards to your face in order to simulate a 3D effect
- [EVURLCache](https://github.com/evermeer/EVURLCache) - a NSURLCache subclass for handling all web requests that use NSURLReques
- [AlamofireJsonToObject](https://github.com/evermeer/AlamofireJsonToObjects) - An Alamofire extension which converts JSON response data into swift objects using EVReflection
- [AlamofireOauth2](https://github.com/evermeer/AlamofireOauth2) - A swift implementation of OAuth2 using Alamofire
- [EVWordPressAPI](https://github.com/evermeer/EVWordPressAPI) - Swift Implementation of the WordPress (Jetpack) API using AlamofireOauth2, AlomofireJsonToObjects and EVReflection (work in progress)
- [PassportScanner](https://github.com/evermeer/PassportScanner) - Scan the MRZ code of a passport and extract the firstname, lastname, passport number, nationality, date of birth, expiration date and personal numer.