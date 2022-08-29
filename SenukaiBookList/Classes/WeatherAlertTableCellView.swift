//
//  WeatherAlertTableCellView.swift
//  djweatherisk
//
//  Created by Darius Jankauskas on 18/05/2017.
//  Copyright © 2017 Darius Jankauskas. All rights reserved.
//

import UIKit

class WeatherAlertTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func setup(_ viewModel: WeatherAlertSummaryViewModel) {
        titleLabel.text = viewModel.title
        timeLabel.text = viewModel.time
    }
    
}

