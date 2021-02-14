//
//  DeleteViewController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/13.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class DeleteViewController: UIViewController {
            
    var collectionID:String = ""
    var docID:String = ""
    var locationName:String = ""
    var anotherDocID:String = ""
        
    
    override func viewDidLoad() {
        super.viewDidLoad()

                
          
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
//        showActionSheet()
        deletePost()
                        
    }
    
    func deletePost(){
                    
        Firestore.firestore().collection(collectionID).document(docID).collection(locationName).document(anotherDocID).delete { (error) in
            if error != nil{
                print(error)
            }else{
                print("消したよ")
                
//                let TLVC = self.storyboard?.instantiateViewController(identifier: "timeLine") as! TimeLineViewController
//                self.present(TLVC, animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
                self.alert(title: "投稿を削除しました!!", message: "", subtitle: "戻る")
                
            }
        }                

    }
    
    
    func alert(title:String,message:String,subtitle:String){
        //アラートのタイトル
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //ボタンのタイトル
        dialog.addAction(UIAlertAction(title: subtitle, style: .default, handler: nil))
        //実際に表示させる
        self.present(dialog, animated: true, completion: nil)
    }

    
}
