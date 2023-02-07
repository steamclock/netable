//
//  RootVM.swift
//  Example
//
//  Created by Amy Oulton on 2022-12-15.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

class RootVM: ObservableVM {
    let homeVM = HomeVM()
    let loginVM = LoginVM()
    let graphQLVM = GraphQLVM()
    let userVM = UserVM()

    @Published var user: User?
    @Published var error: String?

    override func bindViewModel() {
        super.bindViewModel()

        AuthNetworkService.shared.user
            .receive(on: RunLoop.main)
            .sink { user in
                self.user = user
            }.store(in: &cancellables)

        AuthNetworkService.shared.authError
            .receive(on: RunLoop.main)
            .sink { error in
                self.error = error?.errorDescription
            }.store(in: &cancellables)
        
        ErrorService.shared.errors
            .receive(on: RunLoop.main)
            .sink { error in
                self.error = error?.errorDescription
            }.store(in: &cancellables)

        getVersion()
    }

    func getVersion() {
        Task {
            try await SimpleNetworkService.shared.getVersion()
        }
    }

    func clearError() {
        error = nil
    }
}
