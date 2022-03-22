//
//  MainViewModel.swift
//  UploadUsedGoods
//
//  Created by 노민경 on 2022/03/21.
//

import Foundation
import RxSwift
import RxCocoa

struct MainViewModel {
    let titleTextFieldCellViewModel = TitleTextFieldCellViewModel()
    let priceTextFieldCellViewModel = PriceTextFieldCellViewModel()
    let detailWriteFieldCellViewModel = DetailWriteFormCellViewModel()
    
    // ViewModel -> View
    let cellData: Driver<[String]> // MainView가 가지고 있는 cellData
    let presentAlert: Signal<Alert> // Alert를 띄워야한다는 signal
    let push: Driver<CategoryViewModel> // 카테고리를 누르면 카테고리 디테일을 보여주는 viewcontroller로 푸시를 해줘야함. CategoryViewModel을 전달해서 binding 할 수 있게 해주는 드라이버
    
    // View -> ViewModel
    let itemSelected = PublishRelay<Int>()
    let submitButtonTapped = PublishRelay<Void>()
    
    init(model: MainModel = MainModel()) {
        let title = Observable.just("글 제목") // placeholder
        let categoryViewModel = CategoryViewModel()
        let category = categoryViewModel
            .selectedCategory
            .map { $0.name }
            .startWith("카테고리 선택")
        
        let price = Observable.just("₩ 가격 (선택사항)")
        let detail = Observable.just("내용을 입력하세요")
        
        // cellData로 넘겨줌
        self.cellData = Observable
            .combineLatest(title, category, price, detail) {
                [$0, $1, $2, $3] // array로 묶여서 전달됨
            }
            .asDriver(onErrorJustReturn: []) // 에러가 나면 빈 array
        
        // alert이 나타나는 시점
        // 제출 버튼을 누르면 나타나야 하는데, 어떠한 값이 비어있는지에 따라 alert의 내용이 달라짐
        let titleMesaage = titleTextFieldCellViewModel
            .titleText
            .map { $0?.isEmpty ?? true } // 입력한 값이 없으면 true
            .startWith(true) // 처음에는 아무런 값도 입력하지 않았을 것이기 때문에 true를 줌
            .map { $0 ? ["- 글 제목을 입력해주세요."] : [] } // true가 전달되었다면 : 충분히 값이 입력되었다면
        
        let categoryMesaage = categoryViewModel
            .selectedCategory
            .map { _ in false } // 선택된 카테고리가 있다면 아무런 메세지도 보여주지 않을 것
            .startWith(true)
            .map { $0 ? ["- 카테고리를 선택해주세요."] : [] }
        
        let detailMesaage = detailWriteFieldCellViewModel
            .contentValue
            .map { $0?.isEmpty ?? true }
            .startWith(true)
            .map { $0 ? ["- 내용을 입력해주세요."] : [] }
        
        // 가장 최신의 에러 메세지들을 합침
        let errorMessage = Observable
            .combineLatest(titleMesaage, categoryMesaage, detailMesaage) { $0 + $1 + $2 }
        
        // 제출 버튼을 탭했을 때만 현재 입력된 상태를 봐여하므로 submitButtonTapped을 트리거로 함
        self.presentAlert = submitButtonTapped
            .withLatestFrom(errorMessage)
            .map(model.setAlert)
            .asSignal(onErrorSignalWith: .empty())
        
        // 카테고리 선택을 눌렀을 때만 푸시가 되어야 함 => filtering 필요
        self.push = itemSelected
            .compactMap { row -> CategoryViewModel? in
                guard case 1 = row else {
                    return nil
                }
                return categoryViewModel
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
