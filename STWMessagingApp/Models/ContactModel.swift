//
//  ContactModel.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 30/12/2023.
//

import UIKit
import MessageKit

struct MockUser:SenderType, Equatable {
    var senderId: String
    var displayName: String
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var email: String?
    var thumbnailImage: UIImage?
    var searchableText: String {
           [firstName, lastName, lastName, phoneNumber, email].compactMap { $0 }.joined(separator: " ").lowercased()
       }
}
