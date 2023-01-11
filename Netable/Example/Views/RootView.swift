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
            ErrorView(viewModel: viewModel)
            if viewModel.user == nil {
                LoginView(viewModel: viewModel.loginVM)
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
}
