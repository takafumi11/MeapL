//
//  MapViewController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/13.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import FirebaseFirestore
import FirebaseAuth
import ChameleonFramework

struct MyPlace {
    var name: String
    var lat: Double
    var long: Double
}

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    
    
    let currentLocationMarker = GMSMarker()
    var locationManager = CLLocationManager()
    var chosenPlace: MyPlace?
    
    var locationArr:[String] = []
    
    let collectionID = Auth.auth().currentUser!.uid
    var docID:String = ""
    
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    
    var isAlertIssued:Bool = false
    var isClosureCaller:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Home"
        self.view.backgroundColor = UIColor.white
        myMapView.delegate=self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        setupViews()
        
        initGoogleMaps()
        
        txtFieldSearch.delegate=self
        
        UITabBar.appearance().tintColor = UIColor.flatWatermelon()
        
    }
    
    let txtFieldSearch: UITextField = {
        let tf=UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .white
        tf.layer.borderColor = UIColor.darkGray.cgColor
        tf.placeholder="Search for a location"
        tf.translatesAutoresizingMaskIntoConstraints=false
        return tf
    }()
    
    //検索窓を押した瞬間に画面遷移
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        txtFieldSearch.text = ""
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        autoCompleteController.autocompleteFilter = filter
        
        self.locationManager.startUpdatingLocation()
        autoCompleteController.modalPresentationStyle = .fullScreen
        self.present(autoCompleteController, animated: true, completion: nil)
        return false
    }
    
    //画面遷移先のVC...検索して場所の選択後
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17.0)
        myMapView.camera = camera
        
        txtFieldSearch.text=place.name
        chosenPlace = MyPlace(name: place.formattedAddress!, lat: lat, long: long)
        
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = "\(place.name!)"
    
        marker.map = myMapView

        self.dismiss(animated: true, completion: nil) // dismiss after place selected
                
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
                
        showActionSheet(location: txtFieldSearch.text!)
        
        return true
    }

    func showActionSheet(location:String){
        let alertController = UIAlertController(title: "選択", message: "この場所を登録しますか?", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "登録する", style: .default) { (alert) in
            
            self.checkLocation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.registerLocationINformation()
            }
            
        }

        let action2 = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func registerLocationINformation(){
        
        //trueの時は通さない
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

        Firestore.firestore().collection(collectionID).document(docID).setData( ["location":txtFieldSearch.text,"date":Date().timeIntervalSince1970,"docID":docID]) { [self] (error) in
            if error != nil{
                print(error)
                print("ミスったよ")
            }else{
                let title = "登録完了しました!!"
                let message = ""
                let subtitle = "戻る"
                self.alert(title: title, message: message, subtitle: subtitle)
            }
        }
    }

    //入力されたemailが存在するかのcheckをする。
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
             
            
            if locationArr.count > 1{
                for i in 0...self.locationArr.count-1{
                    if self.locationArr[i] == self.txtFieldSearch.text!{
                        
                        isAlertIssued = true
                        return
                    }
                }
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
    
    func setupTextField(textField: UITextField, img: UIImage){
        textField.leftViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        imageView.image = img
        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        paddingView.addSubview(imageView)
        textField.leftView = paddingView
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let myMapView: GMSMapView = {
        let v=GMSMapView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let btnMyLocation: UIButton = {
        let btn=UIButton()
        btn.backgroundColor = UIColor.white
        btn.setImage(#imageLiteral(resourceName: "my_location"), for: .normal)
        btn.layer.cornerRadius = 25
        btn.clipsToBounds=true
        btn.tintColor = UIColor.gray
        btn.imageView?.tintColor=UIColor.gray
        btn.addTarget(self, action: #selector(btnMyLocationAction), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: 28.7041, longitude: 77.1025, zoom: 17.0)
        self.myMapView.camera = camera
        self.myMapView.delegate = self
        self.myMapView.isMyLocationEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        let location = locations.last
        let lat = (location?.coordinate.latitude)!
        let long = (location?.coordinate.longitude)!
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17.0)
        
        self.myMapView.animate(to: camera)
        
//        showPartyMarkers(lat: lat, long: long)
    }
    
    @objc func btnMyLocationAction() {
        let location: CLLocation? = myMapView.myLocation
        if location != nil {
            myMapView.animate(toLocation: (location?.coordinate)!)
        }
    }
   
    func setupViews() {
        view.addSubview(myMapView)
                        
        myMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive=true
        myMapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive=true
        myMapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive=true
        myMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:0).isActive=true
        
        self.view.addSubview(txtFieldSearch)
        txtFieldSearch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive=true
        txtFieldSearch.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        txtFieldSearch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        txtFieldSearch.heightAnchor.constraint(equalToConstant: 35).isActive=true
        setupTextField(textField: txtFieldSearch, img: #imageLiteral(resourceName: "map_Pin"))
        
        
        self.view.addSubview(btnMyLocation)
        btnMyLocation.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90).isActive=true
        btnMyLocation.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive=true
        btnMyLocation.widthAnchor.constraint(equalToConstant: 50).isActive=true
        btnMyLocation.heightAnchor.constraint(equalTo: btnMyLocation.widthAnchor).isActive=true
        
    }
    
}
