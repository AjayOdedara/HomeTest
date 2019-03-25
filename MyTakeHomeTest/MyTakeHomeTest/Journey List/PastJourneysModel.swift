//
//  PastJourneysModel.swift
//  MyTakeHomeTest
//
//  Created by Ajay Odedra on 24/03/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import Foundation
import UIKit

class PastJourneysViewModel {
    
    enum WeatherCellData {
        case normal(modelData: [Run])
        case error(message: String)
    }
    
    var title: String{
        return "Past Journeys"
    }
    
    let reuseIdentifier = "PastJourneysCell"
    var responseData = Bindable([Run]())
    
    func cellInstance(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! JourneyTableViewCell
        cell.setup(self.responseData.value[indexPath.row])
        return cell
    }
    
}

