//
//  ViewController.swift
//  fullScreen
//
//  Created by 박휘목 on 7/20/24.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    let ad = UIApplication.shared.delegate as! AppDelegate
    
    let domainList = ["site1", "site2"]
    let nvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "webViewVC")
    
    @IBOutlet weak var recentSite1Link: UILabel!
    @IBOutlet weak var recentSite2Link: UILabel!
    
    //    let picker = UIPickerView()
    @IBOutlet weak var goSite1: UIButton!
    @IBOutlet weak var goSite2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.configPickerView()
    }
    
    @IBAction func goSite1(_ sender: Any) {
        ad.goURL = "https://example1.com/콘텐츠?fil=인기"
        
        self.navigationController?.pushViewController(nvc, animated: true)
    }
    
    @IBAction func goSite2(_ sender: Any) {
        ad.goURL = "https://example2.com/"
        
        self.navigationController?.pushViewController(nvc, animated: true)
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
