import Foundation
import SwiftCodegen

let outputDir = "/Users/jagger/CLionProjects/ChromeDevtoolProtocol/Sources/domains"

let fm = FileManager.default
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: false)

func genDomain(document: ChromeDevtoolProtocolDocument, domain: ChromeDevtoolProtocolDocument.Domain) {
  let dir = "\(outputDir)/\(domain.domain)"
  print("gen \(domain.domain):")
  try! fm.createDirectory(atPath: dir, withIntermediateDirectories: true)


  func genExperimental(_ experimental: Bool?, hasPrefix: Bool) -> String {
    if experimental == true {
      return "\(hasPrefix == true ? "," : ":") ExperimentalFeature "
    } else {
      return " "
    }
  }

  func genMainContent(cb: CodeBuilder) {
    cb << "// Generated code, ChromeDevtoolsProtocol domain \"\(domain.domain)\""
    cb << ""

    cb.comment("https://vanilla.aslushnikov.com/?\(domain.domain)", prefix: "- see: ")
    if let desc = domain.description {
      cb.comment(desc, prefix: "- description: ")
    }
    if domain.experimental == true {
      cb.comment("This is an experimental property.", prefix: "- intention: ")
    }
    cb.comment("\((domain.dependencies ?? []).joined(separator: ", "))", prefix: "- dependencies: ")
    if domain.deprecated == true {
      cb.deprecated()
    }
    cb << "public enum \(domain.domain): Model\(genExperimental(domain.experimental, hasPrefix: true)){"
    cb.indent {
      cb << "public static let name = \"\(domain.domain)\""
    }
    cb << "}"
    cb << ""
  }

  func genType(cb: CodeBuilder, type: ChromeDevtoolProtocolDocument.DomainType?, typeName: String?, arrayItem: ChromeDevtoolProtocolDocument.ArrayProperty?, ref: ChromeDevtoolProtocolDocument.TypeRef?) -> String {
    let typeMap = [
      "string": "String",
      "integer": "Int",
      "boolean": "Bool",
      "any": "[String: JsonPrimitive]",
      "number": "JsonNumber",
      "object": "[String: JsonPrimitive]"
    ]
    if let typeName = typeName {
      switch typeName {
        case "string", "integer", "boolean", "number", "any", "object":
          return typeMap[typeName]!
        case "array":
          guard let arrayItem = arrayItem else {
            fatalError("array must has array item.")
          }
          return "[\(genType(cb: cb, type: type, typeName: arrayItem.type, arrayItem: nil, ref: arrayItem.ref))]"
        default:
          fatalError("\(typeName)")
      }
    } else if let ref = ref {
      if let domain = ref.domain {
        return "ChromeDevtoolProtocol.\(domain).\(ref.typeName)"
      } else {
        if ref.typeName == type?.id {
          return "StructReference<\(ref.typeName)>"
        } else {
          return "\(ref.typeName)"
        }
      }
    } else {
      fatalError("bad")
    }
  }

  func genProperty(cb: CodeBuilder, type: ChromeDevtoolProtocolDocument.DomainType?, property: ChromeDevtoolProtocolDocument.ObjectProperty) {
    if let description = property.description {
      cb.comment(description, prefix: "- description: ")
    }
    if property.experimental == true {
      cb.comment("This is an experimental property.", prefix: "- intention: ")
    }
    let type = genType(cb: cb, type: type, typeName: property.type, arrayItem: property.items, ref: property.ref) + (property.optional == true ? "?" : "")
    cb << "public var \(CodeBuilder.escapeKeyword(name: property.name)): \(type)"
  }

  func genTypesContent(cb: CodeBuilder) {

    func genIdType(type: ChromeDevtoolProtocolDocument.DomainType, rawType: String) {
      if domain.deprecated == true {
        cb.deprecated()
      }
      cb.block("public struct \(type.id): Codable ") {
        cb << "private var rawValue: \(rawType)"
        cb << ""
        cb.block("public init(from decoder: Decoder) throws ") {
          cb << "self.rawValue = try decoder.singleValueContainer().decode(\(rawType).self)"
        }
        cb << ""
        cb.block("public func encode(to encoder: Encoder) throws ") {
          cb << "var container = encoder.singleValueContainer()"
          cb << "try container.encode(rawValue)"
        }
      }
    }

    func genType(type: ChromeDevtoolProtocolDocument.DomainType) {
      cb.comment("https://vanilla.aslushnikov.com/?\(domain.domain).\(type.id)", prefix: "- see: ")
      if let description = type.description {
        cb.comment(description, prefix: "- description: ")
      }
      if let enums = type.enum {
        cb.comment("\(enums)", prefix: "- choices: ")
      }
      if domain.deprecated == true {
        cb.deprecated()
      }
      switch type.type {
        case "integer":
          if type.id.lowercased().hasSuffix("id") {
            genIdType(type: type, rawType: "Int")
          } else {
            cb << "public typealias \(type.id) = Int"
          }
        case "string":
          if type.id.lowercased().hasSuffix("id") {
            genIdType(type: type, rawType: "String")
          } else {
            cb << "public typealias \(type.id) = String"
          }
        case "object":
          cb.block("public struct \(type.id): Codable ") {
            for property in type.properties ?? [] {
              genProperty(cb: cb, type: type, property: property)
              cb << ""
            }
          }
        case "array":
          cb << "public typealias \(type.id) = Array<String>"
        case "number":
          cb << "public typealias \(type.id) = JsonNumber"
        default:
          fatalError("which \(type)")
      }
    }

    cb << "// Generated code, ChromeDevtoolsProtocol types in domain \"\(domain.domain)\""
    cb << ""
    for type in domain.types ?? [] {
      if domain.deprecated == true {
        cb.deprecated()
      }
      cb.block("extension ChromeDevtoolProtocol.\(domain.domain) ") {
        genType(type: type)
      }
      cb << ""
    }
    cb << ""
  }

  func genCommandsContent(cb: CodeBuilder) {
    cb << "// Generated code, ChromeDevtoolsProtocol commands in domain \"\(domain.domain)\""
    cb << ""

    func genCommand(command: ChromeDevtoolProtocolDocument.Command) {
      func genInit() -> [String] {
        guard let parameters = command.parameters else {
          return []
        }
        return parameters.map { property in
          let str = "\(CodeBuilder.escapeKeyword(name: property.name)): \(genType(cb: cb, type: nil, typeName: property.type, arrayItem: property.items, ref: property.ref))"
          if property.optional == true {
            return "\(str)? = nil"
          } else {
            return str
          }
        }
      }

      if let desc = domain.description {
        cb.comment(desc, prefix: "- description: ")
      }
      if domain.experimental == true {
        cb.comment("This is an experimental property.", prefix: "- intention: ")
      }
      if command.deprecated == true {
        cb.deprecated()
      }
      cb.block("public struct \(command.name): ModelMethod\(genExperimental(command.experimental, hasPrefix: true))") {
        cb << "public typealias Model = ChromeDevtoolProtocol.\(domain.domain)"
        cb << "public static let name = \"\(command.name)\""
        cb << ""
        for param in command.parameters ?? [] {
          genProperty(cb: cb, type: nil, property: param)
          cb << ""
        }
        cb.block("public init(\(genInit().joined(separator: ", "))) ") {
          for parameter in command.parameters ?? [] {
            let name = CodeBuilder.escapeKeyword(name: parameter.name)
            cb << "self.\(name) = \(name)"
          }
        }
        cb << ""
        cb.block("public struct Result: Decodable ") {
          for param in command.returns ?? [] {
            genProperty(cb: cb, type: nil, property: param)
          }
          cb << ""
        }
        if (command.returns?.count ?? 0) == 0 {
          cb << "public static func transform(client: ChromeClient, result: Result) -> Void {"
          cb << "}"
        } else {
          cb << "public static func transform(client: ChromeClient, result: Result) -> Result {"
          cb << "\(cb.indentString)result"
          cb << "}"
        }
      }
    }

    for command in domain.commands ?? [] {
      cb.block("extension ChromeDevtoolProtocol.\(domain.domain) ") {
        genCommand(command: command)
      }
      cb << ""
    }
    cb << ""
  }

  func genEventsContent(cb: CodeBuilder) {
    cb << "// Generated code, ChromeDevtoolsProtocol events in domain \"\(domain.domain)\""
    cb << ""

    func genEvent(event: ChromeDevtoolProtocolDocument.Event) {
      if let desc = domain.description {
        cb.comment(desc, prefix: "- description: ")
      }
      if domain.experimental == true {
        cb.comment("This is an experimental property.", prefix: "- intention: ")
      }
      if event.deprecated == true {
        cb.deprecated()
      }
      cb.block("public struct \(event.name): ModelEvent\(genExperimental(event.experimental, hasPrefix: true))") {
        cb << "public typealias Model = ChromeDevtoolProtocol.\(domain.domain)"
        cb << ""
        for param in event.parameters ?? [] {
          genProperty(cb: cb, type: nil, property: param)
          cb << ""
        }
      }
    }

    for event in domain.events ?? [] {
      cb.block("extension ChromeDevtoolProtocol.\(domain.domain) ") {
        genEvent(event: event)
      }
      cb << ""
    }
    cb << ""
  }

  func writeFile(file: String, build: (CodeBuilder) -> Void) {
    try? fm.removeItem(atPath: file)
    print("\tgen \(file)")
    let cb = CodeBuilder()
    cb << "import Foundation"
    build(cb)
    fm.createFile(atPath: file, contents: cb.build().data(using: .utf8))
  }

  writeFile(file: "\(dir)/\(domain.domain).swift", build: genMainContent)
  if domain.types != nil {
    writeFile(file: "\(dir)/\(domain.domain)+types.swift", build: genTypesContent)
  }
  if domain.commands != nil {
    writeFile(file: "\(dir)/\(domain.domain)+commands.swift", build: genCommandsContent)
  }
  if domain.events != nil {
    writeFile(file: "\(dir)/\(domain.domain)+events.swift", build: genEventsContent)
  }
}


