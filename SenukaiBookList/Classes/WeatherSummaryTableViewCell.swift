//
//  WeatherSummaryTableViewCell.swift
//  djweatherisk
//
//  Created by Darius Jankauskas on 17/05/2017.
//  Copyright © 2017 Darius Jankauskas. All rights reserved.
//

import UIKit

class WeatherSummaryTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!

    func setup(_ viewModel: WeatherSummaryViewModel) {
        summaryLabel.text = viewModel.summary
        iconImageView.image = viewModel.picture
    }
    
}
