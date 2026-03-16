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

    // Config.plist에서 사이트 키워드 로드
    private var siteKeywords: [(key: String, keyword: String)] {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) else {
            return []
        }
        var result: [(key: String, keyword: String)] = []
        if let key = dict["Site1Key"] as? String {
            result.append((key: "site1", keyword: key))
        }
        if let key = dict["Site2Key"] as? String {
            result.append((key: "site2", keyword: key))
        }
        return result
    }

    override func viewDidLoad() {
    }

    override func viewWillAppear(_ animated: Bool) {
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: {
            (records) -> Void in
            for record in records {
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        })

        navigationController?.hidesBarsOnSwipe = true

        self.navigationItem.title = "\(ad.goURL)"

        let url = URL(string: ad.goURL)
        let req = URLRequest(url: url!)

        setupWebView()
    }

    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden ?? false
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate {
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
            function removeAds() {
                const adLinks = document.querySelectorAll('a[href*="linkbn.php"]');
                adLinks.forEach(link => {
                    link.style.display = 'none';
                    link.remove();
                });

                const adSelectors = [
                    '.navbar', '#mobile_nav', '.col-md-12.mobile-banner',
                    '.clearfix', '.bn.bnt', '.visible-xs', '#banner_21_img',
                    '#main-banner-view', '#id_mbv', '#hd_pop', '.basic-banner',
                    '.m-list', '.at-go', '.col-md-12.mobile-banner'
                ];

                adSelectors.forEach(selector => {
                    const elements = document.querySelectorAll(selector);
                    elements.forEach(el => {
                        el.style.display = 'none';
                        el.remove();
                    });
                });
            }

            const observer = new MutationObserver(function(mutations) {
                let shouldCheck = false;
                mutations.forEach(function(mutation) {
                    if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                        shouldCheck = true;
                    }
                });

                if (shouldCheck) {
                    removeAds();
                }
            });

            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', removeAds);
            } else {
                removeAds();
            }

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
        })();
        """

        let userScript = WKUserScript(
            source: adBlockScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )

        webConfiguration.userContentController.addUserScript(userScript)
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

            // site1 URL 변경 감지
            if checkAdUrl != changeUrl && ad.goURL.contains(extractDomainUrl(urlString: ad.goURL)) {
                let matchedSite = detectSite(url: removePercentUrl)

                if let site = matchedSite {
                    let alert = UIAlertController(title: "Detect Change URL", message: "요청된 url = \(checkAdUrl)\n변경된 url = \(changeUrl)\n변경된 url로 저장하시겠습니까?", preferredStyle: .alert)

                    let success = UIAlertAction(title: "확인", style: .default){ [self] action in
                        let existingData = self.realm.objects(UrlInfoRealm.self).filter("urlSrl == %@", site)

                        let newData = UrlInfoRealm()
                        newData.urlSrl = site
                        newData.urlDomain = site == "site1" ? url.removingPercentEncoding : url

                        do {
                            try realm.write {
                                realm.delete(existingData)
                                realm.add(newData)
                            }
                        } catch {
                            print("\(error)")
                        }
                    }

                    let cancel = UIAlertAction(title: "취소", style: .cancel)

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

    private func detectSite(url: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) else {
            return nil
        }

        if let site1URL = dict["Site1URL"] as? String,
           let site1Domain = URL(string: site1URL)?.host,
           url.contains(site1Domain.components(separatedBy: ".").first ?? "") {
            return "site1"
        }

        if let site2URL = dict["Site2URL"] as? String,
           let site2Domain = URL(string: site2URL)?.host,
           url.contains(site2Domain.components(separatedBy: ".").first ?? "") {
            return "site2"
        }

        return nil
    }
}
