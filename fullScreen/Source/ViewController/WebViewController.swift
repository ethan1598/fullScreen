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
    var webV = WKWebView()
    
    override func viewDidLoad() {
//        if #available(iOS 16.4, *) {
//            webView.isInspectable = true
//        }
//        
//        webView.scrollView.delegate = self
//        webView.navigationDelegate  = self
//        webView.uiDelegate = self
//        
//        webView.allowsBackForwardNavigationGestures = true
//        
//        self.webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: {
            (records) -> Void in
            for record in records {
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                // remove callback
            }
        })
        
        navigationController?.hidesBarsOnSwipe = true
        
        self.navigationItem.title = "\(ad.goURL)"
        
        let url = URL(string: ad.goURL)
        let req = URLRequest(url: url!)
        
//        webView.load(req)
        
        setupWebView()
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        webView?.loadHTMLString("<html><body></body></html>", baseURL: nil)
//    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? false
    }
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate {
    //    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    //        print("didStartProvisionalNavigation")
    //    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) { [self] in
            let checkAdUrl = extractDomainUrl(urlString: ad.goURL)
            
            if checkAdUrl.contains("site1") {
                webView.evaluateJavaScript("document.querySelectorAll('.navbar')[0].style.display = 'none'", completionHandler: nil)
                webView.evaluateJavaScript("document.querySelectorAll('#mobile_nav')[0].style.display = 'none'", completionHandler: nil)
                webView.evaluateJavaScript("document.querySelectorAll('.col-md-12.mobile-banner')[0].style.display = 'none'", completionHandler: nil)
                webView.evaluateJavaScript("document.querySelectorAll('.clearfix')[1].style.display = 'none'", completionHandler: nil)
                webView.evaluateJavaScript("document.querySelectorAll('.bn.bnt')[0].style.display = 'none'", completionHandler: nil)
                webView.evaluateJavaScript("document.querySelectorAll('.visible-xs')[0].setAttribute('style', 'display:none!important')",completionHandler: nil)
                webView.evaluateJavaScript("document.querySelectorAll('.visible-xs')[1].setAttribute('style', 'display:none!important')",completionHandler: nil)
                webView.evaluateJavaScript("document.querySelectorAll('#banner_21_img')[0].style.display = 'none'",completionHandler: nil)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("END LOAD")
        
        let checkAdUrl = extractDomainUrl(urlString: ad.goURL)
        
        if checkAdUrl.contains("site1") == false {
            webView.evaluateJavaScript("document.querySelectorAll('#main-banner-view')[0].style.display = 'none'", completionHandler: nil)
            webView.evaluateJavaScript("document.querySelectorAll('#id_mbv')[0].style.display = 'none'", completionHandler: nil)
            webView.evaluateJavaScript("document.querySelectorAll('#hwjsutnkgpqrlvfmio')[0].style.display = 'none'", completionHandler: nil)
            webView.evaluateJavaScript("document.querySelectorAll('#tuvqmrlgjopsfwxnikh')[0].style.display = 'none'", completionHandler: nil)
            webView.evaluateJavaScript("document.querySelectorAll('#ptymjglvrfxsqhikwuno')[0].style.display = 'none'", completionHandler: nil)
            webView.evaluateJavaScript("document.querySelectorAll('#mobile_nav')[0].style.display = 'none'", completionHandler: nil)
            webView.evaluateJavaScript("document.querySelectorAll('#hd_pop')[0].style.display = 'none'", completionHandler: nil)
            webView.evaluateJavaScript("document.querySelectorAll('.basic-banner.row.row-10')[0].style.display = 'none'", completionHandler: nil)
            webView.evaluateJavaScript("document.querySelectorAll('.basic-banner.row.row-10')[1].style.display = 'none'", completionHandler: nil)
            webView.evaluateJavaScript("document.querySelectorAll('.m-list')[0].style.display = 'none'", completionHandler: nil)
        }
    }
    
}

extension WebViewController {
    
    func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webV = WKWebView(frame: .zero, configuration: webConfiguration)
        
        view.addSubview(webV)
        
        webV.scrollView.delegate = self
        webV.navigationDelegate  = self
        webV.uiDelegate = self
        
        webV.allowsBackForwardNavigationGestures = true
        
        // URL 로드
        let url = URL(string: ad.goURL)!
        let request = URLRequest(url: url)
        webV.load(request)
        
        webV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webV.topAnchor.constraint(equalTo: view.topAnchor),
            webV.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webV.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webV.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        print("SET UP WEBVIEW")
        
        if #available(iOS 16.4, *) {
            webV.isInspectable = true
        }
        
        webV.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
    }
    
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
            guard let url = self.webV.url?.absoluteString else {
                return
            }
            
            print("now url = \(url)", url.count)
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
                        newData.urlDomain = url.removingPercentEncoding
                        
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
            } else if url.contains("site2") && url.count <= 23 {
                if checkAdUrl != changeUrl {
                    let alert = UIAlertController(title: "Detect Change URL", message: "요청된 url = \(checkAdUrl)\n변경된 url = \(changeUrl)\n변경된 url로 저장하시겠습니까?", preferredStyle: .alert)
                    
                    let success = UIAlertAction(title: "확인", style: .default){ [self] action in
                        print("확인 버튼이 눌렸습니다.")
                        
                        let existingData = self.realm.objects(UrlInfoRealm.self).filter("urlSrl == 'site2'")
                        print("취소할 데이터 :", existingData)
                        
                        let newData = UrlInfoRealm()
                        newData.urlSrl = "site2"
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
                
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            } else {
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            }
            
        }
    }
}
