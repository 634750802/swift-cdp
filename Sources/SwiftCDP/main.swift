import Foundation
import Combine
import Dispatch
import ChromeDevtoolProtocol
import WebSocketClient
import NIO
import Target

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

let client = try WebSocketClient
    .connect(url: "ws://localhost:53587/devtools/browser/72984f3b-fca4-466c-b96c-d437d9a8c29e", group: group)
    .map(ChromeClient.init)
    .wait()

client.on { (ct: Target.targetCreated) in
  print(ct)
}
try client.sync(Target.setDiscoverTargets(discover: true))
let id = try client.sync(Target.createTarget(url: "https://www.baidu.com", newWindow: false))
print(id)
try client.closeFuture.wait()
//
//let driver = WebDriver()
//
//func main() throws {
//  driver.queue.sync {
//    print(__dispatch_queue_get_label(nil))
//    print(__dispatch_queue_get_label(DispatchQueue.global()))
//    print(__dispatch_queue_get_label(driver.queue))
//  }
//  let pipeline = driver
//      .createSession(CreateSession(user: "name", password: nil, capabilities: ["goog:chromeOptions": ["args": "--remote-debugging-port=9222"]]))
//      .flatMap { (session: WebDriver.Session) in
//        session
//            .navigate(to: "https://www.baidu.com/")
//            .flatMap { () in
//              session.findElement(by: .css("input#kw"))
//            }
//            .flatMap { (element: Element) in
//              element.sendKeys("hi").map { element }
//            }
//            .delay(for: .seconds(2), scheduler: driver.queue)
//            .flatMap { (element: Element) in
//              element.clear().map { element }
//            }
//            .delay(for: .seconds(2), scheduler: driver.queue)
//            .delay(for: .seconds(1000), scheduler: driver.queue)
//            .flatMap { (element: Element) in
//              element.get(.attribute, name: "id")
//                     .map { id in
//                       print(id)
//                     }
//            }
//      }
//
//  print(try block(pipeline))
//  print(try block(driver.debugRequest(url: "/json/version")))
//}
//
//try main()
