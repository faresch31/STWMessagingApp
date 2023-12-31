//
//  SampleData.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 30/12/2023.
//

import Foundation


import AVFoundation
import CoreLocation
import MessageKit
import UIKit

final internal class SampleData : ObservableObject{

    @Published var messages : [MessageType] = []
    init(reciever: MockUser, now: Date = Date(), currentSender: MockUser) {
        self.reciever = reciever
        self.now = now
        self.currentSender = currentSender
    }
  enum MessageTypes: String, CaseIterable {
    case Text
    case AttributedText
    case Photo
    case PhotoFromURL = "Photo from URL"
    case Video
    case Audio
    case Emoji
    case Location
    case Url
    case Phone
    case Custom
    case ShareContact
  }
  var reciever : MockUser
  var now = Date()
  let attributes = ["Font1", "Font2", "Font3", "Font4", "Color", "Combo"]
  var currentSender: MockUser
    
  func attributedString(with text: String) -> NSAttributedString {
    let nsString = NSString(string: text)
    var mutableAttributedString = NSMutableAttributedString(string: text)
    let randomAttribute = Int(arc4random_uniform(UInt32(attributes.count)))
    let range = NSRange(location: 0, length: nsString.length)

    switch attributes[randomAttribute] {
    case "Font1":
      mutableAttributedString.addAttribute(
        NSAttributedString.Key.font,
        value: UIFont.preferredFont(forTextStyle: .body),
        range: range)
    case "Font2":
      mutableAttributedString.addAttributes(
        [
          NSAttributedString.Key.font: UIFont
            .monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.bold),
        ],
        range: range)
    case "Font3":
      mutableAttributedString.addAttributes(
        [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)],
        range: range)
    case "Font4":
      mutableAttributedString.addAttributes(
        [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)],
        range: range)
    case "Color":
      mutableAttributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: range)
    case "Combo":
      let msg9String = "Use .attributedText() to add bold, italic, colored text and more..."
      let msg9Text = NSString(string: msg9String)
      let msg9AttributedText = NSMutableAttributedString(string: String(msg9Text))

      msg9AttributedText.addAttribute(
        NSAttributedString.Key.font,
        value: UIFont.preferredFont(forTextStyle: .body),
        range: NSRange(location: 0, length: msg9Text.length))
      msg9AttributedText.addAttributes(
        [
          NSAttributedString.Key.font: UIFont
            .monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.bold),
        ],
        range: msg9Text.range(of: ".attributedText()"))
      msg9AttributedText.addAttributes(
        [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)],
        range: msg9Text.range(of: "bold"))
      msg9AttributedText.addAttributes(
        [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)],
        range: msg9Text.range(of: "italic"))
      msg9AttributedText.addAttributes(
        [NSAttributedString.Key.foregroundColor: UIColor.red],
        range: msg9Text.range(of: "colored"))
      mutableAttributedString = msg9AttributedText
    default:
      fatalError("Unrecognized attribute for mock message")
    }

    return NSAttributedString(attributedString: mutableAttributedString)
  }



}
