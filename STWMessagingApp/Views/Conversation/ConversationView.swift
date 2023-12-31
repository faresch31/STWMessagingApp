//
//  ConversationView.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 30/12/2023.
//

import MessageKit
import SwiftUI


struct ConversationView: View {

  @ObservedObject  var conversationViewModel : SampleData

  var body: some View {
      MessagesView(messages: $conversationViewModel.messages, currentMockSender: conversationViewModel.currentSender, recieverMock: conversationViewModel.reciever)
          .navigationBarTitle("\(conversationViewModel.reciever.firstName ?? conversationViewModel.reciever.phoneNumber ?? "")", displayMode: .inline)
          .modifier(IgnoresSafeArea()) //fixes issue with placement when keyboard appears
  }

}


private struct IgnoresSafeArea: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content.ignoresSafeArea(.keyboard, edges: .bottom)
        } else {
            content
        }
    }
}
