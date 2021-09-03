//
//  ObservableViewModel.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-03.
//

import Combine
import Foundation

extension Array where Element: Cancellable {
    mutating func cancelAll() {
        self.forEach { $0.cancel() }
        self.removeAll()
    }
}

class ObservableViewModel: ObservableObject {
    var cancellables = [AnyCancellable]()

    @Published var loadState = ContentLoadState.noData

    func unbindViewModel() {
        cancellables.cancelAll()
    }

    func bindViewModel() {
        cancellables.cancelAll()
    }
}
