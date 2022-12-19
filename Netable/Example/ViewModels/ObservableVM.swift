//
//  ObservableVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-19.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

class ObservableVM: ObservableObject {

    var cancellables: [AnyCancellable] = []

    func unbindViewModel() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    func bindViewModel() {
        unbindViewModel()
    }

}
