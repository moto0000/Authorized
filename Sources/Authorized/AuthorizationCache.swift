import Authentication

final class AuthorizationCache: Service {

    private var storage: [ObjectIdentifier: Any]

    init() {
        self.storage = [:]
    }

    internal subscript<R>(_ type: R.Type) -> R? where R: Resource {
        get { return storage[ObjectIdentifier(R.self)] as? R }
        set { storage[ObjectIdentifier(R.self)] = newValue }
    }
}

extension Request {

    internal func authorize<R>(_ instance: R) throws where R: Resource {
        let cache = try privateContainer.make(AuthorizationCache.self)
        cache[R.self] = instance
    }

    public func authorized<R>(_ type: R.Type = R.self) throws -> R? where R: Resource {
        let cache = try privateContainer.make(AuthorizationCache.self)
        return cache[R.self]
    }

    public func requireAuthorized<R>(_ type: R.Type = R.self) throws -> R where R: Resource {
        guard let resource = try authorized(R.self) else {
            throw Abort(.forbidden)
        }

        return resource
    }
}
