//
//  UserView.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-01.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import SwiftUI

struct UserView: View {
    @ObservedObject var viewModel: UserVM

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let user = viewModel.user {
                HStack {
                    Spacer()
                    Text("Hello, \(user.firstName) \(user.lastName)!")
                        .font(.title)
                    Spacer()
                }
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("Bio: ").fontWeight(.bold)
                    Text(user.bio)
                }
                HStack(spacing: 1) {
                    Text("Location: ").fontWeight(.bold)
                    Text(user.location)
                }
                HStack(spacing: 1) {
                    Text("Age: ").fontWeight(.bold)
                    Text("\(user.age)")
                }
                HStack {
                    Spacer()
                    // TODO: Add logout function - this is a good way to show create a "DELETE" request since we're only doing GET and UPDATE in this so far.
                    Button(action: { print("log out")}) {
                        Text("Log Out")
                    }.padding()
                    .padding(.horizontal, 40)
                    .background(.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    Spacer()
                }.padding(.top, 20)
            } else {
                Text("Hmmmm, we can't seem to find anything about you.")
            }
        }.padding()
        .onAppear {
            viewModel.bindViewModel()
        }
    }
}
