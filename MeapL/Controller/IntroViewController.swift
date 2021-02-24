//
//  IntroViewController.swift
//  MeapL
//
//  Created by 野入隆史 on 2021/02/14.
//

import UIKit
import Lottie
import Firebase
import FirebaseAuth
import ChameleonFramework

class IntroViewController: UIViewController,UIScrollViewDelegate {

    var animationArray = ["swipeToLeft","hello","map","list","timeline",""]
    var animationTextArray = ["左にスワイプしてね!!","こんにちは!!\nこのアプリの紹介をするよ!","まずMap画面から場所を登録して、","List画面で詳細を登録しよう!!","TimeLineで一覧が見れるよ",""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        
        scrollView.isPagingEnabled = true
        
        setUpScroll()
        playAnimation()
    }

    var scrollView:UIScrollView = {
        let sv = UIScrollView()
        
        sv.translatesAutoresizingMaskIntoConstraints=false
        return sv
    }()
    
    func setupViews() {
        view.addSubview(scrollView)
                        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive=true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive=true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive=true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:0).isActive=true
        
    }
    
    func setUpScroll(){
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 6, height: UIScreen.main.bounds.height)
        
        for i in 0...5{
            //文字の高さ
            let animationTextLabel = UILabel(frame: CGRect(x: UIScreen.main.bounds.width * CGFloat(i), y: UIScreen.main.bounds.height / 20 * 10, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 3 / 5))
            
            
            //animatinではなく、開始ボタンを表示
            if i == 5{
                           
                var startBtn = UIButton(frame: CGRect(x: Int(UIScreen.main.bounds.width)*51/10, y:Int(UIScreen.main.bounds.height*0.5) , width: Int(UIScreen.main.bounds.width*0.8), height: 50))
                       
                startBtn.backgroundColor = .black
                startBtn.setTitle("Let's get started", for: .normal)
                startBtn.setTitleColor(.white, for: .normal)
                startBtn.backgroundColor = UIColor.flatWatermelon()
                startBtn.addTarget(self, action: #selector(tapBtn(_:)), for: UIControl.Event.touchUpInside)
                scrollView.addSubview(startBtn)
            }
            
            animationTextLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
            animationTextLabel.textAlignment = .center
            animationTextLabel.text = animationTextArray[i]
            animationTextLabel.numberOfLines = 2
            scrollView.addSubview(animationTextLabel)
        }
    }
    
    func playAnimation(){
        for i in 0...4{
            let animationView = AnimationView()
            let animation = Animation.named(animationArray[i])
            animationView.animation = animation
            animationView.frame = CGRect(x: CGFloat(i) * UIScreen.main.bounds.width, y: UIScreen.main.bounds.height / 50 * 10, width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height / 3)
            animationView.contentMode = .scaleAspectFill
            animationView.loopMode = .loop
            
            animationView.play()
            
            scrollView.addSubview(animationView)
        }
    }
    
    @objc func tapBtn(_ : UIButton){
        Auth.auth().signInAnonymously { (result, error) in
            if error != nil{
                print(error.debugDescription)
            }else{
                print("ログインに成功しました!!!")
                
                self.performSegue(withIdentifier: "map", sender: nil)
            }
        }
    }
    
    
}
