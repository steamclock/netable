//
//  RootView.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-01.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var viewModel: HomeVM

    var body: some View {
        VStack {
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
                    GraphQLView()
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
        }
    }


    var loginView: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            if viewModel.loginFailed {
                Text("Woops! We have to enter the credientials!")
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
        }.background(CustomColor.lightGrey)
    }
}
