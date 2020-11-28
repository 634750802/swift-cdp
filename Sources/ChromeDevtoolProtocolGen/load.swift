import Foundation
import Logging

fileprivate let logger = Logger(label: "CodegenHealthCheck")

func load(_ name: String) -> ChromeDevtoolProtocolDocument {
  let url = URL(string: "https://cdn.jsdelivr.net/gh/ChromeDevTools/devtools-protocol@master/json/\(name)_protocol.json")
  let data = try! Data(contentsOf: url!)
  var doc = try! JSONDecoder().decode(ChromeDevtoolProtocolDocument.self, from: data)

  for rule in fixRules {
    fix(doc: &doc, rule: rule)
  }
  healthCheck(doc)
  return doc
}

let unSafeTypes: Set<String?> = ["any", "number"]

func healthCheck(_ doc: ChromeDevtoolProtocolDocument) {
  func warnPath(_ type: String, _ path: String...) {
    logger.warning("type of \(path.joined(separator: "."))(\(type)) is unsafe.")
  }

  var builds: [String] = []

  for domain in doc.domains {
    for type in domain.types ?? [] {
      if unSafeTypes.contains(type.type) {
        warnPath(type.type, domain.domain, type.id)
        builds.append(
            """
            .typeType(domain: "\(domain.domain)", type: "\(type.id)", realType: "\(type.type)"),
            """
        )
      }
      for property in type.properties ?? [] {
        if unSafeTypes.contains(property.type) {
          warnPath(property.type!, domain.domain, type.id, property.name)
          builds.append(
              """
              .propertyType(domain: "\(domain.domain)", type: "\(type.id)", property: "\(property.name)", realType: "\(property.type!)"),
              """
          )
        }
      }
    }
    for command in domain.commands ?? [] {
      for property in command.parameters ?? [] {
        if unSafeTypes.contains(property.type) {
          warnPath(property.type!, domain.domain, command.name, property.name)
          builds.append(
              """
              .commandParamsType(domain: "\(domain.domain)", command: "\(command.name)", params: "\(property.name)", realType: "\(property.type!)"),
              """
          )
        }
      }
    }
    for event in domain.events ?? [] {
      for property in event.parameters ?? [] {
        if unSafeTypes.contains(property.type) {
          warnPath(property.type!, domain.domain, event.name, property.name)
          builds.append(
              """
              .eventParamsType(domain: "\(domain.domain)", event: "\(event.name)", params: "\(property.name)", realType: "\(property.type!)"),
              """
          )
        }
      }
    }
  }
//  print(builds.joined(separator: "\n"))
}
