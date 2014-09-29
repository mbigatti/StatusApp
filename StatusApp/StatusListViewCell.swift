//
//  StatusTableViewCell.swift
//  StatusApp
//
//  Created by Massimiliano Bigatti on 23/07/14.
//  Copyright (c) 2014 Massimiliano Bigatti. All rights reserved.
//

import UIKit

/**
 Status Entry cell
 */
class StatusListViewCell: UITableViewCell {
    
    /// reference to title label
    @IBOutlet private var titleLabel: UILabel?
    
    /// reference to notes label
    @IBOutlet private var notesLabel: UILabel?
    
    /// reference to last update timestamp label
    @IBOutlet private var lastUpdatedLabel: UILabel?

    /// formatted used to populate the last update timestamp label
    private var dateFormatter = NSDateFormatter()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit();
    }
    
    /// common initializer
    private func commonInit() {
        let currentLocale = NSLocale.currentLocale()
        
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("dd MMM hh:mm", options: 0, locale: currentLocale)
        dateFormatter.locale = currentLocale
        
        contentView.backgroundColor = UIColor.clearColor()
        backgroundView = GradientView()
        selectedBackgroundView = GradientView()
    }
    
    /**
     Configure the cell for the specified entry.
     :param: statsEntry entry to use to configure the cell
     */
    func configureForStatusEntity(statusEntity: StatusEntity) {
        titleLabel!.text = statusEntity.title
        notesLabel!.text = statusEntity.notes
        lastUpdatedLabel!.text = dateFormatter.stringFromDate(statusEntity.lastUpdateDate)
        
        backgroundView?.backgroundColor = statusEntity.color.color()
        selectedBackgroundView?.backgroundColor = statusEntity.color.color().darkerColor(0.1)
    }

}
