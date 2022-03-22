//
//  PriceTextFieldCell.swift
//  UploadUsedGoods
//
//  Created by 노민경 on 2022/03/22.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PriceTextFieldCell: UITableViewCell {
    let disposeBag = DisposeBag()
    let priceInputField = UITextField()
    let freeShareButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: PriceTextFieldCellViewModel) {
        viewModel.showFreeShareButton
            .map { !$0 } // 뒤집음
            .emit(to: freeShareButton.rx.isHidden) // freeShareButton의 isHidden에 묶어줌
            // => '보여줘'가 들어오면 true 값을 false로 바꾸고 isHidden이 false가 되어서 보여주게 됨
            .disposed(by: disposeBag)
        
        viewModel.resetPrice
            .map { _ in "" } // 빈 값으로 바꿈
            .emit(to: priceInputField.rx.text) // priceInputField의 textField에 묶어줌
            // => 어떠한 가격이 적혀있더라도 빈 값으로 전환
            .disposed(by: disposeBag)
        
        // View -> ViewModel
        priceInputField.rx.text
            .bind(to: viewModel.priceValue)
            .disposed(by: disposeBag)
        
        freeShareButton.rx.tap
            .bind(to: viewModel.freeShareButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        freeShareButton.setTitle("무료나눔 ", for: .normal)
        freeShareButton.setTitleColor(.orange, for: .normal)
        freeShareButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        freeShareButton.titleLabel?.font = .systemFont(ofSize: 18)
        freeShareButton.tintColor = .orange
        freeShareButton.backgroundColor = .white
        freeShareButton.layer.borderColor = UIColor.orange.cgColor
        freeShareButton.layer.borderWidth = 1.0
        freeShareButton.layer.cornerRadius = 10.0
        freeShareButton.clipsToBounds = true
        freeShareButton.isHidden = true
        freeShareButton.semanticContentAttribute = .forceRightToLeft
        
        priceInputField.keyboardType = .numberPad // 가격을 입력하는 셀이므로 numberPad로 설정
        priceInputField.font = .systemFont(ofSize: 17)
    }
    
    private func layout() {
        [priceInputField, freeShareButton].forEach {
            contentView.addSubview($0)
        }
        
        priceInputField.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        
        freeShareButton.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview().inset(15)
            $0.width.equalTo(100)
        }
    }
}
