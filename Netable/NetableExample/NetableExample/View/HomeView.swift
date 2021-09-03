//
//  HomeView.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel = HomeViewModel()

    var body: some View {
        VStack {
            Text("Hi Mom")
        }.padding(20)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
