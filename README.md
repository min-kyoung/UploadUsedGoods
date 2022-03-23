# UploadUsedGoods
## Description
* 각각의 내용을 하나로 합쳐 어떠한 API로 전달하는 것을 가정하여 중고거래 물건 올리기 화면을 구현한다.
* RxSwift와 RxCocoa를 사용하여 MVVM 구조로 작성한다.
  #### 구현화면
  <br> <img src="https://user-images.githubusercontent.com/62936197/159731319-a6958b2e-46f7-427c-bada-bce58ca6f5d3.png" width="150" height="320"> 　
  <img src="https://user-images.githubusercontent.com/62936197/159731323-4e79ab10-85a6-43d8-b7d6-e0691a9c3eac.png" width="150" height="320"> 　
  <img src="https://user-images.githubusercontent.com/62936197/159733469-cc7db84a-cef3-48a0-9218-5fabe80d306c.png" width="150" height="320"> <br>
## Prerequisite
* XCode Version 13.2.1에서 개발을 진행한다
* 스토리보드를 사용하지 않기 위한 초기 셋팅이 필요하다.
  1. Main.storyboard를 삭제한다.
  2. info.plist에 있는 Main.storyboard와 관련된 항목을 삭제한다.
     <img src="https://user-images.githubusercontent.com/62936197/149618014-9c2a58e8-9bb7-49f7-8552-1f381a08b63a.png" width="700" height="130">
     <img src="https://user-images.githubusercontent.com/62936197/149618059-abea1cef-5272-4abf-bfa2-ae300ab9def0.png" width="700" height="20">
  3. ViewController의 이름을 MainViewController 변경하여 사용한다.
  4. SceneDelegate에서 생성할 ViewController가 나타날 수 있도록 설정한다.
      ```swift
      class SceneDelegate: UIResponder, UIWindowSceneDelegate {
          var window: UIWindow?
          let rootViewModel = MainViewModel()

          func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
              guard let windowScene = (scene as? UIWindowScene) else { return }
              self.window = UIWindow(windowScene: windowScene)
        
              let rootViewController = MainViewController()
              rootViewController.bind(rootViewModel)
        
              window?.rootViewController = UINavigationController(rootViewController: rootViewController)
              window?.makeKeyAndVisible()
          }
      }
      ```
* openAPI를 설치한다. 
  * UI를 쉽기 그리기 위해 SnapKit을 설치하고 RxSwift와 RxCocoa를 사용하기 위해 RxSwift를 설치한다.
  * **File > Add Packages**에서 아래 openAPI를 설치한다.
     ```
     https://github.com/SnapKit/SnapKit.git
     github.com/ReactiveX/RxSwift.git
     ```
## Usage
### RxCocoa
* Cocoa Framework를 Rx로 감싼 RxSwift 기반으로 만들어진 라이브러리이다.
* 서로 다른 클래스에서 비동적으로 발생하는 값을 기존 애플의 API가 제공하는 방식으로 조합하고 전달하려면 복잡하다. 이 때 Rx를 이용하면 명시적이고 간단하게 작성이 가능하다. 
#### Binder
* **.bind(to: )** : 생성자는 값을 만들어내고 수신자는 만들어 놓은 값을 처리한다.
* 수신자는 값을 반환할 수 없는 단방향 데이터 스트림이고, 이는 앱의 데이터 흐름을 크게 단순화하는 하나의 방법이다.
* Observable을 다른 속성에 binding하기 위해서는 데이터 수신자가 Observable 타입이어야 한다.
* Error 이벤트를 받지 않는다.
* binding이 성공하면 UI가 업데이트될 텐데 UI 업데이트는 Main Thread에서만 이루어져야 하므로 Main Thread에서 실행되는 것을 보장한다.
  ```swift
  private func bind() {
          sortButton.rx.tap // 탭되었다는 이벤트를 방출하면
              .bind(to: sortButtonTapped) // sortButtonTapped라는 PublishRelay로 binding
              .disposed(by: disposeBag)
  }
  ```
#### Traits
* **Driver** : 새로운 구독자에게 구독하는 순간 초기값이나 최신값을 준다.
* **Signal** : 구독한 이후에 발생하는 값만 전달한다.
* 에러를 방출하지 않는 특별한 Observable
* 모든 과정은 Main Thread에서 이루어진다.
* 구독자가 생길 때마다 스트림을 새로 만드는 것이 아니라 스트림 공유를 할 수 있어 resource 낭비를 줄일 수 있다.
  ```swift
  // searchButtonTapped 이벤트가 발생할 때는 서치바 기준으로 endEditing을 인지할 수 있도록 함
  searchButtonTapped
       .asSignal()
       .emit(to: self.rx.endEditing) // 탭 이벤트가 발생했을 때 endEditing 발현
       .disposed(by: disposeBag)
  ```
### MVVM 
#### 기존에 사용하던 MVC 패턴 구조
* 앱을 개발할 때 Model, View, Controller 3가지 역할을 나누어 개발을 진행한다.
* 각각의 객체가 앱에서 수행하는 역할을 정의하고, 이들이 서로 통신하는 방식을 정의한다.
* 각 객체는 추상적으로 다른 유형과 분리되고, 이러한 경계를 넘어서 다른 유형의 객체와 통신한다.
    #### 한계점
    * Cocoa Framework에서는 View와 Controller를 완벽히 분리하여 개발하기 어렵다.
    * UIViewController도 자신의 View를 가지고 있고 온전한 형태의 controller의 역할을 하지 못한다.
#### MVVM 구조
* Model, View, ViewModel 3가지로 이루어져 있다.
* View에 해당하는 UIView와 UIViewController는 각자의 ViewModel을 소유하고 있다.
* View가 소유한 ViewModel은 View와 binding 되어서 데이터나 사용자 액션을 주고받게 된다.
* ViewModel은 자신의 Model을 가질 수 있으며, View로부터 받은 데이터나 사용자 액션을 Model을 통해서 비지니스 로직을 처리한다.
* ViewModel과 이 ViewModel이 소유한 Model을 통해 처리한 결과는 binding된 View에 어떠한 데이터의 형태로 전달될 것이고, 전달된 데이터는 어떠한 형태로든 View에 업데이트 된다.
    #### 장점
    * 양방향으로 개발이 불가능한 것은 아니나, 단방향으로 개발이 용이하기 때문에 불필요한 부수작용을 최소화할 수 있다. 
    * View의 상태와 동작을 추상화한 형태로 하나의 View는 해당 View의 로직을 담당하는 Model이 대응하게 된다. <br>
      이로써 순수한 비즈니스 로직은 ViewModel에게 넘기고View는 그 ViewModel이 처리한 결과를 UI로 반영하기만 하면 된다. <br> 다시 말해 순수한 View의 역할을 할 수 있다.
    * View가 ViewModel을 소유하는 형태이기 때문에 ViewModel은 자기를 소유한 View를 몰라도 된다.
    #### RxSwift 사용
    * View와 ViewModel을 bind하는 접착제로 RxSwift를 사용할 수 있다.
    * View를 통해 발생하는 사용자 입력에 의해 수행되는 일련의 과정들은 Observable을 통해 구현해서 해당 View에 소유된 ViewModel은 이러한 View의 Observable을 subscribe하는 형태로 만들 수 있다.
    * 또한 ViewModel에서의 stream 연산은 Observable의 Operator를 통해 해결해서 많은 코드양을 줄이고 Operator에 통합하여 가독성을 올릴 수 있다.
