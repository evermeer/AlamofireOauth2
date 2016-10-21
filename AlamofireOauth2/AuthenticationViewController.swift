
import Foundation
import UIKit

class AuthenticationViewController : UIViewController, UIWebViewDelegate{

    let expectedState:String = "authDone"
    
    var webView: UIWebView?
    
    var successCallback : ((_ code:String)-> Void)?
    var failureCallback : ((_ error:Error) -> Void)?

    var isRetrievingAuthCode : Bool? = false

    var oauth2Settings:Oauth2Settings!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(oauth2Settings: Oauth2Settings, successCallback:@escaping ((_ code:String)-> Void), failureCallback:@escaping ((_ error:Error) -> Void)) {
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
            bindCheck.backgroundColor = UIColor.clear
            bindCheck.scalesPageToFit = true
            bindCheck.delegate = self
            self.view.addSubview(bindCheck)
        }
        
        self.view.backgroundColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelAction))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TO alter if more parameters needed
        let url:String! = self.oauth2Settings.authorizeURL + "?response_type=code&client_id=" + self.oauth2Settings.clientID + "&redirect_uri=" + self.oauth2Settings.redirectURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlHostAllowed)! + "&scope=" + self.oauth2Settings.scope + "&state=" + expectedState
        
        let urlRequest : NSURLRequest = NSURLRequest(url: NSURL(string: url)! as URL)
        
        self.webView!.loadRequest(urlRequest as URLRequest)
    }
    
    
    func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url : String = request.url!.absoluteString
        
        self.isRetrievingAuthCode = url.hasPrefix(self.oauth2Settings.redirectURL)

        if url.hasPrefix("http:") {
            print("\n\nWARNING: You should use https:// authentication will probably fail!\n\n")
        }
        
        if (self.isRetrievingAuthCode!) {
            if(url.contains("error")) {
                let error:Error = NSError(domain:"CROAuth2UnknownErrorDomain", code:0, userInfo: nil)
                self.failureCallback!(error)
            } else {
                
                let optionnalState:String? = NSURLComponents(string: url)?.queryItems?.filter { $0.name == "state" }.first?.value
                
                if let state = optionnalState {
                    if (state == expectedState) {
                        let optionnalCode:String? = NSURLComponents(string: url)?.queryItems?.filter { $0.name == "code" }.first?.value
                        if let code = optionnalCode {
                            self.successCallback!(code)
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if self.isRetrievingAuthCode == false {
            self.failureCallback?(error)
        }
    }
}


