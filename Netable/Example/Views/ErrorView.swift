//
//  ErrorView.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-19.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    @ObservedObject var viewModel: RootVM

    var body: some View {
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
    }
}
