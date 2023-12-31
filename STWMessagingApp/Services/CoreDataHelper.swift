//
//  CoreDataHelper.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 30/12/2023.
//

import CoreData
import UIKit

class CoreDataHelper {
    static let shared = CoreDataHelper()
    var persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "ContactsContainer")
        
        // Enable encryption for CoreData
        let storeDescription = persistentContainer.persistentStoreDescriptions.first
        storeDescription?.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func saveContact(_ contact: MockUser) {
        let context = persistentContainer.viewContext
        let contactEntity = ContactEntity(context: context)
        contactEntity.identifier = contact.senderId
        contactEntity.firstName = contact.firstName
        contactEntity.lastName = contact.lastName
        contactEntity.phoneNumber = contact.phoneNumber
        contactEntity.email = contact.email
        if let thumbnailImage = contact.thumbnailImage {
            contactEntity.thumbnailImage = thumbnailImage.pngData()
        }
        saveContext()
    }

    func fetchContacts() -> [MockUser] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
        do {
            let contactEntities = try context.fetch(fetchRequest)
            return contactEntities.compactMap { contactEntity in
                if  let indentifier  = contactEntity.identifier  {
                    let firstName =  contactEntity.firstName
                    let lastName =  contactEntity.lastName
                    let phoneNumber =  contactEntity.phoneNumber
                    let  email =  contactEntity.email
                    let  thumbnailImage =  contactEntity.thumbnailImage != nil ? UIImage(data: contactEntity.thumbnailImage!) : nil
                    var displayName = ""
                    if let firstName , let lastName {
                      displayName = firstName + " " +  lastName
                    }
                  return  MockUser(senderId: indentifier, displayName: displayName, firstName: firstName, lastName: lastName,phoneNumber: phoneNumber,email: email,thumbnailImage: thumbnailImage)
                }
                return nil
            }
        } catch {
            print("Failed to fetch contacts from CoreData, error: \(error)")
            return []
        }
    }
    
    
    func findContactEntity(identifier: String) -> ContactEntity? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching contact with identifier \(identifier): \(error)")
            return nil
        }
    }

    func deleteContactEntity(_ contactEntity: ContactEntity) {
        let context = persistentContainer.viewContext
        context.delete(contactEntity)
        saveContext()
    }

    func updateContactEntity(_ existingContact: ContactEntity, with simpleContact: MockUser) {
        existingContact.firstName = simpleContact.firstName
        existingContact.lastName = simpleContact.lastName
        existingContact.phoneNumber = simpleContact.phoneNumber
        existingContact.email = simpleContact.email
        if let thumbnailImage = simpleContact.thumbnailImage {
            existingContact.thumbnailImage = thumbnailImage.pngData()
        }
        saveContext()
    }
    

      func deleteContacts(identifiers: [String]) {
          let context = persistentContainer.viewContext
          identifiers.forEach { identifier in
              if let contactEntity = findContactEntity(identifier: identifier) {
                  context.delete(contactEntity)
              }
          }
          saveContext()
      }
}
