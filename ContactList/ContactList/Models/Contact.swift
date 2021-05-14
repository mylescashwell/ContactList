//
//  Contact.swift
//  ContactList
//
//  Created by Myles Cashwell on 5/14/21.
//

import Foundation
import CloudKit

struct ContactKeys {
    static let nameKey        = "name"
    static let phoneNumberKey = "phoneNumber"
    static let emailKey       = "email"
    static let recordKey      = "Contact"
}

class Contact {
    var name: String
    var phoneNumber: String
    var email: String
    var recordID: CKRecord.ID
    
    init(name: String, phoneNumber: String, email: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name        = name
        self.phoneNumber = phoneNumber
        self.email       = email
        self.recordID    = recordID
    }
}

//MARK: - Extensions
extension CKRecord {
    convenience init(contact: Contact) {
        self.init(recordType: ContactKeys.recordKey, recordID: contact.recordID)
        self.setValuesForKeys([ContactKeys.nameKey        : contact.name,
                               ContactKeys.phoneNumberKey : contact.phoneNumber,
                               ContactKeys.emailKey       : contact.email])
    }
}

extension Contact {
    convenience init?(ckRecord: CKRecord) {
        guard let name        = ckRecord[ContactKeys.nameKey] as? String,
              let phoneNumber = ckRecord[ContactKeys.phoneNumberKey] as? String,
              let email       = ckRecord[ContactKeys.emailKey] as? String else { return nil }
        self.init(name: name, phoneNumber: phoneNumber, email: email, recordID: ckRecord.recordID)
    }
}

extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
