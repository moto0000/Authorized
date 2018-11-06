import Foundation
import XCTest
import Vapor
import Authentication
@testable import Authorized

final class PermissionManagerTests: XCTestCase {
    
    static var allTests = [
        ("testAllowed", testAllowed),
        ("testAuthorize", testAuthorize),
    ]
    
    func testAllowed() throws {
        let container = try self.container()
        let permissions = try container.make(PermissionManager.self)
        let user = SomeUser(id: 1)
        let otherUser = SomeUser(id: 2)
        let post = Post(id: 1, userId: user.id)
        
        permissions.allow(Post.self, .create, as: SomeUser.self)
        permissions.allow(Post.self, .modify, as: SomeUser.self) { post, user, container in
            return container.future(post.userId == user.id)
        }
        
        XCTAssertTrue(try permissions.allowed(Post.self, .create, as: user, on: container).wait())
        XCTAssertTrue(try permissions.allowed(post, .create, as: user, on: container).wait())

        XCTAssertTrue(try permissions.allowed(Post.self, .create, as: otherUser, on: container).wait())
        XCTAssertTrue(try permissions.allowed(post, .create, as: otherUser, on: container).wait())
        
        XCTAssertFalse(try permissions.allowed(Post.self, .modify, as: user, on: container).wait())
        XCTAssertTrue(try permissions.allowed(post, .modify, as: user, on: container).wait())
        
        XCTAssertFalse(try permissions.allowed(Post.self, .modify, as: otherUser, on: container).wait())
        XCTAssertFalse(try permissions.allowed(post, .modify, as: otherUser, on: container).wait())
    }
    
    func testAuthorize() throws {
        let container = try self.container()
        let permissions = try container.make(PermissionManager.self)
        let request = Request(using: container)

        let user = SomeUser(id: 1)
        let otherUser = SomeUser(id: 2)
        let post = Post(id: 1, userId: user.id)

        permissions.allow(Post.self, .create, as: SomeUser.self)
        permissions.allow(Post.self, .modify, as: SomeUser.self) { post, user, container in
            return container.future(post.userId == user.id)
        }

        try request.authenticate(user)

        XCTAssertNoThrow(
            try request.authorize(SomeUser.self, Post.self, .create).wait()
        )

        XCTAssertNoThrow(
            try request.authorize(SomeUser.self, post, .create).wait()
        )

        XCTAssertThrowsError(
            try request.authorize(SomeUser.self, Post.self, .modify).wait()
        )

        XCTAssertThrowsError(
            try request.authorize(otherUser, Post.self, .modify).wait()
        )

        XCTAssertThrowsError(
            try request.authorize(otherUser, post, .modify).wait()
        )

        XCTAssertNoThrow(
            try request.authorize(SomeUser.self, post, .modify).wait()
        )
    }
    
}

fileprivate struct SomeUser: Authorizable, Authenticatable {
    
    let id: Int
    
}

fileprivate struct Post: Resource {
    
    enum Action: String, ResourceAction {
        case create
        case modify
    }
    
    let id: Int
    let userId: Int
    
}
