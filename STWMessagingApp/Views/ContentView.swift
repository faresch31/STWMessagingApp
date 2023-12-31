//
//  ContentView.swift
//  STWMessagingApp
//
//  Created by Fares Cherni on 30/12/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ContactsView(viewModel: ContactsViewModel())
    }
}

#Preview {
    ContentView()
}
