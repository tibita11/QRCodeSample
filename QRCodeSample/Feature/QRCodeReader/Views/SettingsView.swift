//
//  SettingsView.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/24.
//

import UIKit

class SettingsView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    func loadNib() {
        let view = Bundle.main.loadNibNamed("SettingsView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
}
