//
//  LoginDataView.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-20.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import SwiftUI

struct LoginDataView: View {
    var user: User

    var body: some View {
        VStack {
            Text("Login Info").font(.title)
            ForEach(user.loginData.elements, id: \.self) { data in
                VStack {
                    HStack {
                        Text("Date: ").fontWeight(.bold)
                        Text(data.date)
                    }
                    HStack {
                        Text("Time: ").fontWeight(.bold)
                        Text(data.time)
                    }
                    HStack {
                        Text("Location: ").fontWeight(.bold)
                        Text(data.location)
                    }
                }.padding()
                .border(.black)
            }
        }
    }
}
