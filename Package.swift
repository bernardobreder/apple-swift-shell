//
//  Package.swift
//  SwiftShell
//
//

import PackageDescription

let package = Package(
	name: "SwiftShell",
	targets: [
		Target(name: "SwiftShell", dependencies: ["Regex", "Shell"]),
		Target(name: "Regex", dependencies: []),
		Target(name: "Shell", dependencies: []),
	]
)

