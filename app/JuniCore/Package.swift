// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "JuniCore", products: [.library(name: "JuniCore", targets: ["JuniCore"])], targets: [.target(name: "JuniCore"), .testTarget(name: "JuniCoreTests", dependencies: ["JuniCore"])])
