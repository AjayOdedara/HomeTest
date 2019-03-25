//
//  JourneyViewController.swift
//  MyTakeHomeTest
//
//  Created by Ajay Odedra on 24/03/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import UIKit

class PastJourneysViewController: UIViewController {
    @IBOutlet var pastJourneysTableVew: UITableView!
    
    let viewModel: PastJourneysViewModel = PastJourneysViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Set up
        setUpUI()
        // Model Binding
        bindViewModel()
    }
    func setUpUI(){
        // TableView Init
        pastJourneysTableVew.delegate = self
        pastJourneysTableVew.dataSource = self
        pastJourneysTableVew.estimatedRowHeight = 90
        pastJourneysTableVew.rowHeight = UITableView.automaticDimension
        pastJourneysTableVew.tableFooterView = UIView()
        
    }
    func bindViewModel() {
        self.title = viewModel.title
        
        viewModel.responseData.value = CoreDataStack.retriveSaveContext()
        viewModel.responseData.bindAndFire() { [weak self] _ in
            self?.pastJourneysTableVew?.reloadData()
        }
        
    }
}

extension PastJourneysViewController: SegueHandlerType {
    enum SegueIdentifier: String {
        case details = "RunDetailsViewController"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifier(for: segue) {
        case .details:
            let destination = segue.destination as! RunDetailsViewController
            destination.run = viewModel.responseData.value[pastJourneysTableVew.indexPathForSelectedRow?.row ?? 0]
        }
    }
    
}

extension PastJourneysViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.responseData.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.cellInstance(tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pastJourneysTableVew.deselectRow(at: indexPath, animated: true)
    }
}
