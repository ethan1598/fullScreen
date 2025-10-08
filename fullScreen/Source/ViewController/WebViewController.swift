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
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate {
    // WKUserScript가 모든 광고를 즉시 제거하므로 추가 네비게이션 델리게이트 불필요
}

extension WebViewController {
    
    func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = false
        
        // MARK: - 즉시 광고 제거 스크립트 (WKUserScript)
        setupImmediateAdBlocking(webConfiguration: webConfiguration)
        
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
    
    
    // MARK: - 즉시 광고 제거 시스템 (WKUserScript)
    func setupImmediateAdBlocking(webConfiguration: WKWebViewConfiguration) {
        let adBlockScript = """
        (function() {
            console.log('🚀 즉시 광고 차단 스크립트 시작');
            
            // 불법 도박 사이트 링크 제거 함수
            function removeGamblingAds() {
                // linkbn.php 패턴의 링크들 제거
                const gamblingLinks = document.querySelectorAll('a[href*="linkbn.php"]');
                if (gamblingLinks.length > 0) {
                    console.log('🎰 불법 도박 링크 제거:', gamblingLinks.length + '개');
                    gamblingLinks.forEach(link => {
                        link.style.display = 'none';
                        link.remove();
                    });
                }
                
                // 기존 광고 요소들 제거
                const adSelectors = [
                    '.navbar', '#mobile_nav', '.col-md-12.mobile-banner',
                    '.clearfix', '.bn.bnt', '.visible-xs', '#banner_21_img',
                    '#main-banner-view', '#id_mbv', '#hd_pop', '.basic-banner',
                    '.m-list', '.at-go', '.col-md-12.mobile-banner'
                ];
                
                let removedCount = 0;
                adSelectors.forEach(selector => {
                    const elements = document.querySelectorAll(selector);
                    elements.forEach(el => {
                        el.style.display = 'none';
                        el.remove();
                        removedCount++;
                    });
                });
                
                if (removedCount > 0) {
                    console.log('🧹 광고 요소 제거:', removedCount + '개');
                }
            }
            
            // DOM 변경 감지 및 실시간 광고 제거
            const observer = new MutationObserver(function(mutations) {
                let shouldCheck = false;
                mutations.forEach(function(mutation) {
                    if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                        shouldCheck = true;
                    }
                });
                
                if (shouldCheck) {
                    removeGamblingAds();
                }
            });
            
            // DOM이 준비되면 즉시 실행
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', removeGamblingAds);
            } else {
                removeGamblingAds();
            }
            
            // body가 준비되면 observer 시작
            if (document.body) {
                observer.observe(document.body, { 
                    childList: true, 
                    subtree: true 
                });
            } else {
                document.addEventListener('DOMContentLoaded', function() {
                    observer.observe(document.body, { 
                        childList: true, 
                        subtree: true 
                    });
                });
            }
            
            console.log('✅ 즉시 광고 차단 시스템 활성화');
        })();
        """
        
        let userScript = WKUserScript(
            source: adBlockScript,
            injectionTime: .atDocumentStart, // 페이지 로드 시작 시점
            forMainFrameOnly: false
        )
        
        webConfiguration.userContentController.addUserScript(userScript)
        print("🚀 즉시 광고 차단 스크립트 주입 완료")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url) {
            guard let url = self.webV.url?.absoluteString else {
                return
            }
            
            var removePercentUrl = url.removingPercentEncoding ?? ""
            
            print("now url = \(removePercentUrl)", url.count)
            self.navigationItem.title = "\(removePercentUrl)"
            
            let checkAdUrl = extractDomainUrl(urlString: ad.goURL)
            let changeUrl = extractDomainUrl(urlString: url)
            
            if removePercentUrl.contains("site1") && removePercentUrl.contains("콘텐츠") && removePercentUrl.contains("인기") {
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
