//
//  PrivacyViewController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/14.
//

import UIKit
import WebKit
import ChameleonFramework

class PrivacyViewController: UIViewController,WKNavigationDelegate {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var agreeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //indicatorの設定
        indicator.startAnimating()
        indicator.color = .purple
        self.indicator.stopAnimating()
        
        //autolauoutの設定
        setupViews()
        
        //webViewの設定
        webView.navigationDelegate = self
        
        //規約画面
        let url = URL(string: "https://noifumi.com/MeapL/terms.html")
        let request = URLRequest(url: url!)
        
        webView.load(request)
                
        agreeBtn.tintColor = UIColor.white
        
        CheckBtnDidTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    func CheckBtnDidTap(){
        //checkBtnが押されている場合
        if(self.checkBtn.isSelected){
            agreeBtn.backgroundColor = UIColor.flatWatermelon()
        }else{
            agreeBtn.backgroundColor = UIColor.flatGray()
        }
        
        self.checkBtn.setImage(UIImage(named: "noCheck"), for: .normal)
        self.checkBtn.setImage(UIImage(named: "check"), for: .selected)
                            
    }

    @IBAction func check(_ sender: Any) {
        self.checkBtn.isSelected = !self.checkBtn.isSelected
        CheckBtnDidTap()
    }
    
    @IBAction func agree(_ sender: Any) {
        if(self.checkBtn.isSelected){
            let introVC = storyboard?.instantiateViewController(identifier: "intro") as! IntroViewController
            self.navigationController?.pushViewController(introVC, animated: true)
        }else{
            print("同意してください")
        }
    }
        
    var webView: WKWebView = {
        let wv = WKWebView()
        wv.translatesAutoresizingMaskIntoConstraints = false
        return wv
    }()

    func setupViews() {
        view.addSubview(webView)

        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: checkBtn.topAnchor, constant: -10).isActive = true
    }

}

