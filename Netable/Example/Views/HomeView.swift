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
        NavigationView {
            ScrollView {
                HStack {
                    Text("Cat Diary")
                        .font(.largeTitle)
                    Spacer()
                    NavigationLink(destination: CreatePostView(viewModel: viewModel)) {
                        Text("New Post")
                    }.padding()
                    .background(.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                }

                ForEach(viewModel.posts, id: \.self) { post in
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
        .onAppear {
            viewModel.bindViewModel()
        }
        .onDisappear {
            viewModel.unbindViewModel()
        }
    }
}
