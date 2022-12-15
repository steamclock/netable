//
//  RootView.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-01.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: HomeVM


    var body: some View {
        VStack {
            if let error = viewModel.error {
                let _ = print(error)
                VStack{
                    HStack {
                        Spacer()
                        Text("Error: \(error)")
                        Spacer()
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .onTapGesture {
                                viewModel.clearError()
                            }
                    }
                }.frame(maxWidth: .infinity)
                .padding()
                .background(.yellow)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        viewModel.error = nil
                    }
                }
            }
            if viewModel.user == nil {
                loginView
            } else {
                TabView {
                    HomeView(viewModel: viewModel)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    UserView(viewModel: UserVM())
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                    GraphQLView(viewModel: GraphQLVM())
                        .tabItem {
                            Image(systemName: "flowchart.fill")
                            Text("GraphQL")
                        }
                }.onAppear {
                    let tabBarAppearance = UITabBarAppearance()
                    tabBarAppearance.configureWithDefaultBackground()
                    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                }
            }
        }.onAppear {
            viewModel.bindViewModel()
            }
            .onDisappear {
                viewModel.unbindViewModel()
            }
    }

    var loginView: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            if viewModel.loginFailed {
                Text("Password/username are incorrect. Hint:")
                Text("User: cat@netable.com")
                Text("Password: meows")
            }
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
            }.padding()
            Spacer()
        }.background(Color.lightGrey)

    }
}
