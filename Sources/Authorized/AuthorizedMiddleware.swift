import Authentication

public final class AuthorizedMiddleware<R, A>: Middleware where R: Resource & Parameter, R.ResolvedParameter == Future<R>, A: Authenticatable & Authorizable {

    private let action: R.Action

    public init(action: R.Action) {
        self.action = action
    }

    public func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        let user = try req.requireAuthenticated(A.self)

        guard req.parameters.values.count > 0 else {
            return try user.authorize(R.self, action, on: req)
                .flatMap {
                    return try next.respond(to: req)
            }
        }

        return try req.parameters.next(R.self)
            .authorize(action, as: user, on: req)
            .flatMap { resource in
                try req.authorize(resource)
                return try next.respond(to: req)
        }
    }
}

public extension Router {

    func authorized<R, A>(
        _ action: R.Action,
        _ type: R.Type,
        as user: A.Type
    ) -> Router where R: Resource & Parameter, R.ResolvedParameter == Future<R>, A: Authenticatable & Authorizable {
        return grouped(AuthorizedMiddleware<R, A>(action: action))
    }

    func authorize<R, A>(
        _ action: R.Action,
        _ type: R.Type,
        as user: A.Type,
        configure: (Router) -> Void
    ) where R: Resource & Parameter, R.ResolvedParameter == Future<R>, A: Authenticatable & Authorizable {
        group(AuthorizedMiddleware<R, A>(action: action), configure: configure)
    }
}
