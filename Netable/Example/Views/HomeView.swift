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
    @State private var showingSheet = false


    var body: some View {
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
        }.padding(8)
        .onAppear {
            viewModel.bindViewModel()
        }
    }
}
