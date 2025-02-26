// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MacTodo",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MacTodo", targets: ["MacTodo"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MacTodo",
            dependencies: [],
            path: "MacTodo"
        )
    ]
)
