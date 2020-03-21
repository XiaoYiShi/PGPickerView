//
//  PGPickerTableView.swift
//  PickerViewDemo
//
//  Created by 史晓义 on 2020/3/10.
//  Copyright © 2020 piggybear. All rights reserved.
//

import UIKit

@objc class PGPickerTableView: UITableView
{
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.tableFooterView = UIView()
        self.separatorStyle = .none
        self.backgroundColor = .clear
        self.scrollsToTop = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private let kContentFont:CGFloat = 17

@objc class PGPickerColumnCell: UITableViewCell
{
    @objc lazy var label: UILabel = {
        let label = UILabel.init(frame: self.contentView.bounds)
        label.font = UIFont.systemFont(ofSize: kContentFont)
        label.textAlignment = .center
        self.contentView.addSubview(label)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc(transformWith:scale:)
    func transformWith(angle:CGFloat,scale:CGFloat)
    {
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, angle, 1, 0, 0)
        transform = CATransform3DScale(transform, scale, scale, scale);
        self.layer.transform = transform
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = self.contentView.bounds
    }
    
}
