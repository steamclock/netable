//
//  ContentView.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import Combine
import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    private var cancellables = [AnyCancellable]()

    var body: some View {
        NavigationView {
            if isLoggedIn {
                HomeView()
            } else {
                LoginView()
            }
        }.onAppear {
            UserRepository.shared.user.sink { user in
                self.isLoggedIn = user != nil
            }.store(in: &UserRepository.shared.cancellables)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
