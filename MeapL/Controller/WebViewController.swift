//
//  WebViewController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/14.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(webView)
        
        //contact
        if UserDefaults.standard.object(forKey: "contact") != nil{
            let urlString = UserDefaults.standard.object(forKey: "contact")
            let url = URL(string: urlString as! String)
            let request = URLRequest(url: url!)
            
            UserDefaults.standard.removeObject(forKey: "contact")
            
            webView.load(request)
        }
        
        //terms
        if UserDefaults.standard.object(forKey: "terms") != nil{
            let urlString = UserDefaults.standard.object(forKey: "terms")
            let url = URL(string: urlString as! String)
            let request = URLRequest(url: url!)
            
            UserDefaults.standard.removeObject(forKey: "terms")
            
            webView.load(request)
        }
    }      
}
