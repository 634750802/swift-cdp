//
// Created by 高林杰 on 2020/11/27.
//

import Foundation

public struct ChromeDevtoolProtocolDocument: Decodable {
  var version: Version
  var domains: [Domain]

  mutating func merge(other: ChromeDevtoolProtocolDocument) {
    assert(version == other.version)
  }
}

public extension ChromeDevtoolProtocolDocument {
  struct Version: Decodable, Equatable {
    var major: String
    var minor: String
  }

  struct TypeRef: Decodable {
    var domain: String?
    var typeName: String

    public init(from decoder: Decoder) throws {
      let value = try decoder.singleValueContainer().decode(String.self)
      if value.contains(".") {
        let arr = value.split(separator: ".")
        domain = String(arr[0])
        typeName = String(arr[1])
      } else {
        domain = nil
        typeName = value
      }
    }

    func resolve(in document: ChromeDevtoolProtocolDocument, domain: Domain) -> DomainType {
      let refDomain = self.domain.map { domain in document.domains.first { $0.domain == domain }! } ?? domain
      return refDomain.types!.first { $0.id == self.typeName }!
    }
  }

  struct Domain: Decodable {
    var domain: String
    var experimental: Bool?
    var deprecated: Bool?
    var description: String?
    var dependencies: [String]?
    var commands: [Command]?
    var events: [Event]?
    var types: [DomainType]?
  }

  struct Event: Decodable {
    var name: String
    var description: String?
    var experimental: Bool?
    var deprecated: Bool?
    var parameters: [ObjectProperty]?
  }

  struct Command: Decodable {
    var name: String
    var description: String?
    var deprecated: Bool?
    var experimental: Bool?
    var parameters: [ObjectProperty]?
    var returns: [ObjectProperty]?
  }

  struct DomainType: Decodable {
    var id: String
    var description: String?
    var type: String
    var `enum`: [String]?
    var items: ArrayProperty?
    var properties: [ObjectProperty]?
  }

  struct ObjectProperty: Decodable {
    var name: String
    var description: String?
    var optional: Bool?
    var experimental: Bool?
    var type: String?
    var `enum`: [String]?
    var items: ArrayProperty?
    var properties: [ObjectProperty]?
    var ref: TypeRef?

    enum CodingKeys: String, CodingKey {
      case name
      case description
      case optional
      case experimental
      case type
      case `enum`
      case items
      case ref = "$ref"
    }
  }

  struct ArrayProperty: Decodable {
    var ref: TypeRef?
    var type: String?
    var `enum`: String?

    enum CodingKeys: String, CodingKey {
      case ref = "$ref"
      case type
      case `enum`
    }
  }
}

extension ChromeDevtoolProtocolDocument {
  subscript(name: String) -> Domain? {
    get {
      domains.first { $0.domain == name }
    }
    set {
      if let index = domains.firstIndex(where: { $0.domain == name }) {
        if let newDomain = newValue {
          domains[index] = newDomain
        } else {
          domains.remove(at: index)
        }
      } else {
        if let newDomain = newValue {
          domains.append(newDomain)
        }
      }
    }
  }
}

extension ChromeDevtoolProtocolDocument.Domain {
  subscript(type name: String) -> ChromeDevtoolProtocolDocument.DomainType? {
    get {
      types?.first { $0.id == name }
    }
    set {
      guard types != nil else {
        return
      }
      if let index = types!.firstIndex(where: { $0.id == name }) {
        if let newType = newValue {
          types![index] = newType
        } else {
          types!.remove(at: index)
        }
      } else {
        if let newType = newValue {
          types!.append(newType)
        }
      }
    }
  }
  subscript(command name: String) -> ChromeDevtoolProtocolDocument.Command? {
    get {
      commands?.first { $0.name == name }
    }
    set {
      guard commands != nil else {
        return
      }
      if let index = commands!.firstIndex(where: { $0.name == name }) {
        if let newCommand = newValue {
          commands![index] = newCommand
        } else {
          commands!.remove(at: index)
        }
      } else {
        if let newCommand = newValue {
          commands!.append(newCommand)
        }
      }
    }
  }
  subscript(event name: String) -> ChromeDevtoolProtocolDocument.Event? {
    get {
      events?.first { $0.name == name }
    }
    set {
      guard events != nil else {
        return
      }
      if let index = events!.firstIndex(where: { $0.name == name }) {
        if let newEvent = newValue {
          events![index] = newEvent
        } else {
          events!.remove(at: index)
        }
      } else {
        if let newEvent = newValue {
          events!.append(newEvent)
        }
      }
    }
  }
}

extension ChromeDevtoolProtocolDocument.DomainType {
  subscript(name: String) -> ChromeDevtoolProtocolDocument.ObjectProperty? {
    get {
      properties?.first { $0.name == name }
    }
    set {
      guard properties != nil else {
        return
      }
      if let index = properties!.firstIndex(where: { $0.name == name }) {
        if let property = newValue {
          properties![index] = property
        } else {
          properties!.remove(at: index)
        }
      } else {
        if let property = newValue {
          properties!.append(property)
        }
      }
    }
  }
}


extension ChromeDevtoolProtocolDocument.Command {
  subscript(name: String) -> ChromeDevtoolProtocolDocument.ObjectProperty? {
    get {
      parameters?.first { $0.name == name }
    }
    set {
      guard parameters != nil else {
        return
      }
      if let index = parameters!.firstIndex(where: { $0.name == name }) {
        if let property = newValue {
          parameters![index] = property
        } else {
          parameters!.remove(at: index)
        }
      } else {
        if let property = newValue {
          parameters!.append(property)
        }
      }
    }
  }
}

extension ChromeDevtoolProtocolDocument.Event {
  subscript(name: String) -> ChromeDevtoolProtocolDocument.ObjectProperty? {
    get {
      parameters?.first { $0.name == name }
    }
    set {
      guard parameters != nil else {
        return
      }
      if let index = parameters!.firstIndex(where: { $0.name == name }) {
        if let property = newValue {
          parameters![index] = property
        } else {
          parameters!.remove(at: index)
        }
      } else {
        if let property = newValue {
          parameters!.append(property)
        }
      }
    }
  }
}

enum FixupRule {
  case propertyType(domain: String, type: String, property: String, realType: String)
  case typeType(domain: String, type: String, realType: String)
  case commandParamsType(domain: String, command: String, params: String, realType: String)
  case eventParamsType(domain: String, event: String, params: String, realType: String)
}

func fix(doc: inout ChromeDevtoolProtocolDocument, rule: FixupRule) {
  switch rule {
    case .propertyType(let domain, let type, let property, let realType):
      doc[domain]?[type: type]?[property]?.type = realType
    case .typeType(let domain, let type, let realType):
      doc[domain]?[type: type]?.type = realType
    case .commandParamsType(let domain, let command, let param, let realType):
      doc[domain]?[command: command]?[param]?.type = realType
    case .eventParamsType(let domain, let event, let param, let realType):
      doc[domain]?[event: event]?[param]?.type = realType
  }
}
