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
    @ObservedObject var viewModel: RootVM

    var body: some View {
        VStack {
            if let error = viewModel.error {
                VStack {
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
                    HomeView(viewModel: viewModel.homeVM)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    UserView(viewModel: viewModel.userVM)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                    GraphQLView(viewModel: viewModel.graphQLVM)
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
