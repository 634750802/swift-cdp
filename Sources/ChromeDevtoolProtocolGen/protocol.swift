//
// Created by 高林杰 on 2020/11/27.
//

import Foundation

public struct ChromeDevtoolProtocolDocument: Decodable {
  var version: Version
  var domains: [Domain]
}

public extension ChromeDevtoolProtocolDocument {
  struct Version: Decodable {
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
