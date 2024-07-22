//
//  WebViewController.swift
//  fullScreen
//
//  Created by 박휘목 on 7/20/24.
//

import Foundation
import UIKit
import WebKit
import RealmSwift

class WebViewController: UIViewController, UIScrollViewDelegate {
    
    let ad = UIApplication.shared.delegate as! AppDelegate
    let realm = try! Realm()
    
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
        
        webView.allowsBackForwardNavigationGestures = true
        
        self.webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = true
        
        self.navigationItem.title = "\(ad.goURL)"
        
        let url = URL(string: ad.goURL)
        let req = URLRequest(url: url!)
        
        webView.load(req)
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? false
    }
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("END LOAD")
        
        
        let checkAdUrl = extractDomainUrl(urlString: ad.goURL)

        if checkAdUrl.contains("site1") {
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
    
}

extension WebViewController {
    
    func extractDomainUrl(urlString: String) -> String {
        if let url = URL(string: urlString) {
            if let domain = url.host {
                // domain 변수에는 "www.example.com"이 저장됩니다.
                return domain
            } else {
                print("No domain found")
                return ""
            }
        } else {
            print("Invalid URL")
            return ""
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            guard let url = self.webView.url?.absoluteString else {
                return
            }
            
            print("now url = \(url)")
            self.navigationItem.title = "\(url)"
            
            let checkAdUrl = extractDomainUrl(urlString: ad.goURL)
            let changeUrl = extractDomainUrl(urlString: url)
            
            if url.contains("site1") && url.contains("%EC%9B%B9%ED%88%B0?fil=%EC%9D%B8%EA%B8%B0") {
                if checkAdUrl != changeUrl {
                    let alert = UIAlertController(title: "Detect Change URL", message: "요청된 url = \(checkAdUrl)\n변경된 url = \(changeUrl)\n변경된 url로 저장하시겠습니까?", preferredStyle: .alert)
                    
                    let success = UIAlertAction(title: "확인", style: .default){ [self] action in
                        print("확인 버튼이 눌렸습니다.")
                        
                        let existingData = self.realm.objects(UrlInfoRealm.self).filter("urlSrl == 'site1'")
                        print("취소할 데이터 :", existingData)
                        
                        let newData = UrlInfoRealm()
                        newData.urlSrl = "site1"
                        newData.urlDomain = url
                        
                        do {
                            try realm.write {
                                realm.delete(existingData)
                                realm.add(newData)
                            }
                        } catch {
                            print("\(error)")
                        }
                    }
                    
                    let cancel = UIAlertAction(title: "취소", style: .cancel){ cancel in
                        print("취소 버튼이 눌렸습니다.")
                    }
                    
                    alert.addAction(cancel)
                    alert.addAction(success)
                    
                    present(alert, animated: true)
                }
                
                // navigationController 기본 뒤로가기 컨트롤러
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            } else {
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            }
            
        }
    }
}
