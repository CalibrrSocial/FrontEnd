//
//  UserSummary.swift
//  Calibrr
//
//  Lightweight user summary for likes lists
//

import Foundation

public struct UserSummary: Codable, Hashable {
	public let id: String
	public let firstName: String
	public let lastName: String
	public let avatarUrl: String?

	public init(id: String, firstName: String, lastName: String, avatarUrl: String?) {
		self.id = id
		self.firstName = firstName
		self.lastName = lastName
		self.avatarUrl = avatarUrl
	}

	private enum CodingKeys: String, CodingKey {
		case id
		case firstName
		case lastName
		case avatarUrl
	}
}


