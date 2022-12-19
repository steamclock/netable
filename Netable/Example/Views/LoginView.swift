//
//  LoginVIew.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-19.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginVM

    var body: some View {
            VStack(alignment: .center, spacing: 10) {
                Spacer()
                VStack {
                    Text("Welcome back!")
                        .font(.title)
                    TextField("Username", text: $viewModel.username)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                    Button(action: { viewModel.login() }) {
                        Text("Login")
                    }.padding()
                        .padding(.horizontal, 40)
                        .background(.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                    Button("Add Credentials") {
                        viewModel.fillForm()
                    }
                }.padding()
                Spacer()
            }.background(Color.lightGrey)
    }
}


