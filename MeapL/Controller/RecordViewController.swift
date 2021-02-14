//
//  RecordViewController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/13.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import ChameleonFramework

class RecordViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var memoTextField: UITextView!
    @IBOutlet weak var somethingImageView: UIImageView!
    
    @IBOutlet weak var plusBtn: UIButton!
    
    var recordArr:[String] = []
    
    var cellCount:Int = 1
    
    var locationName:String = ""
    var recordTitle:String = ""
    var selectedImageData = Data()
    
    let collectionID = Auth.auth().currentUser!.uid
    var docID:String = ""
    var anotherDocID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
        datePicker.preferredDatePickerStyle = .wheels

        if locationName != nil{
            recordTitle = locationName
        }
        
        somethingImageView.isHidden = true
        
        memoTextField.layer.cornerRadius = 20.0
        memoTextField.textColor = .black
        
        view.backgroundColor = UIColor.flatWhite()
        
        bgView.layer.cornerRadius = 20.0
        
        
        dateTextField.delegate = self
        memoTextField.delegate = self
                
        navigationItem.title = recordTitle
        
        navigationController?.navigationBar.tintColor = UIColor.flatWatermelon()
        self.navigationController?.navigationBar.titleTextAttributes = [
            // 文字の色
                .foregroundColor: UIColor.flatWatermelon()]
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dateTextField.resignFirstResponder()
        memoTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dateTextField.resignFirstResponder()
    }

    @IBAction func setImage(_ sender: Any) {
        //１枚目の写真追加
        //plusBtn
        showActionSheet()
    }
    
    
    @IBAction func resetImage(_ sender: Any) {
        //写真の変更
        //画像タッチ
        showActionSheet()
    }
    
    //albumから写真を選択した場合の処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] as? UIImage != nil{
            
            let selectedImage = info[.originalImage] as! UIImage
            
            somethingImageView.image = selectedImage
            plusBtn.isHidden = true
            somethingImageView.isHidden = false
            picker.dismiss(animated: true, completion: nil)
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
        
    func editFirestore(){
        showActionSheet2()
    }
    
    func addData(){
        
        let docid = Firestore.firestore().collection(collectionID).document().path
        let from = docid.index(docid.startIndex, offsetBy:collectionID.count + 1)
        let to = docid.index(docid.startIndex, offsetBy:docid.count)
        let newString = String(docid[from..<to])
        
        anotherDocID = newString
        
        let data:Data = (somethingImageView.image?.jpegData(compressionQuality: 0.1))!
        Firestore.firestore().collection(collectionID).document(docID).collection(locationName).document(anotherDocID).setData(["date": Date().timeIntervalSince1970 ,"day" : dateTextField.text, "image" : data, "text" : memoTextField.text,"anotherDocID" : anotherDocID,"docID":docID], merge: true) { (error) in
            if error != nil{
                print(error)
            }
                    
        }
    }
    
    
    var datePicker: UIDatePicker = {
        let date = UIDatePicker()
        
        date.datePickerMode = .date
        date.timeZone = NSTimeZone.local
        date.locale = Locale.current
        
        
        return date
    }()
    
    func getInfo(){
        Firestore.firestore().collection(collectionID).addSnapshotListener() { [self] (snapShot, error) in
            
            if error != nil{
                print(error.debugDescription)
                return
            }
            
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    
                    if let location:String = data["location"] as? String,let docid = data["docID"]{
                                               
                        if recordTitle == location{
                            docID = docid as! String
                        }
                        
                    }
                }
            }
        }
    }
    
    @IBAction func register(_ sender: Any) {
        editFirestore()
    }
    
    @objc func done() {
       dateTextField.endEditing(true)

       // 日付のフォーマット
       let formatter = DateFormatter()

       //"yyyy年MM月dd日"を"yyyy/MM/dd"したりして出力の仕方を好きに変更できるよ
       formatter.dateFormat = "yyyy年MM月dd日"

       //(from: datePicker.date))を指定してあげることで
       //datePickerで指定した日付が表示される
       dateTextField.text = "\(formatter.string(from: datePicker.date))"

    }
    
    // ボタンが押された時に呼ばれるメソッド
    @objc func buttonEvent(_ sender: UIButton) {
                
        
    }
    
    @objc func expand(sender:UITapGestureRecognizer){
//        showActionSheet()
    }
    
    //端末のカメラを開く関数
    func openCamera(){
        let sourceType:UIImagePickerController.SourceType = .camera
        
        //カメラ利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraPicker = UIImagePickerController()
            
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    //アルバムを開く関数
    func openAlbum(){
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        
        //アルバムが 利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let cameraPicker = UIImagePickerController()
            
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    func showActionSheet(){
        let alertController = UIAlertController(title: "画像を選択します", message: "", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "カメラ", style: .default) { (alert) in
            self.openCamera()
        }
        let action2 = UIAlertAction(title: "アルバム", style: .default) { (alert) in
            self.openAlbum()
        }
        let action3 = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showActionSheet2(){
        let alertController = UIAlertController(title: "この内容で登録しますか？", message: "", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "登録する", style: .default) { (alert) in
            
            self.getInfo()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){ [self] in
                if somethingImageView.image != nil && memoTextField.text != nil && dateTextField.text != nil{
                    self.addData()
                    
                    self.alert(title: "登録完了!!", message: "", subtitle: "戻る")
                    dateTextField.text = ""
                    memoTextField.text = ""
                        
                    plusBtn.isHidden = false
                    somethingImageView.isHidden = true
                }else{
                    self.alert(title: "エラー", message: "空欄があります", subtitle: "記入する")
                }
            }
        }
   
        let action2 = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell",for: indexPath)
        
        tableView.rowHeight = view.frame.size.height*0.8 + 80
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    
}
