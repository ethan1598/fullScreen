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
    
    //    let picker = UIPickerView()
    @IBOutlet weak var goSite1: UIButton!
    @IBOutlet weak var goSite2: UIButton!
    @IBOutlet weak var site1Title: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.configPickerView()
        print("realm 개수 :", realm.objects(UrlInfoRealm.self).count)
        
        site1Title.delegate = self
        
        let keyboardToolbar = UIToolbar()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneButtonTapped))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        keyboardToolbar.sizeToFit()
//        keyboardToolbar.tintColor = UIColor.systemGray

        site1Title.inputAccessoryView = keyboardToolbar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = false
        
//        print(realm.objects(UrlInfoRealm.self).filter("urlSrl == 'site1'")[0].urlDomain ?? "")
        
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
        
        site1Title.text = ""
    }
    
    @IBAction func goSite1(_ sender: Any) {
        let newDataUrl = UrlInfoRealm()
        let queryResult = realm.objects(UrlInfoRealm.self).filter("urlSrl == 'site1'")
        
        ad.goURL = "https://example1.com/콘텐츠?fil=인기"

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
            
            if site1Title.text != "" {
                var site1Domain = ""
                if let convertUrl = URL(string: ad.goURL) {
                    if let domain = convertUrl.host {
                        // domain 변수에는 "www.example.com"이 저장됩니다.
                        site1Domain = domain
                    }
                }
                
                ad.goURL = "https://\(site1Domain)/\(site1Title.text!.replacingOccurrences(of: " ", with: "-"))"
                print("convert Title, \(ad.goURL)")
            }
        }
        
        self.navigationController?.pushViewController(nvc, animated: true)
    }
    
    @IBAction func goSite2(_ sender: Any) {
        let newDataUrl = UrlInfoRealm()
        let queryResult = realm.objects(UrlInfoRealm.self).filter("urlSrl == 'site2'")
        
        ad.goURL = "https://example2.com/"
        
        if queryResult.count == 0 {
            do {
                newDataUrl.urlSrl = "site2"
                newDataUrl.urlDomain = ad.goURL
                
                try realm.write {
                    realm.add(newDataUrl)
                }
            } catch {
                print("site2 Insert Error \(error)")
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
        // 완료 버튼이 눌렸을 때 실행될 코드
        site1Title.resignFirstResponder() // 키보드 내리기
        print("Text entered: \(site1Title.text ?? "")")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//    func configPickerView() {
//        picker.delegate = self
//        picker.dataSource = self
//        selectDomain.inputView = picker
//
//        configToolbar()
//    }
//
//    func configToolbar() {
//        let toolBar = UIToolbar()
//        toolBar.barStyle = UIBarStyle.default
//        toolBar.isTranslucent = true
//        //        toolBar.tintColor = UIColor.white
//        toolBar.sizeToFit()
//
//        let doneBT = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(self.donePicker))
//        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let cancelBT = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(self.cancelPicker))
//
//        toolBar.setItems([cancelBT,flexibleSpace,doneBT], animated: false)
//        toolBar.isUserInteractionEnabled = true
//
//        selectDomain.inputAccessoryView = toolBar
//    }
//
//    @objc func donePicker() {
//        let row = self.picker.selectedRow(inComponent: 0)
//        self.picker.selectRow(row, inComponent: 0, animated: false)
//        self.selectDomain.text = self.domainList[row]
//        self.selectDomain.resignFirstResponder()
//    }
//
//    @objc func cancelPicker() {
//        self.selectDomain.text = nil
//        self.selectDomain.resignFirstResponder()
//    }
//
//    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return domainList.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return domainList[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        self.selectDomain.text = self.domainList[row]
//    }
//}
