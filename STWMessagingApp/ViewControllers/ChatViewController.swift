//
//  ChatViewController.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 30/12/2023.
//

import SwiftUI

import InputBarAccessoryView
import MessageKit
import UIKit


class ChatViewController: MessagesViewController, MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        return currentMockSender
    }

    
    init(messageList: [MockMessage], currentMockSender: MockUser , recieverMock: MockUser) {
        self.messageList = messageList
        self.currentMockSender = currentMockSender
        self.recieverMock = recieverMock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

  var messageList: [MockMessage] = []
  let recieverMock : MockUser
  let currentMockSender: MockUser

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never
    configureMessageCollectionView()
    configureMessageInputBar()
    loadFirstMessages()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

  }

  func loadFirstMessages() {
        DispatchQueue.main.async {
          self.messagesCollectionView.reloadData()
          self.messagesCollectionView.scrollToLastItem(animated: false)
        }
  }



  func configureMessageCollectionView() {
    messagesCollectionView.messagesDataSource = self
    messagesCollectionView.messageCellDelegate = self

    scrollsToLastItemOnKeyboardBeginsEditing = true // default false
    showMessageTimestampOnSwipeLeft = true // default false

  }

  func configureMessageInputBar() {
    messageInputBar.delegate = self
      messageInputBar.inputTextView.tintColor = .green
    messageInputBar.sendButton.setTitleColor(.green, for: .normal)
    messageInputBar.sendButton.setTitleColor(
      UIColor.green.withAlphaComponent(0.3),
      for: .highlighted)
  }

  // MARK: - Helpers

  func insertMessage(_ message: MockMessage) {
    messageList.append(message)
    // Reload last section to update header/footer labels and insert a new one
    messagesCollectionView.performBatchUpdates({
      messagesCollectionView.insertSections([messageList.count - 1])
      if messageList.count >= 2 {
        messagesCollectionView.reloadSections([messageList.count - 2])
      }
    }, completion: { [weak self] _ in
      if self?.isLastSectionVisible() == true {
        self?.messagesCollectionView.scrollToLastItem(animated: true)
      }
    })
  }

  func isLastSectionVisible() -> Bool {
    guard !messageList.isEmpty else { return false }

    let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)

    return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
  }

  func numberOfSections(in _: MessagesCollectionView) -> Int {
    messageList.count
  }

  func messageForItem(at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageType {
    messageList[indexPath.section]
  }

  func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    if indexPath.section % 3 == 0 {
      return NSAttributedString(
        string: MessageKitDateFormatter.shared.string(from: message.sentDate),
        attributes: [
          NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
          NSAttributedString.Key.foregroundColor: UIColor.darkGray,
        ])
    }
    return nil
  }

  func cellBottomLabelAttributedText(for _: MessageType, at _: IndexPath) -> NSAttributedString? {
    NSAttributedString(
      string: "Read",
      attributes: [
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
        NSAttributedString.Key.foregroundColor: UIColor.darkGray,
      ])
  }

  func messageTopLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
    let name = message.sender.displayName
    return NSAttributedString(
      string: name,
      attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
  }

  func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
    let dateString = formatter.string(from: message.sentDate)
    return NSAttributedString(
      string: dateString,
      attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
  }

  func textCell(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UICollectionViewCell? {
    nil
  }

  // MARK: Private

  // MARK: - Private properties

  private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
  }()
}

// MARK: MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
  func didTapAvatar(in _: MessageCollectionViewCell) {
    print("Avatar tapped")
  }

  func didTapMessage(in _: MessageCollectionViewCell) {
    print("Message tapped")
  }

  func didTapImage(in _: MessageCollectionViewCell) {
    print("Image tapped")
  }

  func didTapCellTopLabel(in _: MessageCollectionViewCell) {
    print("Top cell label tapped")
  }

  func didTapCellBottomLabel(in _: MessageCollectionViewCell) {
    print("Bottom cell label tapped")
  }

  func didTapMessageTopLabel(in _: MessageCollectionViewCell) {
    print("Top message label tapped")
  }

  func didTapMessageBottomLabel(in _: MessageCollectionViewCell) {
    print("Bottom label tapped")
  }

  func didTapAccessoryView(in _: MessageCollectionViewCell) {
    print("Accessory view tapped")
  }
}

// MARK: MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
  func didSelectAddress(_ addressComponents: [String: String]) {
    print("Address Selected: \(addressComponents)")
  }

  func didSelectDate(_ date: Date) {
    print("Date Selected: \(date)")
  }

  func didSelectPhoneNumber(_ phoneNumber: String) {
    print("Phone Number Selected: \(phoneNumber)")
  }

  func didSelectURL(_ url: URL) {
    print("URL Selected: \(url)")
  }

  func didSelectTransitInformation(_ transitInformation: [String: String]) {
    print("TransitInformation Selected: \(transitInformation)")
  }

  func didSelectHashtag(_ hashtag: String) {
    print("Hashtag selected: \(hashtag)")
  }

  func didSelectMention(_ mention: String) {
    print("Mention selected: \(mention)")
  }

  func didSelectCustom(_ pattern: String, match _: String?) {
    print("Custom data detector patter selected: \(pattern)")
  }
}

// MARK: InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

  @objc
  func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
    processInputBar(messageInputBar)
  }

  func processInputBar(_ inputBar: InputBarAccessoryView) {
    // Here we can parse for which substrings were autocompleted
    let attributedText = inputBar.inputTextView.attributedText!
    let range = NSRange(location: 0, length: attributedText.length)
    attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { _, range, _ in

      let substring = attributedText.attributedSubstring(from: range)
      let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
      print("Autocompleted: `", substring, "` with context: ", context ?? "-")
    }

    let components = inputBar.inputTextView.components
    inputBar.inputTextView.text = String()
    inputBar.invalidatePlugins()
    // Send button activity animation
    inputBar.sendButton.startAnimating()
    inputBar.inputTextView.placeholder = "Sending..."
    // Resign first responder for iPad split view
    inputBar.inputTextView.resignFirstResponder()
    DispatchQueue.main.async { [weak self] in
        inputBar.sendButton.stopAnimating()
        inputBar.inputTextView.placeholder = "Aa"
        self?.insertMessages(components)
        self?.messagesCollectionView.scrollToLastItem(animated: true)
      }
  }

  // MARK: Private

  private func insertMessages(_ data: [Any]) {
    for component in data {
      let user = currentMockSender
        var message :  MockMessage
      if let str = component as? String {
          let uid = UUID().uuidString
          message = MockMessage(text: str, user: user , messageId: uid, date: Date())
          insertMessage(message)
          if currentSender.senderId == recieverMock.senderId {
              message.user.senderId = UUID().uuidString
              insertMessage(message)
            }
      }
    
        
       
        
    }
  }
}
