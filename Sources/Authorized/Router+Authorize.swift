import Authentication

public extension Router {
    
    @discardableResult
    func get<T, R>(
        _ path: PathComponentsRepresentable...,
        use closure: @escaping (Request, R) throws -> T
    ) -> Route<Responder> where T: ResponseEncodable, R: Resource {
        return authorizeOn(.GET, at: path, use: closure)
    }

    @discardableResult
    func post<T, R>(
        _ path: PathComponentsRepresentable...,
        use closure: @escaping (Request, R) throws -> T
    ) -> Route<Responder> where T: ResponseEncodable, R: Resource {
        return authorizeOn(.POST, at: path, use: closure)
    }

    @discardableResult
    func delete<T, R>(
        _ path: PathComponentsRepresentable...,
        use closure: @escaping (Request, R) throws -> T
    ) -> Route<Responder> where T: ResponseEncodable, R: Resource {
        return authorizeOn(.DELETE, at: path, use: closure)
    }
    
    @discardableResult
    func authorizeOn<T, R>(
        _ method: HTTPMethod,
        at path: PathComponentsRepresentable...,
        use closure: @escaping (Request, R) throws -> T
    ) -> Route<Responder> where T: ResponseEncodable, R: Resource {
        return on(method, at: path) { req -> T in
            return try closure(req, req.requireAuthorized(R.self))
        }
    }
}

public extension Router {

    @discardableResult
    func post<T, C, R>(
        _ content: C.Type,
        at path: PathComponentsRepresentable...,
        use closure: @escaping (Request, C, R) throws -> T
    ) -> Route<Responder> where T: ResponseEncodable, C: RequestDecodable, R: Resource {
        return authorizeOn(.POST, at: path, use: closure)
    }
    
    @discardableResult
    func put<T, C, R>(
        _ content: C.Type,
        at path: PathComponentsRepresentable...,
        use closure: @escaping (Request, C, R) throws -> T
    ) -> Route<Responder> where T: ResponseEncodable, C: RequestDecodable, R: Resource {
        return authorizeOn(.PUT, at: path, use: closure)
    }

    @discardableResult
    func authorizeOn<T, C, R>(
        _ method: HTTPMethod,
        at path: PathComponentsRepresentable...,
        use closure: @escaping (Request, C, R) throws -> T
    ) -> Route<Responder> where T: ResponseEncodable, C: RequestDecodable, R: Resource {
        return on(method, C.self, at: path) { req, content -> T in
            return try closure(req, content, req.requireAuthorized(R.self))
        }
    }
}
