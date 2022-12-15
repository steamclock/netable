//
//  CreatePostView.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-02.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import SwiftUI

struct CreatePostView: View {
    @ObservedObject var viewModel: HomeVM

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
                Button(action: { viewModel.createPost() }) {
                    Text("Post")
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

