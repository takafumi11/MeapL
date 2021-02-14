//
//  ListViewController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/13.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import ChameleonFramework

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var recordArr:[String] = []
    
    let collectionID:String = Auth.auth().currentUser!.uid
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layer.cornerRadius = 20.0
        view.backgroundColor = UIColor.flatWhite()
        titleLabel.textColor = .white
        UITabBar.appearance().backgroundColor = .white
        UITabBar.appearance().tintColor = UIColor.flatWatermelon()
        
        bgView.backgroundColor = UIColor.flatWatermelon()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getLocation()
    }
    
    func getLocation(){
        recordArr = []
        
        Firestore.firestore().collection(collectionID).addSnapshotListener() {(snapShot, error) in
            
            if error != nil{
                print(error.debugDescription)
                return
            }
            
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    
                    if let location = data["location"]{
                              
                        
                        
                        self.recordArr.append(location as! String)
                        
                    }
                }
            }
        }
        
        //ここをできる限り短くしたい
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.reloadData()
        }
        
    }
    
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        cell.textLabel?.text = "・\(recordArr[indexPath.row])"
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height/8
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recordVC = storyboard?.instantiateViewController(identifier: "Record") as! RecordViewController
        
        recordVC.locationName = recordArr[indexPath.row]
        
        self.navigationController?.pushViewController(recordVC, animated: true)
    }
    

}
