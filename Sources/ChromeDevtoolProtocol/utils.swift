@dynamicMemberLookup
public class StructReference<Target> {
  public private(set) var __target: Target

  public init(_ target: Target) {
    self.__target = target
  }

  public required init(from decoder: Decoder) throws where Target: Decodable {
    self.__target = try Target(from: decoder)
  }

  public subscript<T>(dynamicMember member: KeyPath<Target, T>) -> T {
    __target[keyPath: member]
  }

  public subscript<T>(dynamicMember member: WritableKeyPath<Target, T>) -> T {
    get {
      __target[keyPath: member]
    }
    set {
      __target[keyPath: member] = newValue
    }
  }
}

extension StructReference: Encodable where Target: Encodable {
  public func encode(to encoder: Encoder) throws {
    try __target.encode(to: encoder)
  }
}

extension StructReference: Decodable where Target: Decodable {

}
