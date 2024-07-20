//
//  WebViewController.swift
//  fullScreen
//
//  Created by 박휘목 on 7/20/24.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController, UIScrollViewDelegate {
    
    let ad = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: {
            (records) -> Void in
            for record in records {
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                // remove callback
            }
        })
        
        webView.scrollView.delegate = self
        webView.navigationDelegate  = self
        webView.uiDelegate = self
        
        navigationController?.hidesBarsOnSwipe = true
        
        self.webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "\(ad.goURL)"

        let url = URL(string: ad.goURL)
        let req = URLRequest(url: url!)
        
        webView.load(req)
    }
    
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("END LOAD")
        
        webView.evaluateJavaScript("document.querySelectorAll('.navbar')[0].style.display = 'none'",
                                   completionHandler: nil)
        
        webView.evaluateJavaScript("document.querySelectorAll('#mobile_nav')[0].style.display = 'none'",
                                   completionHandler: nil)
        
        webView.evaluateJavaScript("document.querySelectorAll('.col-md-12.mobile-banner')[0].style.display = 'none'",
                                   completionHandler: nil)  
        
        webView.evaluateJavaScript("document.querySelectorAll('.clearfix')[1].style.display = 'none'",
                                   completionHandler: nil)
        
        webView.evaluateJavaScript("document.querySelectorAll('.bn.bnt')[0].style.display = 'none'",
                                   completionHandler: nil)
        
        webView.evaluateJavaScript("document.querySelectorAll('.visible-xs')[0].setAttribute('style', 'display:none!important')",
                                   completionHandler: nil)
        
        webView.evaluateJavaScript("document.querySelectorAll('.visible-xs')[1].setAttribute('style', 'display:none!important')",
                                   completionHandler: nil)
        
        webView.evaluateJavaScript("document.querySelectorAll('#banner_21_img')[0].style.display = 'none'",
                                   completionHandler: nil)
    }

}

extension WebViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            guard let url = self.webView.url?.absoluteString else {
                return
            }
            
            print("now url = \(url)")
            self.navigationItem.title = "\(url)"
        }
    }
}
