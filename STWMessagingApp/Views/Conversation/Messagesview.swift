//
//  Messagesview.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 30/12/2023.
//

import InputBarAccessoryView
import MessageKit
import SwiftUI

// MARK: - MessageSwiftUIVC

final class MessageSwiftUIVC: ChatViewController {
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    messagesCollectionView.scrollToLastItem(animated: true)
  }
    
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, animated: Bool, performUpdates updates: (() -> Void)? = nil) {
        setTypingIndicatorViewHidden(isHidden, animated: animated, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
}

// MARK: - MessagesView

struct MessagesView: UIViewControllerRepresentable {
  // MARK: Internal

  final class Coordinator {
    // MARK: Lifecycle
      

      init(messages: Binding<[MessageType]>,currentMockSender : MockUser,recieverMock : MockUser) {
      self.currentMockSender = currentMockSender
      self.messages = messages
      self.recieverMock = recieverMock
    }

    // MARK: Internal

    let formatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      return formatter
    }()

    var messages: Binding<[MessageType]>
    let currentMockSender: MockUser
    let recieverMock : MockUser
  }

  @State var initialized = false
  @Binding var messages: [MessageType]
  let currentMockSender: MockUser
  let recieverMock : MockUser

  func makeUIViewController(context: Context) -> MessagesViewController {
      // MARK: messages should be paased here after retrieving from coredata
      let messagesVC = MessageSwiftUIVC(messageList: [], currentMockSender: currentMockSender, recieverMock: recieverMock)
    messagesVC.messagesCollectionView.messagesDisplayDelegate = context.coordinator
    messagesVC.messagesCollectionView.messagesLayoutDelegate = context.coordinator
    messagesVC.messagesCollectionView.messagesDataSource = context.coordinator
    messagesVC.messageInputBar.delegate = context.coordinator
    messagesVC.scrollsToLastItemOnKeyboardBeginsEditing = true // default false
    messagesVC.maintainPositionOnInputBarHeightChanged = true // default false
    messagesVC.showMessageTimestampOnSwipeLeft = true // default false

    return messagesVC
  }

  func updateUIViewController(_ uiViewController: MessagesViewController, context _: Context) {
    uiViewController.messagesCollectionView.reloadData()
    scrollToBottom(uiViewController)
  }

  func makeCoordinator() -> Coordinator {
      Coordinator(messages: $messages, currentMockSender: currentMockSender, recieverMock: recieverMock)
  }

  // MARK: Private

  private func scrollToBottom(_ uiViewController: MessagesViewController) {
    DispatchQueue.main.async {
      // The initialized state variable allows us to start at the bottom with the initial messages without seeing the initial scroll flash by
      uiViewController.messagesCollectionView.scrollToLastItem(animated: self.initialized)
      self.initialized = true
    }
  }
}

// MARK: - MessagesView.Coordinator + MessagesDataSource

extension MessagesView.Coordinator: MessagesDataSource {
  var currentSender: SenderType {
       currentMockSender
  }

  func messageForItem(at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageType {
    messages.wrappedValue[indexPath.section]
  }

  func numberOfSections(in _: MessagesCollectionView) -> Int {
    messages.wrappedValue.count
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

  func messageTimestampLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
    let sentDate = message.sentDate
    let sentDateString = MessageKitDateFormatter.shared.string(from: sentDate)
    let timeLabelFont: UIFont = .boldSystemFont(ofSize: 10)
    let timeLabelColor: UIColor = .systemGray
    return NSAttributedString(
      string: sentDateString,
      attributes: [NSAttributedString.Key.font: timeLabelFont, NSAttributedString.Key.foregroundColor: timeLabelColor])
  }
}

// MARK: - MessagesView.Coordinator + InputBarAccessoryViewDelegate

extension MessagesView.Coordinator: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    let message = MockMessage(text: text, user:  currentMockSender , messageId: UUID().uuidString, date: Date())
    messages.wrappedValue.append(message)
    inputBar.inputTextView.text = ""
  }
}

// MARK: - MessagesView.Coordinator + MessagesLayoutDelegate, MessagesDisplayDelegate

extension MessagesView.Coordinator: MessagesLayoutDelegate, MessagesDisplayDelegate {
  func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) {
      
      if currentSender.senderId == recieverMock.senderId {
        let avatar = Avatar(image:  currentMockSender.thumbnailImage)
        avatarView.set(avatar: avatar)
      }
      else {
          let senderID = message.sender.senderId
          let sender = [currentMockSender , recieverMock].first { sender in
              sender.senderId == senderID
          }
          let avatar = Avatar(image:  sender?.thumbnailImage)
        avatarView.set(avatar: avatar)
      }
 
  }

  func messageTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
    20
  }

  func messageBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
    16
  }
}
