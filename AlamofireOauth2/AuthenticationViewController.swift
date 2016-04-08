
import Foundation
import UIKit

class AuthenticationViewController : UIViewController, UIWebViewDelegate{

    let expectedState:String = "authDone"
    
    var webView: UIWebView?
    
    var successCallback : ((code:String)-> Void)?
    var failureCallback : ((error:NSError) -> Void)?

    var isRetrievingAuthCode : Bool? = false

    var oauth2Settings:Oauth2Settings!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(oauth2Settings: Oauth2Settings, successCallback:((code:String)-> Void), failureCallback:((error:NSError) -> Void)) {
        super.init(nibName: nil, bundle: nil)
        
        self.oauth2Settings = oauth2Settings
        self.successCallback = successCallback
        self.failureCallback = failureCallback
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Login"
        
        self.webView = UIWebView(frame: self.view.bounds);
        
        if let bindCheck = self.webView {
            bindCheck.backgroundColor = UIColor.clearColor()
            bindCheck.scalesPageToFit = true
            bindCheck.delegate = self
            self.view.addSubview(bindCheck)
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(cancelAction))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TO alter if more parameters needed
        let url:String! = self.oauth2Settings.authorizeURL + "?response_type=code&client_id=" + self.oauth2Settings.clientID + "&redirect_uri=" + self.oauth2Settings.redirectURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())! + "&scope=" + self.oauth2Settings.scope + "&state=" + expectedState
        let urlRequest : NSURLRequest = NSURLRequest(URL: NSURL(string: url)!)
        
        self.webView!.loadRequest(urlRequest)
    }
    
    
    func cancelAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let url : NSString = request.URL!.absoluteString
        self.isRetrievingAuthCode = url.hasPrefix(self.oauth2Settings.redirectURL)
        
        if (self.isRetrievingAuthCode!) {
            if(url.rangeOfString("error").location != NSNotFound) {
                let error:NSError = NSError(domain:"CROAuth2UnknownErrorDomain", code:0, userInfo: nil)
                self.failureCallback!(error:error)
            } else {
                
                let optionnalState:String? = self.extractParameterFromUrl("state", url: url)
                
                if let state = optionnalState {
                    if (state == expectedState) {
                        
                        let optionnalCode:String? = self.extractParameterFromUrl("code", url: url)
                        if let code = optionnalCode {
                            self.successCallback!(code:code)
                        }
                    }
                }
            }
        }
        
        return true
            
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if (!self.isRetrievingAuthCode!) {
            self.failureCallback!(error: error ?? NSError(domain: "Could not retreive auth code", code: 1, userInfo: nil))
        }
    }
        
    
    func extractParameterFromUrl(parameterName:NSString, url:NSString) -> String? {
        
        if(url.rangeOfString("?").location == NSNotFound) {
            return nil
        }
        
        if let urlString: String = url.componentsSeparatedByString("?")[1] {
            var dict = Dictionary <String, String>()
            
            for param in urlString.componentsSeparatedByString("&") {
                var array = Array <AnyObject>()
                array = param.componentsSeparatedByString("=")
                let name:String = array[0] as! String
                let value:String = array[1] as! String
                
                dict[name] = value
            }
            if let result = dict[parameterName as String] {
                return result
            }
        }
        return nil
    }
}


