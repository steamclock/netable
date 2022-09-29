import Foundation
import _Concurrency
import PlaygroundSupport

func slowPrint(_ string: String = "slow print") async {
    print("start slow")
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    print(string)
}

func fastPrint(_ string: String = "fast print") async {
    print("start fast")
    try? await Task.sleep(nanoseconds: 1_000_000)
    print(string)
}

let task = Task {
    await fastPrint()
    await slowPrint()
    print("done")
    PlaygroundPage.current.finishExecution()
}
print("dundee")
print(task.hashValue)
task.cancel()

PlaygroundPage.current.needsIndefiniteExecution = true


func aSlowNetworkRequest() async throws -> FinalResource {
    
}
