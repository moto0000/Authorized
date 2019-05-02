import Vapor
import Authentication

extension Future where T: Resource {
    
    public func authorize<A>(_ action: T.Action, as user: A, on container: Container) -> Future<T> where A: Authorizable {
        return flatMap { resource in
            let permissions = try container.make(PermissionVerifying.self)
            return permissions.authorize(resource, action, as: user, on: container)
        }
    }
    
    public func authorize<A>(_ action: T.Action, as user: A.Type, on request: Request) -> Future<T> where A: Authenticatable & Authorizable {
        return flatMap { resource in
            return try request.authorize(A.self, resource, action)
        }
    }
    
}

extension Future where T: Authorizable {

    public func authorize<R>(_ resource: R, _ action: R.Action, on container: Container) -> Future<R> where R: Resource {
        return flatMap { user in
            let permissions = try container.make(PermissionVerifying.self)
            return permissions.authorize(resource, action, as: user, on: container)
        }
    }
}
