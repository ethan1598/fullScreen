//
//  ViewController.swift
//  fullScreen
//
//  Created by 박휘목 on 7/20/24.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITextFieldDelegate {

    let ad = UIApplication.shared.delegate as! AppDelegate
    let realm = try! Realm()

    let domainList = ["site1", "site2"]
    let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "webViewVC")

    @IBOutlet weak var recentSite1Link: UILabel!
    @IBOutlet weak var recentSite2Link: UILabel!

    @IBOutlet weak var goSite1: UIButton!
    @IBOutlet weak var goSite2: UIButton!
    @IBOutlet weak var searchTitle: UITextField!

    // Config.plist에서 URL 로드
    private var site1URL: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let url = dict["Site1URL"] as? String else {
            return ""
        }
        return url
    }

    private var site2URL: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let url = dict["Site2URL"] as? String else {
            return ""
        }
        return url
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("realm 개수 :", realm.objects(UrlInfoRealm.self).count)

        searchTitle.delegate = self

        let keyboardToolbar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneButtonTapped))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        keyboardToolbar.sizeToFit()

        searchTitle.inputAccessoryView = keyboardToolbar
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = false

        if realm.objects(UrlInfoRealm.self).filter("urlSrl == 'site1'").count != 0 {
            recentSite1Link.text = realm.objects(UrlInfoRealm.self).filter("urlSrl == 'site1'")[0].urlDomain
        } else {
            recentSite1Link.text = "없음"
        }

        if realm.objects(UrlInfoRealm.self).filter("urlSrl == 'site2'").count != 0 {
            recentSite2Link.text = realm.objects(UrlInfoRealm.self).filter("urlSrl == 'site2'")[0].urlDomain
        } else {
            recentSite2Link.text = "없음"
        }

        searchTitle.text = ""
    }

    @IBAction func goSite1(_ sender: Any) {
        let newDataUrl = UrlInfoRealm()
        let queryResult = realm.objects(UrlInfoRealm.self).filter("urlSrl == 'site1'")

        ad.goURL = site1URL

        if queryResult.count == 0 {
            do {
                newDataUrl.urlSrl = "site1"
                newDataUrl.urlDomain = ad.goURL

                try realm.write {
                    realm.add(newDataUrl)
                }
            } catch {
                print("Site1 Insert Error \(error)")
            }
        } else {
            ad.goURL = queryResult[0].urlDomain ?? ""

            if searchTitle.text != "" {
                var siteDomain = ""
                if let convertUrl = URL(string: ad.goURL) {
                    if let domain = convertUrl.host {
                        siteDomain = domain
                    }
                }

                ad.goURL = "https://\(siteDomain)/\(searchTitle.text!.replacingOccurrences(of: " ", with: "-"))"
                print("convert Title, \(ad.goURL)")
            }
        }

        self.navigationController?.pushViewController(nvc, animated: true)
    }

    @IBAction func goSite2(_ sender: Any) {
        let newDataUrl = UrlInfoRealm()
        let queryResult = realm.objects(UrlInfoRealm.self).filter("urlSrl == 'site2'")

        ad.goURL = site2URL

        if queryResult.count == 0 {
            do {
                newDataUrl.urlSrl = "site2"
                newDataUrl.urlDomain = ad.goURL

                try realm.write {
                    realm.add(newDataUrl)
                }
            } catch {
                print("Site2 Insert Error \(error)")
            }
        } else {
            ad.goURL = queryResult[0].urlDomain ?? ""
        }

        print(ad.goURL.count)

        self.navigationController?.pushViewController(nvc, animated: true)
    }

}

extension ViewController {
    @objc func doneButtonTapped() {
        searchTitle.resignFirstResponder()
        print("Text entered: \(searchTitle.text ?? "")")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
