//
//  ContactsViewModel.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 30/12/2023.
//

import Combine
import Contacts
import SwiftUI

class ContactsViewModel: ObservableObject {
    @Published var contacts = [MockUser]() {
        didSet {
            updateFilteredContacts()
        }
    }
    @Published var isAccessDenied = false  // Track access denial
    @Published var searchText = "" { // For the search bar
        didSet {
            updateFilteredContacts()
        }
    }
    @Published var filteredContacts = [String: [MockUser]]()  // Sorted and sectioned contacts
    
    @AppStorageCompat("currentUserID") var currentUserID : String = ""
    
    var myContact : MockUser {
        contacts.first {  contact in
            contact.senderId == currentUserID
        } ??  .init(senderId: "", displayName: "lorem name",phoneNumber: "lorem phone number",email: "lorem email")
    }
    private var contactsService = ContactsService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        requestPermissionAndLoadContacts()
        startObservingContactChanges()
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    private func requestPermissionAndLoadContacts() {
        contactsService.requestAccess { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.isAccessDenied = false
                    self?.loadContacts()
                } else {
                    self?.isAccessDenied = true
                    self?.loadSavedContacts()  // Load saved contacts if access is denied
                }
            }
        }
    }
    

    
   func loadSavedContacts() {
        // Fetch and update the UI with contacts from CoreData
        self.contacts = CoreDataHelper.shared.fetchContacts()
    }

    private func loadContacts() {
          contactsService.fetchContacts { [weak self] newContacts in
              DispatchQueue.main.async {
                  self?.syncContacts(newContacts: newContacts)
              }
          }
      }

  
    private func syncContacts(newContacts: [MockUser]) {
        let currentContacts = CoreDataHelper.shared.fetchContacts()
        
        // Prepare sets for comparison
        let currentSet = Set(currentContacts.map { $0.senderId })
        let newSet = Set(newContacts.map { $0.senderId })

        // Determine deletions and handle them
        deleteContactsNotIn(newSet: newSet, currentSet: currentSet)

        // Handle additions and updates
        updateAndAddContacts(newContacts: newContacts, currentSet: currentSet)

        // Update UI
        self.contacts = CoreDataHelper.shared.fetchContacts()
    }

    private func deleteContactsNotIn(newSet: Set<String>, currentSet: Set<String>) {
        let deletedIdentifiers = currentSet.subtracting(newSet)
        CoreDataHelper.shared.deleteContacts(identifiers: Array(deletedIdentifiers))
    }

    private func updateAndAddContacts(newContacts: [MockUser], currentSet: Set<String>) {
        for contact in newContacts {
            if currentSet.contains(contact.senderId) {
                // If the contact exists, update it (if needed)
                if let existingContactEntity = CoreDataHelper.shared.findContactEntity(identifier: contact.senderId) {
                    CoreDataHelper.shared.updateContactEntity(existingContactEntity, with: contact)
                }
            } else {
                // If the contact doesn't exist, save it as a new one
                CoreDataHelper.shared.saveContact(contact)
            }
        }
    }


       private func startObservingContactChanges() {
           // Subscribe to changes in the Contacts store
           NotificationCenter.default
               .publisher(for: NSNotification.Name.CNContactStoreDidChange)
               .sink { [weak self] _ in
                   self?.handleContactStoreChange()
               }
               .store(in: &cancellables)
       }

       private func handleContactStoreChange() {
           // Check for permissions before attempting to sync contacts
           contactsService.requestAccess { [weak self] granted in
               DispatchQueue.main.async {
                   if granted {
                       self?.loadContacts()
                   } else {
                       self?.isAccessDenied = true
                       self?.loadSavedContacts()  // Load saved contacts if access is denied
                   }
               }
           }
       }


}


extension ContactsViewModel {
    // Call this method whenever contacts or searchText changes
    private func updateFilteredContacts() {
          let lowercasedQuery = searchText.lowercased()

          // Filter contacts based on the search text
          let filtered = searchText.isEmpty ? contacts : contacts.filter {
              $0.searchableText.contains(lowercasedQuery)
          }

          // Sort and section the filtered contacts
        let sortedContacts = filtered.sorted {($0.firstName ?? "") < ($1.firstName ?? "")}
          var newFilteredContacts = [String: [MockUser]]()
          for contact in sortedContacts {
              let index = String(contact.firstName?.first ?? "#").uppercased()  // Section by the first letter of the first name
              if newFilteredContacts[index] == nil {
                  newFilteredContacts[index] = [contact]
              } else {
                  newFilteredContacts[index]?.append(contact)
              }
          }
          self.filteredContacts = newFilteredContacts
      }
      

}
