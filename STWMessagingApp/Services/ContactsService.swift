//
//  ContactsService.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 30/12/2023.
//

import Contacts
import UIKit

class ContactsService {
    private var contactStore = CNContactStore()

    func requestAccess(completion: @escaping (Bool) -> Void) {
        contactStore.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                print("Error requesting access: \(error)")
                completion(false)
                return
            }
            completion(granted)
        }
    }

    func fetchContacts(completion: @escaping ([MockUser]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let keys = [
                CNContactIdentifierKey,
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey,
                CNContactEmailAddressesKey,
                CNContactThumbnailImageDataKey
            ] as [CNKeyDescriptor]
            
            let request = CNContactFetchRequest(keysToFetch: keys)
            var contacts = [MockUser]()
            do {
                try self.contactStore.enumerateContacts(with: request) { (contact, stop) in
                    let simpleContact = MockUser(
                        senderId: contact.identifier,
                        displayName: contact.givenName + " " + contact.familyName,
                        firstName: contact.givenName,
                        lastName: contact.familyName,
                        phoneNumber: contact.phoneNumbers.first?.value.stringValue,
                        email: contact.emailAddresses.first?.value as String?,
                        thumbnailImage: UIImage(data: contact.thumbnailImageData ?? Data())
                    )
                    contacts.append(simpleContact)
                }
                
                // Once fetching is complete, dispatch the completion handler on the main thread
                DispatchQueue.main.async {
                    completion(contacts)
                }
            } catch {
                print("Failed to fetch contacts, error: \(error)")
                // Dispatch the error completion handler on the main thread
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    

}
