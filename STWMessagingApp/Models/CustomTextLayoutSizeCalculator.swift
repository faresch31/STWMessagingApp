//
//  CustomTextMessageSizeCalculator.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 30/12/2023.
//


import MessageKit
import UIKit

class CustomTextLayoutSizeCalculator: CustomLayoutSizeCalculator {
  var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)
  var cellMessageContainerRightSpacing: CGFloat = 16

  override func messageContainerSize(
    for message: MessageType,
    at indexPath: IndexPath)
    -> CGSize
  {
    let size = super.messageContainerSize(
      for: message,
      at: indexPath)
    let labelSize = messageLabelSize(
      for: message,
      at: indexPath)
    let selfWidth = labelSize.width +
      cellMessageContentHorizontalPadding +
      cellMessageContainerRightSpacing
    let width = max(selfWidth, size.width)
    let height = size.height + labelSize.height

    return CGSize(
      width: width,
      height: height)
  }

  func messageLabelSize(
    for message: MessageType,
    at _: IndexPath)
    -> CGSize
  {
    let attributedText: NSAttributedString

    let textMessageKind = message.kind
    switch textMessageKind {
    case .attributedText(let text):
      attributedText = text
    case .text(let text), .emoji(let text):
      attributedText = NSAttributedString(string: text, attributes: [.font: messageLabelFont])
    default:
      fatalError("messageLabelSize received unhandled MessageDataType: \(message.kind)")
    }

    let maxWidth = messageContainerMaxWidth -
      cellMessageContentHorizontalPadding -
      cellMessageContainerRightSpacing

    return attributedText.size(consideringWidth: maxWidth)
  }

  func messageLabelFrame(
    for message: MessageType,
    at indexPath: IndexPath)
    -> CGRect
  {
    let origin = CGPoint(
      x: cellMessageContentHorizontalPadding / 2,
      y: cellMessageContentVerticalPadding / 2)
    let size = messageLabelSize(
      for: message,
      at: indexPath)

    return CGRect(
      origin: origin,
      size: size)
  }
}
