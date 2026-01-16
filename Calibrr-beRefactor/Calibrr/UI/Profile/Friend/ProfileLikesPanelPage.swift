//
//  ProfileLikesPanelPage.swift
//  Calibrr
//

import UIKit
import OpenAPIClient
import SDWebImage
import PromiseKit

class ProfileLikesPanelPage: APage, UITableViewDelegate, UITableViewDataSource {

	private enum Mode {
		case received
		case sent
	}

	private var userId: String = ""
	private var viewingOwnProfile: Bool = false
	private var tableView: UITableView!
	private var segmented: UISegmentedControl!
	private var items: [UserSummary] = []
	private var nextCursor: String? = nil
	private var isLoading: Bool = false
	private var mode: Mode = .received

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		load(reset: true)
	}

	func configure(for userId: String, viewingOwnProfile: Bool) {
		self.userId = userId
		self.viewingOwnProfile = viewingOwnProfile
	}

	private func setupUI() {
		// Back button (pop if in navigation, else dismiss)
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(onBack))

		let titles: [String]
		if viewingOwnProfile {
			titles = ["Who liked me", "Who I liked"]
		} else {
			titles = ["Who liked this user", "Who this user liked"]
		}
		segmented = UISegmentedControl(items: titles)
		segmented.selectedSegmentIndex = 0
		segmented.addTarget(self, action: #selector(changeMode), for: .valueChanged)
		navigationItem.titleView = segmented

		// CBRTableView only has required init(coder:), but UITableView provides convenience inits.
		// Use a plain UITableView, which is fine for this screen, to avoid init(coder:) requirement.
		tableView = UITableView(frame: .zero, style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	@objc private func onBack() {
		if let nav = self.navigationController, nav.viewControllers.first != self {
			nav.popViewController(animated: true)
		} else if presentingViewController != nil {
			self.dismiss(animated: true, completion: nil)
		} else {
			_ = self.nav.pop()
		}
	}

	@objc private func changeMode() {
		mode = segmented.selectedSegmentIndex == 0 ? .received : .sent
		load(reset: true)
	}

	private func load(reset: Bool) {
		guard !isLoading else { return }
		isLoading = true
		if reset {
			items.removeAll()
			nextCursor = nil
			tableView.reloadData()
		}
		let promise: Promise<PaginatedUserSummaries> = (mode == .received)
			? ProfileAPI.getLikesReceived(id: userId, cursor: nextCursor)
			: ProfileAPI.getLikesSent(id: userId, cursor: nextCursor)
		promise.done { page in
			self.items.append(contentsOf: page.data)
			self.nextCursor = page.nextCursor
			self.tableView.reloadData()
		}.ensure {
			self.isLoading = false
		}.catchCBRError(show: true, from: self)
	}

	// MARK: - Table
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return items.count }

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellId = "likesCell"
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
		let item = items[indexPath.row]
		cell.textLabel?.text = "\(item.firstName) \(item.lastName)"
		if let url = item.avatarUrl, let u = URL(string: url) {
			// If we have SDWebImage in this module, we could set imageView; keeping simple text cell for now
			cell.imageView?.sd_setImage(with: u, placeholderImage: UIImage(named: "icon_avatar_placeholder"))
		} else {
			cell.imageView?.image = UIImage(named: "icon_avatar_placeholder")
		}
		cell.accessoryType = .disclosureIndicator
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let profileId = items[indexPath.row].id
		if profileId == DatabaseService.singleton.getProfile().user.id {
			self.nav.push(ProfilePage())
		} else {
			let vc = ProfileFriendPage()
			vc.friendId = profileId
			self.nav.push(vc)
		}
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let threshold: CGFloat = 120
		let contentBottom = scrollView.contentSize.height - scrollView.bounds.height - threshold
		if scrollView.contentOffset.y > contentBottom, nextCursor != nil {
			load(reset: false)
		}
	}
}


