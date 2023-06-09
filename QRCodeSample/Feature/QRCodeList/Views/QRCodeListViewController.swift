//
//  ListViewController.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/11.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class QRCodeListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton! {
        didSet {
            editButton.layer.cornerRadius = 15
        }
    }
    private let viewModel = QRCodeListViewModel()
    private let disposeBag = DisposeBag()
    let dataSources = RxTableViewSectionedReloadDataSource<SectionOfItemData>(configureCell: { dataSource, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        cell.contentConfiguration = config
        return cell
    }, canEditRowAtIndexPath: { dataSource, indexPath in
        return true
    }, canMoveRowAtIndexPath: { dataSource, indexPath in
        return true
    })

    
    
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
            .bind(to: tableView.rx.items(dataSource: dataSources))
            .disposed(by: disposeBag)
        // 削除
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.delete(at: indexPath.row)
            })
            .disposed(by: disposeBag)
        // 移動
        tableView.rx.itemMoved
            .subscribe(onNext: { [weak self] sourceIndexPath, destinationIndexPath in
                self?.viewModel.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
            })
            .disposed(by: disposeBag)
        // DB取得が流れてしまうためバインド後に処理する
        viewModel.setUp()
    }
    
    @IBAction func tapEditButton(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
    }
    
}