var arr = [String]()
var deps = [String: [String]]()

var document = load("browser")
for domain in document.domains {
  genDomain(document: document, domain: domain)
  arr.append(domain.domain)
  deps[domain.domain] = domain.dependencies ?? []
}

document = load("js")
for domain in document.domains {
  genDomain(document: document, domain: domain)
  arr.append(domain.domain)
  deps[domain.domain] = domain.dependencies ?? []
}

print("gen Package.swift")
var targets: [String] = []
var template = """
               // swift-tools-version:5.3

               import PackageDescription

               let package = Package(
                 name: "SwiftCDPDomains",
                 platforms: [SupportedPlatform.macOS(.v10_15)],
                 dependencies: [
                   // Dependencies declare other packages that this package depends on.
                   // .package(url: /* package url */, from: "1.0.0"),
                   .package(url: "https://github.com/634750802/swift-cdp.git", from: "0.0.1")
                 ],
                 targets: [
               // slot targets
                 ]
               )
               """
    .split(separator: "\n")
    .map(String.init)

for item in arr {
  targets.append(
      """
          .target(
            name: "\(item)", 
            dependencies: [
              .product(name: "ChromeDevtoolProtocol", package: "swift-cdp")\(deps[item]!.map { ",\n        .target(name: \"\($0)\")" }.joined())
            ]
          ),
      """)
}
let i = template.firstIndex(of: "// slot targets")!
template.replaceSubrange(i...i, with: targets)

fm.createFile(atPath: outputDir + "/Package.swift", contents: template.joined(separator: "\n").data(using: .utf8))


