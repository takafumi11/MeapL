//
//  AppleMapViewController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/17.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import ChameleonFramework

protocol HandMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class AppleMapViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    var selectedPin: MKPlacemark? = nil
    var resultSearchController: UISearchController? = nil
    let locationManager = CLLocationManager()
    
    let regionRadius:CLLocationDistance = 1000
    
    var collectionID:String = ""
    var docID:String = ""
    var locationArr:[String] = []
    
    var isAlertIssued:Bool = false
    
    override func viewDidLoad() {
                
        super.viewDidLoad()
        
        collectionID = Auth.auth().currentUser!.uid
        
        checkLocationServices()
        
        mapView.delegate = self
         
        UITabBar.appearance().tintColor = UIColor.flatWatermelon()
        
        //以下UISearchControllerの設定
        let locationSearchTable = storyboard?.instantiateViewController(identifier: "LocationSearch") as! LocationSearchViewController
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as! UISearchResultsUpdating
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
     
        //以下検索窓の設定
        let searchBar = resultSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search for places"
        self.navigationItem.titleView = resultSearchController?.searchBar

        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    //以下4つ位置情報の確認とmapの表示
    func setupLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            //userの現在地表示
            mapView.showsUserLocation = true
             
            centerMapOnLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            print("位置情報が許可されていません")
            break
        case .notDetermined:
            //位置情報の許可を求める
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //制限
            break
        case .authorizedAlways:
            break
        }
    }
    
    //最初にこれが呼ばれる
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        }
    }
     
    func centerMapOnLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location,latitudinalMeters: regionRadius,longitudinalMeters: regionRadius)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        showActionSheet()
    }
    
    func showActionSheet(){
        let alertController = UIAlertController(title: "選択", message: "この場所を登録しますか?", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "登録する", style: .default) { (alert) in
            
            self.checkLocation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                self.registerLocationINformation()
            }
        }

        let action2 = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func checkLocation(){
        
        locationArr = []
        isAlertIssued = false
        
        Firestore.firestore().collection(collectionID).addSnapshotListener() { [self] (snapShot, error) in

            if error != nil{
                print(error.debugDescription)
                return
            }

            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()

                    if let location = data["location"]{

                        self.locationArr.append(location as! String)

                    }
                }
            }

            //Firestoreにデータが存在する場合
            if locationArr.count > 0{
                for i in 0...self.locationArr.count-1{
                    if self.locationArr[i] == self.resultSearchController?.searchBar.text!{

                        isAlertIssued = true
                        return
                    }
                }
            }
        }
    }
    
    func registerLocationINformation(){
        //true(すでに登録されている)時は通さない
        guard !isAlertIssued  else {
            let title = "エラー"
            let message = "このLocationは既に登録されています...."
            let subtitle = "戻る"
            self.alert(title: title, message: message, subtitle: subtitle)

            return
        }

        let docid = Firestore.firestore().collection(collectionID).document().path
        let from = docid.index(docid.startIndex, offsetBy:collectionID.count + 1)
        let to = docid.index(docid.startIndex, offsetBy:docid.count)
        let newString = String(docid[from..<to])

        //ここで取得しておかないと後で書き換えるときにdocumentの指定ができない
        docID = newString

        Firestore.firestore().collection(collectionID).document(docID).setData( ["location":resultSearchController?.searchBar.text,"date":Date().timeIntervalSince1970,"docID":docID]) { [self] (error) in
            if error != nil{
                print(error)
            }else{
                let title = "登録完了しました!!"
                let message = ""
                let subtitle = "戻る"
                self.alert(title: title, message: message, subtitle: subtitle)
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

//LocationSearchVCからprotocolを受け取りannotationを表示する
extension AppleMapViewController: HandMapSearch{
    func dropPinZoomIn(placemark: MKPlacemark) {
        selectedPin = placemark
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        resultSearchController?.searchBar.text = placemark.name
        
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
