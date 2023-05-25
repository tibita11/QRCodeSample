//
//  ListViewController.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/11.
//

import UIKit
import RxSwift
import RxCocoa

class QRCodeListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let viewModel = QRCodeListViewModel()
    private let disposeBag = DisposeBag()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
    

    // MARK: - Action
    
    private func setUp() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // TableViewとバインド
        viewModel.output.listObserver
            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { row, element, cell in
                var config = cell.defaultContentConfiguration()
                config.text = element.title
                cell.contentConfiguration = config
            }
            .disposed(by: disposeBag)
        // DB取得が流れてしまうためバインド後に処理する
        viewModel.setUp()
    }
}
