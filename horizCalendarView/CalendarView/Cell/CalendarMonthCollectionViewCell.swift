//
//  CalendarMonthCollectionViewCell.swift
//  horizCalendarView
//
//  Created by LinZheHao on 2024/1/24.
//

import UIKit

class CalendarMonthCollectionViewCell: UICollectionViewCell {
    
    /// yyyy年MM月
    var monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        label.textColor = UIColor.black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        contentView.addSubview(monthLabel)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            monthLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            monthLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
        ])
    }
    
}
