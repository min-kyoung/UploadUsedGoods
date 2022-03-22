//
//  PriceTextFieldCellViewModel.swift
//  UploadUsedGoods
//
//  Created by 노민경 on 2022/03/22.
//


// 가격을 0 혹은 입력하지 않을 경우 '무료나눔' 버튼이 뜨게 함 => 버튼을 보여주어야 한다는 이벤트가 필요, x를 누르면 그 버튼이 사라져야 하는 이벤트 필요
// 얼마인지 가격을 표시하는 것 자체가 전달되어야 하는 이벤트 필요
// 제출 -> 확인을 누르면 가격이 리셋되어야 함 => 리셋 가격 이벤트도 전달받음
import RxSwift
import RxCocoa

struct PriceTextFieldCellViewModel {
    // ViewModel -> View
    let showFreeShareButton: Signal<Bool>
    let resetPrice: Signal<Void>
    
    // View -> ViewModel
    let priceValue = PublishRelay<String?>()
    let freeShareButtonTapped = PublishRelay<Void>()
    
    init() {
        self.showFreeShareButton = Observable
            .merge(
                priceValue.map { $0 ?? "" == "0" },
                freeShareButtonTapped.map { _ in false } // 버튼을 누를 경우 숨김
            )
            .asSignal(onErrorJustReturn: false)
        
        // 무료나눔 버튼이 선택되면 가격 리셋
        self.resetPrice = freeShareButtonTapped
            .asSignal(onErrorSignalWith: .empty())
    }
}
