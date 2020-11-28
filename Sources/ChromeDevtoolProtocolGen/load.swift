import Foundation

func load(_ name: String) -> ChromeDevtoolProtocolDocument {
  let path: URL = Bundle.module.url(forResource: "\(name)_protocol", withExtension: "json")!

  let data = try! Data(contentsOf: path)
  return try! JSONDecoder().decode(ChromeDevtoolProtocolDocument.self, from: data)
}