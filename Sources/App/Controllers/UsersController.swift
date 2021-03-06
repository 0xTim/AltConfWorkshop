import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.post(use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getHandler)
        usersRoute.delete(User.parameter, use: deleteHandler)
        usersRoute.put(User.self, use: updateHandler)
    }

    func createHandler(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap(to: User.self) { user in
            return user.save(on: req)
        }
    }

    func getAllHandler(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }

    func getHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }

    func updateHandler(_ req: Request, updatedUser: User) throws -> Future<User> {
        return try req.parameters.next(User.self).flatMap(to: User.self) { user in
            user.name = updatedUser.name
            user.username = updatedUser.username
            return user.save(on: req)
        }
    }

    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.parameters.next(User.self)
        return user.delete(on: req).transform(to: .noContent)
    }
}

extension User: Parameter {}
