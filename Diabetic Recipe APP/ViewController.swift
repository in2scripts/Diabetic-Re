import GoogleMobileAds

import UIKit
import WebKit
class ViewController: UIViewController, WKNavigationDelegate,GADBannerViewDelegate {
    
    
    var webView: WKWebView!
    let screenSize = UIScreen.main.bounds
    // Ad banner
    var adMobBannerView = GADBannerView()
    
    let deviceID = UIDevice.current.identifierForVendor?.uuidString
    // IMPORTANT: REPLACE THE RED STRING BELOW WITH THE UNIT ID YOU'VE GOT BY REGISTERING YOUR APP IN http://apps.admob.com
    let ADMOB_BANNER_UNIT_ID = "ca-app-pub-4579602742595312/8918742352"
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
     
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.dataDetectorTypes = [.all]
        
        
        webConfiguration.preferences.javaScriptEnabled = true
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        let url = Bundle.main.url(forResource: "main", withExtension: "html", subdirectory: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never;
        }
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        // Init AdMob banner
        //initAdMobBanner()
        
        
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let urlAsString = navigationAction.request.url?.absoluteString else {
            return
        }
        
        
        let string1 = urlAsString
        if navigationAction.navigationType == .linkActivated {
            
            if string1.contains("#view-home") {
                let device = UIDevice.current.identifierForVendor?.uuidString
                let myURL = URL(string:"https://my.phpsmarter.com/ios/?device=" + device.unsafelyUnwrapped)
                let myRequest = URLRequest(url: myURL!)
                webView.load(myRequest)
                
            }
            if string1.contains("mylist.php") {
                let url = Bundle.main.url(forResource: "main", withExtension: "html", subdirectory: "html")!
                webView.loadFileURL(url, allowingReadAccessTo: url)
                let request = URLRequest(url: url)
                webView.load(request)
             
            }
            if string1.contains("#doc") {
                
                let file = "index.html" //this is the file. we will write to and read from it

                

                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    
                    let fileURL = dir.appendingPathComponent(file)
                    let found = dir.appendingPathComponent(file).path
                    
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: found) {
                        
                        do {
                            let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                            
                            webView.loadHTMLString(text2, baseURL: nil)
                            
                        }
                        catch {/* error handling here */}                    }
                    else{
                        let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "html")!
                        webView.loadFileURL(url, allowingReadAccessTo: url)
                        let request = URLRequest(url: url)
                        webView.load(request)
                        //reading
                        
                    }
                }
                
            }
            
            if string1.contains("#add-list") {
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.download(url1: self.getDocumentsDirectory().appendingPathComponent("index.html"))
                }
                
                
}        }
        
        decisionHandler(.allow)      }
  
    func download(url1 : URL) {
        
            let device = UIDevice.current.identifierForVendor?.uuidString
        let myURL = "https://my.phpsmarter.com/main.php?device=" + device.unsafelyUnwrapped
        if let messageURL = URL(string: myURL) {
                let sharedSession = URLSession.shared
                let downloadTask = sharedSession.downloadTask(with: messageURL) { (location, response, error) in
                    var urlContents = ""
                    if let location = location {
                        do{
                            urlContents = try String(contentsOf: location, encoding: String.Encoding.utf8)
                        }catch {
                            print("Couldn't load string from \(location)")
                        }
                        let file = "index.html" //this is the file. we will write to and read from it
                        
                        let text = urlContents //just a text
                        
                        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            
                            let fileURL = dir.appendingPathComponent(file)
                            
                            //writing
                            do {
                                try text.write(to: fileURL, atomically: false, encoding: .utf8)
                            }
                            catch {/* error handling here */}
                            
                            
                        }
                    }
                }
            
                downloadTask.resume()
            } else {
                print("\(myURL) isn't a valid URL")
            }
    }
    
    func initAdMobBanner() {
        
        
        let screenHeight = screenSize.height - 60
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
            adMobBannerView.frame = CGRect(x: 20, y: screenHeight, width: 320, height: 50)
        } else  {
            // iPad
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 468, height: 60))
            adMobBannerView.frame = CGRect(x: 80, y: screenHeight, width: 468, height: 60)
        }
        
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        adMobBannerView.load(request)
    }
    
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = false
    }
    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView!) {
        showBanner(adMobBannerView)
    }
    
    
    
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let screenHeight = size.height - 55
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
            adMobBannerView.frame = CGRect(x: 20, y: screenHeight, width: 320, height: 80)
        } else  {
            // iPad
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 468, height: 60))
            adMobBannerView.frame = CGRect(x: 80, y: screenHeight, width: 468, height: 60)
        }}
    
    
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}
    
    
   

