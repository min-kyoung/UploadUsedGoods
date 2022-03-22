//
//  DetailWriteFormCellViewModel.swift
//  UploadUsedGoods
//
//  Created by 노민경 on 2022/03/22.
//

import RxSwift
import RxCocoa

struct DetailWriteFormCellViewModel {
    // View -> ViewModel
    let contentValue = PublishRelay<String?>()
}
