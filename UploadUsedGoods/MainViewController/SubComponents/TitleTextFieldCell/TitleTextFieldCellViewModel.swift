//
//  TitleTextFieldCellViewModel.swift
//  UploadUsedGoods
//
//  Created by 노민경 on 2022/03/21.
//


// 타이틀을 입력할 수 있는 UITextField가 필요
// UITextField에 입력되는 text 값을 부모뷰로 전달
    // "제출" 버튼이 눌렸을 때 가장 최근의 값이 입력된 상태인지를 볼 것
import RxCocoa

struct TitleTextFieldCellViewModel {
    let titleText = PublishRelay<String?>()
}


