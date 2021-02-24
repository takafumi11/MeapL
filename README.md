 # MeapL

食事の思い出を記録するアプリ。

## 環境
・MacbookPro ver.10.15.7  
・Swift5  
・Xcode ver.12.3  
実機テスト  
・iPhone8 iOS 14.3  
・iPhone11 Pro iOS 14.3  


## 機能一覧
###  1.アプリ紹介のアニメーション  

Lottieを使用してアプリを紹介する簡単なアニメーションを作成した。  
###  2.匿名・emailログイン  
FirebaseAuthを使用して匿名ログインを実装した。  

### 3.AppleMapを使用
MapKitを使用してAppleMapを表示した。
また、任意の地名で検索しマップ上にピンを立てることが可能。
ピンをタップするとその場所がFirestoreに登録される。

### 4.思い出を記入
3で登録した場所に関して、メモ・写真と共に思い出を登録可能。
この際に端末のカメラ、アルバム起動。

### 5.TimeLine表示
4で登録した情報をTimeLineとして閲覧可能。

### 6.Firebaseログアウト  
FirebaseAuthのログアウト機能を実装した。

## 使用技術一覧

### CocoaPods
1. Firebase
1. Firebase/Auth
1. Firebase/FireStore
1. Firebase/Core
1. lottie-ios
1. ChameleonFramework
1. SDWebImage






