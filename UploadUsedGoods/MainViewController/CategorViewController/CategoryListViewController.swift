//
//  CategoryListViewController.swift
//  UploadUsedGoods
//
//  Created by 노민경 on 2022/03/21.
//

import UIKit
import RxSwift
import RxCocoa

class CategoryListViewController: UIViewController {
    let disposeBag = DisposeBag()
    let tableView = UITableView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: CategoryViewModel) {
        viewModel.cellData
            .drive(tableView.rx.items) { tv, row, data in
                let cell = tv.dequeueReusableCell(withIdentifier: "CategoryListCell", for: IndexPath(row: row, section: 0)) // indexPath에 row 값만 전달 (섹션 1개)
                
                cell.textLabel?.text = data.name // 카테고리의 이름을 뿌려줌
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.pop
            .emit(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true) // pop이벤트를 받았을 때 onNext 안의 내용이 실행됨
            })
            .disposed(by: disposeBag)
        
        // itemSelected를 받을 수 있도록 bind
        tableView.rx.itemSelected
            .map { $0.row } // itemSelected은 IndexPath 전체를 주나, row 값만 있으면 되기 때문에 map을 통해 row 값만 받음
            .bind(to: viewModel.itemSelected)
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        view.backgroundColor = .systemBackground
        
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryListCell")
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
    }
    
    private func layout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
