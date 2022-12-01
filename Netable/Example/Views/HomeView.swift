//
//  HomeView.swift
//  Example
//
//  Created by Amy Oulton on 2022-11-23.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeVM

    var body: some View {
        VStack {
            if viewModel.user != nil {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Cat Diary")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }.padding(.bottom, 4)

                    if let posts = viewModel.posts {
                    ForEach(posts, id: \.self) { post in
                            VStack(alignment: .leading) {
                                Text(post.title)
                                    .font(.title2)
                                    .padding(.bottom, 4)
                                Text(post.content)
                                Divider()
                            }
                        }
                    } else {
                        EmptyView()
                    }
                }
            } else {
                loginView
            }
        }.padding(8)
        .background(CustomColor.lightGrey)
        .onAppear {
            viewModel.bindViewModel()
        }
    }


    var loginView: some View {
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
            }
            Spacer()
        }
    }
}
