//
//  CalendarDaysCollectionViewCell.swift
//  horizCalendarView
//
//  Created by LinZheHao on 2024/1/23.
//

import UIKit

extension UICollectionView {

    /// 註冊 cell xib
    /// - Parameters:
    ///   - identifier: cell 名稱
    ///   - bundle:  一般為 nil
    func registerCellWithNib(identifier: String, bundle: Bundle?) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    /// 註冊 header, footer cell xib
    /// - Parameters:
    ///   - identifier: cell 名稱
    ///   - bundle:  一般為 nil
    func registerReusableViewWithNib(identifier: String, bundle: Bundle?) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }
}

extension UICollectionViewCell {
    
    /// 取得 cell 名稱
    static var identifier: String {
        return String(describing: self)
    }
}

class CalendarDaysCollectionViewCell: UICollectionViewCell {

    /// 天數 Label
    @IBOutlet weak var dayLabel: UILabel!
    /// 中間 Label
    @IBOutlet weak var subInfoLabel: UILabel!
    /// 底下 Label
    @IBOutlet weak var thrInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    /// 設置 cell 內容
    func setup() {
        
    }
}
