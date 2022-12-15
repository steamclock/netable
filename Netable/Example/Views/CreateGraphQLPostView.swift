//
//  CreateGraphQLPostView.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-08.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import SwiftUI

struct CreateGraphQLPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GraphQLVM

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
            VStack {
                Text("Create New Post")
                    .font(.title)
                TextField("Title", text: $viewModel.title )
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                    .textInputAutocapitalization(.never)
                TextField("Content", text: $viewModel.content)
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                Button(action: { viewModel.updatePosts()
                    self.presentationMode.wrappedValue.dismiss() }) {
                    Text("Post")
                }.padding()
                .padding(.horizontal, 40)
                .background(.blue)
                .cornerRadius(10)
                .foregroundColor(.white)
                Text("Note: this method does not actually mutate posts. Check console to see post method in action after making request.")
                    .font(.footnote)
            }.padding()
            Spacer()
        }.background(Color.lightGrey)
    }
}
