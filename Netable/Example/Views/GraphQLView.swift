//
//  GraphQLView.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-01.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import SwiftUI

struct GraphQLView: View {
    @ObservedObject var viewModel: GraphQLVM


    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Text("Cat Diary")
                        .font(.largeTitle)
                    Spacer()
                    NavigationLink(destination: CreateGraphQLPostView(viewModel: viewModel)) {
                        Text("New Post")
                    }.padding()
                        .background(.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }

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
                }
            }.padding()

        }.onAppear {
            viewModel.getPosts()
        }
    }
}
