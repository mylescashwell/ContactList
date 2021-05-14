//
//  ContactListTableViewController.swift
//  ContactList
//
//  Created by Myles Cashwell on 5/14/21.
//

import UIKit

class ContactListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    //MARK: - Functions
    func fetchContacts() {
        ContactModelController.shared.fetchAllContacts { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let contacts):
                    guard let allContacts = contacts else { return }
                    ContactModelController.shared.contacts = allContacts
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error in \(#function)\(#line) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactModelController.shared.contacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        let contact = ContactModelController.shared.contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        cell.detailTextLabel?.text = contact.phoneNumber
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let contactToDelete = ContactModelController.shared.contacts[indexPath.row]
            guard let  index = ContactModelController.shared.contacts.firstIndex(of: contactToDelete) else { return }
            
            ContactModelController.shared.deleteContact(contact: contactToDelete) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        if success {
                            ContactModelController.shared.contacts.remove(at: index)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    case .failure(let error):
                        print("Error in \(#function)\(#line) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContactDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? ContactDetailViewController else { return }
            let contactToSend = ContactModelController.shared.contacts[indexPath.row]
            destinationVC.contact = contactToSend
        }
    }
}
