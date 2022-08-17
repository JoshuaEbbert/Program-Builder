//
//  TableViewController.swift
//  Program Builder
//
//  Created by Adam Grow on 8/11/22.
//

import UIKit

class TableViewController: UITableViewController {
    var programItems: ProgramItems!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        programItems = ProgramItems()
        
        if let savedItems = defaults.object(forKey: "AllItems") as? [[String]] {
            programItems.allItems = savedItems
        } else {
            programItems.allItems = [["Sacrament Meeting"],
                                     ["Presiding: (Tap to edit)", "Conducting: (Tap to edit)", "Piano: (Tap to edit)", "Chorister: (Tap to edit)"],
                                     ["Opening Hymn: (Tap to edit)", "Opening Prayer: (Tap to edit)", "Announcements", "Sacrament Hymn: (Tap to edit)", "Sacrament", "Opening Speaker: (Tap to edit)", "Intermediate Hymn: (Tap to edit)", "Closing Speaker: (Tap to edit)", "Closing Prayer: (Tap to edit)"],
                                     []
                                     ]
        }
        
        programItems.tableViewController = self
        title = "Build Program"
        self.tableView.delegate = programItems
        self.tableView.dataSource = programItems
        self.tableView.reloadData()
        
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptSelection)), UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetToDefault))]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(programItems.allItems, forKey: "AllItems")
    }
    
    func getNewText(for indexPath: IndexPath) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in self?.tableView.deselectRow(at: indexPath, animated: true) }
        tableView.deselectRow(at: indexPath, animated: true)
        let ac = UIAlertController(title: "Edit Text", message: nil, preferredStyle: .alert)
        ac.addTextField() { [weak self] textField in
            textField.text = self?.programItems.allItems[indexPath.section][indexPath.row]
        }
        
        let changeAction = UIAlertAction(title: "Change", style: .default) { [weak self, weak ac] alert in
            if let text = ac?.textFields?[0].text {
                self?.tableView.cellForRow(at: indexPath)?.textLabel?.text = text
                self?.programItems.allItems[indexPath.section][indexPath.row] = text
            }
        }
        
        ac.addAction(changeAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func promptSelection() {
        let ac = UIAlertController(title: "Add Program Item", message: "To which section would you like to add a program item?", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Header", style: .default, handler: selectionHandler))
        ac.addAction(UIAlertAction(title: "Body", style: .default, handler: selectionHandler))
        ac.addAction(UIAlertAction(title: "Miscellaneous", style: .default, handler: selectionHandler))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func selectionHandler(for action: UIAlertAction) {
        let ac = UIAlertController(title: "\(action.title ?? "Program") Item", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submit = UIAlertAction(title: "Add item", style: .default) { [weak ac, weak self] _ in
            guard let response = ac?.textFields?[0].text else { return }
            var section: Int
            
            switch action.title {
            case "Header":
                section = 1
            case "Body":
                section = 2
            default:
                section = 3
            }
            
            if let count = self?.programItems.allItems[section].count {
                self?.programItems.allItems[section].append(response)
                self?.tableView.insertRows(at: [IndexPath(row: count, section: section)], with: .automatic) // Count set before appending item
            }
        }
        ac.addAction(submit)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    @objc func resetToDefault() {
        let ac = UIAlertController(title: "Reset to default program", message: "This will erase all edits made to the program, including the changes made to the PDF document.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            self?.programItems.allItems = [["Sacrament Meeting"],
                                            ["Presiding: (Tap to edit)", "Conducting: (Tap to edit)", "Piano: (Tap to edit)", "Chorister: (Tap to edit)"],
                                            ["Opening Hymn: (Tap to edit)", "Opening Prayer: (Tap to edit)", "Announcements", "Sacrament Hymn: (Tap to edit)", "Sacrament", "Opening Speaker: (Tap to edit)", "Intermediate Hymn: (Tap to edit)", "Closing Speaker: (Tap to edit)", "Closing Prayer: (Tap to edit)"],
                                            []
                                            ]
            self?.tableView.reloadData()
        }
        
        ac.addAction(confirmAction)
        present(ac, animated: true)
    }
}

