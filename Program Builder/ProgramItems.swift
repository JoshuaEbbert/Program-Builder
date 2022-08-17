//
//  ProgramItems.swift
//  Program Builder
//
//  Created by Adam Grow on 8/12/22.
//

import UIKit

class ProgramItems: NSObject, UITableViewDataSource, UITableViewDelegate {
    var allItems: [[String]]!
    unowned var tableViewController: TableViewController!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgramItem", for: indexPath)
        cell.textLabel?.text = allItems[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Title"
        case 1:
            return "Header"
        case 2:
            return "Body"
        default:
            return "Misc"
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            allItems[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = allItems[destinationIndexPath.section][destinationIndexPath.row]

        allItems[destinationIndexPath.section][destinationIndexPath.row] = allItems[sourceIndexPath.section][sourceIndexPath.row]
        allItems[sourceIndexPath.section][sourceIndexPath.row] = temp
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 { return false }
        
        return true
    }
    
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section > sourceIndexPath.section {
            return IndexPath(row: allItems[sourceIndexPath.section].count - 1, section: sourceIndexPath.section)
        } else if proposedDestinationIndexPath.section < sourceIndexPath.section {
            return IndexPath(row: 0, section: sourceIndexPath.section)
        } else { return proposedDestinationIndexPath }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewController.getNewText(for: indexPath)
    }
}
