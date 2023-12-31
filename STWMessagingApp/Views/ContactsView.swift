//
//  ContactsView.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 30/12/2023.
//

import SwiftUI

struct ContactsView: View {
    @ObservedObject  var viewModel :  ContactsViewModel
    @AppStorageCompat("currentUserID") var currentUserID : String = ""
    @State var selectedRecieverChat : MockUser? = nil
    var body: some View {
        NavigationView {
            VStack{
                List {
                    // Search bar
                    TextField("Search by name, username, number, or email", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    
                    // My Contact Card
                    
                    VStack(alignment: .leading) {
                        Text("My Contact Card")
                            .font(.headline)
                        HStack {
                            Image(uiImage: viewModel.myContact.thumbnailImage ?? UIImage())
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text(viewModel.myContact.displayName)
                                    .font(.system(size: 18))
                                Text(viewModel.myContact.phoneNumber ?? "")
                                    .font(.subheadline)
                                Text(viewModel.myContact.email ?? "")
                                    .font(.subheadline)
                            }
                        }
                        .redacted(reason:currentUserID == "" ? .placeholder : nil)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    
                    
                    // Alphabetical subsections
                    
                    
                    ForEach(viewModel.filteredContacts.keys.sorted(), id: \.self) { key in
                        Section(header: Text(key)) {
                            ForEach(viewModel.filteredContacts[key] ?? [], id: \.senderId) { contact in
                                
                                Button {
                                    if !currentUserID.isEmpty {
                                        selectedRecieverChat = contact
                                    }
                                } label: {
                                    HStack {
                                        Image(uiImage: contact.thumbnailImage ?? UIImage())
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                        VStack(alignment: .leading) {
                                            Text("\(contact.displayName)")
                                                .font(.system(size: 18))
                                            Text(contact.phoneNumber ?? "")
                                                .font(.subheadline)
                                            Text(contact.email ?? "")
                                                .font(.subheadline)
                                        }
                                        
                                        Spacer()
                                        if contact.senderId == currentUserID {
                                            Text("Me")
                                                .opacity(0.5)
                                        }
                                    }
                                    .contextMenu {
                                        
                                        
                                        Button {
                                            selectedRecieverChat = contact
                                        } label: {
                                            Text("Message")
                                            Image(systemName: "message")
                                        }
                                        .disabled(currentUserID.isEmpty)
                                        
                                        Button {
                                            currentUserID = contact.senderId
                                        } label: {
                                            Text("Make this my card")
                                            Image(systemName: "person.crop.circle.fill")
                                        }
                                        
                                    }
                                } 
                            }
                        }
                    }
                }
                .alert(isPresented: $viewModel.isAccessDenied) {
                    Alert(
                        title: Text("Access Denied"),
                        message: Text("This app requires access to your contacts to function properly. Please enable access in your settings."),
                        primaryButton: .default(Text("Open Settings"), action: openAppSettings),
                        secondaryButton: .cancel(Text("Cancel"), action: {})
                    )
                }
                
                NavigationLink(isActive: Binding.optionalBoolBinding($selectedRecieverChat)) {
                    if let selectedRecieverChat {
                        ConversationView(conversationViewModel: SampleData(reciever: selectedRecieverChat, now: Date(), currentSender: viewModel.myContact))
                    }
                } label: { }
            }
        }
    }
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        UIApplication.shared.open(settingsUrl)
    }
}
