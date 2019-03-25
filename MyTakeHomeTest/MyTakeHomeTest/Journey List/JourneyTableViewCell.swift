//
//  JourneyTableViewCell.swift
//  MyTakeHomeTest
//
//  Created by Ajay Odedra on 24/03/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import UIKit

class JourneyTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(_ viewModel: Run) {
        self.selectionStyle = .none
        let formattedDate = FormatDisplay.date(viewModel.timestamp)
        let distance = Measurement(value: viewModel.distance, unit: UnitLength.meters)
        let formattedDistance = FormatDisplay.distance(distance)
        
        self.textLabel?.text = "🗓 \(formattedDate)"
        self.detailTextLabel?.text = "🏃‍♂️\(formattedDistance)"
        
    }
}

