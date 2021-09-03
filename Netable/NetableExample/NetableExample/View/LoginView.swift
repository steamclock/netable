//
//  LoginView.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
            TextField("Password", text: $viewModel.password)

            Button("Submit") {
                viewModel.login()
            }
        }.padding(20)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
