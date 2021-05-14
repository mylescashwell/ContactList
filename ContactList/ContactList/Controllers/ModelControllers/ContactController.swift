//
//  ContactController.swift
//  ContactList
//
//  Created by Myles Cashwell on 5/14/21.
//

import Foundation
import CloudKit

class ContactModelController {
    
    //MARK: - Properties
    static let shared = ContactModelController()
    var contacts: [Contact] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    
    //MARK: - Functions
    func createAndSave(name: String, phoneNumber: String, email: String, completion: @escaping (Result<Contact, ContactError>) -> Void) {
        let newContact = Contact(name: name, phoneNumber: phoneNumber, email: email)
        let newRecord = CKRecord(contact: newContact)
        
        publicDB.save(newRecord) { (record, error) in
            if let error = error { return completion(.failure(.ckError(error))) }
            guard let record = record else { return completion(.failure(.couldNotUnwrap)) }
            guard let savedContact = Contact(ckRecord: record) else { return completion(.failure(.couldNotUnwrap)) }
            
            completion(.success(savedContact))
        }
    }
    
    func updateContact(contact: Contact, completion: @escaping (Result<Contact?, ContactError>) -> Void) {
        let record = CKRecord(contact: contact)
        let updateOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        updateOperation.savePolicy = .changedKeys
        updateOperation.qualityOfService = .userInteractive
        updateOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error { return completion(.failure(.ckError(error))) }
            
            guard let record = records?.first else { return completion(.failure(.couldNotUnwrap)) }
            guard let updatedContact = Contact(ckRecord: record) else { return completion(.failure(.couldNotUnwrap)) }
            completion(.success(updatedContact))
        }
        publicDB.add(updateOperation)
    }
    
    func deleteContact(contact: Contact, completion: @escaping (Result<Bool, ContactError>) -> Void) {
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.recordID])
        deleteOperation.savePolicy = .changedKeys
        deleteOperation.qualityOfService = .userInteractive
        deleteOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error { return completion(.failure(.ckError(error))) }
            
            if records?.count == 0 {
                print("RECORD DELETED FROM CLOUDKIT")
                completion(.success(true))
            } else {
                return completion(.failure(.unexpectedRecordsFound))
            }
        }
        publicDB.add(deleteOperation)
    }
    
    func fetchAllContacts(completion: @escaping (Result<[Contact]?, ContactError>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ContactKeys.recordKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error { return completion(.failure(.ckError(error))) }
            guard let records = records else { return completion(.failure(.couldNotUnwrap)) }
            let fetchedContacts = records.compactMap({ Contact(ckRecord: $0) })
            completion(.success(fetchedContacts))
        }
    }
}
