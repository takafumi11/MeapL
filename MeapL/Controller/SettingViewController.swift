//
//  SettingViewController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/14.
//

import UIKit
import ChameleonFramework
import Firebase
import FirebaseAuth

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    
    let termsBtn: UIButton = {
        let btn=UIButton()
        btn.backgroundColor = UIColor.flatWatermelon()
        btn.layer.cornerRadius = 10
        btn.tintColor = UIColor.flatWhite()
        btn.setTitle("利用規約を確認する", for: .normal)
        btn.addTarget(self, action: #selector(terms), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    let contactBtn: UIButton = {
        let btn=UIButton()
        btn.backgroundColor = UIColor.flatWatermelon()
        btn.layer.cornerRadius = 10
        btn.setTitle("お問い合わせ・不具合報告", for: .normal)
        btn.tintColor = UIColor.flatWhite()
        btn.addTarget(self, action: #selector(contact), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    let logoutBtn: UIButton = {
        let btn=UIButton()
        btn.backgroundColor = UIColor.flatWatermelon()
        btn.setTitle("アカウントを削除する", for: .normal)
        btn.layer.cornerRadius = 10
        btn.tintColor = UIColor.flatWhite()
        btn.addTarget(self, action: #selector(logout), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    @objc func terms(_ btn: UIButton){
        let webViewControlle = WebViewController()
        let terms = "https://noifumi.com/MeapL/terms.html"
        UserDefaults.standard.setValue(terms, forKey: "terms")
        present(webViewControlle, animated: true, completion: nil)
    }
    
    @objc func contact(_ btn: UIButton){
        let webViewControlle = WebViewController()
        let contact = "https://noifumi.com/MeapL/contact.html"
        UserDefaults.standard.setValue(contact, forKey: "contact")
        present(webViewControlle, animated: true, completion: nil)
    }
    
    @objc func logout(_ btn: UIButton){
        showActionSheet()
    }
    
    func showActionSheet(){
        let alertController = UIAlertController(title: "このアカウントを削除しますか?", message: "", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "はい", style: .default) { (alert) in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            print("userを削除しました")
            
            let enterVC = self.storyboard?.instantiateViewController(identifier: "privacy") as! PrivacyViewController
            self.navigationController?.pushViewController(enterVC, animated: true)
        }

        let action2 = UIAlertAction(title: "いいえ", style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupViews() {
        view.addSubview(termsBtn)
                        
        termsBtn.topAnchor.constraint(equalTo: view.topAnchor,constant: view.frame.size.height*0.2).isActive = true
        termsBtn.leftAnchor.constraint(equalTo: view.leftAnchor,constant: view.frame.size.width*0.1).isActive = true
        termsBtn.widthAnchor.constraint(equalToConstant: view.frame.size.width*0.8).isActive = true
        termsBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true

        view.addSubview(contactBtn)
        contactBtn.topAnchor.constraint(equalTo: view.topAnchor,constant: view.frame.size.height*0.4).isActive  = true
        contactBtn.leftAnchor.constraint(equalTo: view.leftAnchor,constant: view.frame.size.width*0.1).isActive  = true
        contactBtn.widthAnchor.constraint(equalToConstant: view.frame.size.width*0.8).isActive = true
        contactBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true


        view.addSubview(logoutBtn)
        logoutBtn.topAnchor.constraint(equalTo: view.topAnchor,constant: view.frame.size.height*0.6).isActive  = true
        logoutBtn.leftAnchor.constraint(equalTo: view.leftAnchor,constant: view.frame.size.width*0.1).isActive  = true
        logoutBtn.widthAnchor.constraint(equalToConstant: view.frame.size.width*0.8).isActive = true
        logoutBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }

}
