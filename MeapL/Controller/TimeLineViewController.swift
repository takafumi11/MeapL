//
//  TimeLineViewController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/13.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import ChameleonFramework

struct LocatioInfo {
    var location:String = ""
    var image = Data()
    var text:String = ""
    var day:String = ""
    var anotherDocID:String = ""
    var docID:String = ""
}

class TimeLineViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var locationInfo:[LocatioInfo] = []

    var recordArr:[String] = [""]
    var docIDArr:[String] = []
    var docID:String = ""
    var anotherDocID:String = ""
    var collectionID:String = ""
    var locationName:String = ""
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        if Auth.auth().currentUser?.uid != nil{
            collectionID = Auth.auth().currentUser!.uid
        }
        
        indicator.startAnimating()
        indicator.color = .purple
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(update), for: .valueChanged)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        getLocation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        tableView.rowHeight = 450
        tableView.separatorStyle = .none
    }
    
    
    @objc func update(){
        tableView.reloadData()
        getLocation()
        refresh.endRefreshing()
    }
    
    func getLocation(){
        recordArr = []
        docIDArr = []

        Firestore.firestore().collection(collectionID).addSnapshotListener() { (snapShot, error) in

            if error != nil{
                print(error.debugDescription)
                return
            }

            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()

                    if let location = data["location"],let docID = data["docID"]{

                        self.recordArr.append(location as! String)
                        self.docIDArr.append(docID as! String)

                    }
                }
            }
        }

        //ここをできる限り短くしたい
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getInfo()
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
    
    func getInfo(){
        locationInfo = []
        if recordArr.count > 0{
            for i in 0...recordArr.count - 1{
                Firestore.firestore().collection(collectionID).document(docIDArr[i]).collection(recordArr[i]).addSnapshotListener() { [self] (snapShot, error) in

                    if error != nil{
                        print(error.debugDescription)
                        return
                    }
                    
                    if let snapShotDoc = snapShot?.documents{
                        for doc in snapShotDoc{
                            let data = doc.data()
                            if let day = data["day"] as? String,let image = data["image"] as? Data,let text = data["text"] as? String,let anotherDocID = data["anotherDocID"] as? String,let docID = data["docID"] as? String{
                                
                                let newInfo = LocatioInfo(location: recordArr[i],image: image, text: text, day: day,anotherDocID: anotherDocID,docID: docID)
                                locationInfo.append(newInfo)
                            }
                        }
                    }
                }
            }
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
//            print(self.locationInfo)
//            print(self.recordArr)
//            print(self.docIDArr)
            if self.locationInfo.count == 0{
                self.alert(title: "投稿がありません", message: "", subtitle: "戻る")
            }
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,style: .grouped)

        tableView.register(UINib(nibName: "TimeLineCell", bundle: nil), forCellReuseIdentifier: "timeLineCell")
                
        
        return tableView
    }()
    
    
    func setupViews() {
        view.addSubview(tableView)

    }
        

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeLineCell",for: indexPath) as! TimeLineCell
        
        cell.dateLabel.text = locationInfo[indexPath.row].day
        cell.locationLabel.text = locationInfo[indexPath.row].location
        let image = locationInfo[indexPath.row].image
        cell.photoImageView.image = UIImage(data: image)
        cell.impressionLabel.text = locationInfo[indexPath.row].text
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.setTitleColor(UIColor.flatWatermelon(), for: .normal)
        cell.deleteBtn.addTarget(self, action: #selector(tapBtn(_: )), for: UIControl.Event.touchUpInside)
        
        cell.bgView.layer.cornerRadius = 20.0
        cell.contentView.backgroundColor = UIColor.flatWhite()
        
                
        return cell
    }
    
    @objc func tapBtn(_ btn: UIButton){
      
        
        //番号だけ渡してdeleteVCで削除させる
        let deleteVC = storyboard?.instantiateViewController(identifier: "delete") as! DeleteViewController
        
        collectionID = Auth.auth().currentUser!.uid
        docID = locationInfo[btn.tag].docID
        anotherDocID = locationInfo[btn.tag].anotherDocID
        locationName = locationInfo[btn.tag].location
            
            
        deleteVC.collectionID = collectionID
        deleteVC.docID = docID
        deleteVC.anotherDocID = anotherDocID
        deleteVC.locationName = locationName
        
        deleteVC.modalPresentationStyle = .fullScreen
        showActionSheet(vc: deleteVC)
        
        
   
                
    }
    
    func showActionSheet(vc:UIViewController){
        let alertController = UIAlertController(title: "この投稿を削除しますか?", message: "", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "はい", style: .default) { (alert) in
            self.present(vc, animated: true, completion: nil)
        }

        let action2 = UIAlertAction(title: "いいえ", style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        self.present(alertController, animated: true, completion: nil)
    }

}
