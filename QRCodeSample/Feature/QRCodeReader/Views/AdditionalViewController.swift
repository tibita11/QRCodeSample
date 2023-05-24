//
//  AdditionalViewController.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/23.
//

import UIKit

class AdditionalViewController: UIViewController {

    @IBOutlet weak var valueLabel: UILabel!
    let valueString: String!
    
    init(value: String) {
        self.valueString = value
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valueLabel.text = valueString
    }
    
}
