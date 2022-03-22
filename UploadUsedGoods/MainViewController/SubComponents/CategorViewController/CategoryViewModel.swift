//
//  CategoryViewModel.swift
//  UploadUsedGoods
//
//  Created by 노민경 on 2022/03/21.
//

import RxSwift
import RxCocoa

struct CategoryViewModel {
    let disposeBag = DisposeBag()
    
    let cellData: Driver<[Category]>
    let pop: Signal<Void>
    
    // ViewModel -> View
    let itemSelected = PublishRelay<Int>() // 선택된 카테고리의 row 값
    
    // ViewModel -> Parents ViewModel
    let selectedCategory = PublishSubject<Category>() // MainViewController가 받아서 해당 카테고리를 표현할 수 있도록 전달
    
    init() {
        let categories = [
            Category(id: 1, name: "디지털/가전"),
            Category(id: 2, name: "게임"),
            Category(id: 3, name: "스포츠/레저"),
            Category(id: 4, name: "유아/아동용품"),
            Category(id: 5, name: "여성패션/잡화"),
            Category(id: 6, name: "뷰티/미용"),
            Category(id: 7, name: "남성패션/잡화"),
            Category(id: 8, name: "생활/식품"),
            Category(id: 9, name: "가구"),
            Category(id: 10, name: "도서/티켓/취미"),
            Category(id: 11, name: "기타")
        ]
        
        self.cellData = Driver.just(categories)
        
        self.itemSelected
            .map { categories[$0] }  // itemSelected는 맵핑해서 전달된 row에 해당하는 카테고리가 무엇인지로 변환
            .bind(to: selectedCategory) // bind해서 내보내줘야 하는 selectedCategory에 묶어줌 => 외부에서는 selectedCategory만 확인하면 최종적으로 선택된 최신의 카테고리를 알 수 있음
            .disposed(by: disposeBag)
        
        self.pop = itemSelected
            .map { _ in Void() } // 아이템이 선택되었을 때, row 값에 관계없이 void 값으로 전환
            .asSignal(onErrorSignalWith: .empty()) // signal 값으로 전환
    }
}
