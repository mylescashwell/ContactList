//
//  ContactDetailViewController.swift
//  ContactList
//
//  Created by Myles Cashwell on 5/14/21.
//

import UIKit

class ContactDetailViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    //MARK: - Properties
    var contact: Contact?
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    
    //MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let nameField = nameTextField.text, !nameField.isEmpty,
              let phoneNumberField = phoneNumberTextField.text,
              let emailField = emailTextField.text else { return }
        if let contact = contact {
            contact.name        = nameField
            contact.phoneNumber = phoneNumberField
            contact.email       = emailField
            ContactModelController.shared.updateContact(contact: contact) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print("Error in \(#function)\(#line) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            }
        } else {
            ContactModelController.shared.createAndSave(name: nameField, phoneNumber: phoneNumberField, email: emailField) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let newContact):
                        ContactModelController.shared.contacts.append(newContact)
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print("Error in \(#function)\(#line) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            }
        }
    }
    
    
    //MARK: - Functions
    func updateViews() {
        guard let contact = contact else { return }
        nameTextField.text        = contact.name
        phoneNumberTextField.text = contact.phoneNumber
        emailTextField.text       = contact.email
    }
}
