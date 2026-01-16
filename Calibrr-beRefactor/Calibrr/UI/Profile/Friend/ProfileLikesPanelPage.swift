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
	private var backOverlayButton: UIButton?

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
		// Back button (custom, larger + label for prominence)
		let backButton = UIButton(type: .system)
		backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
		backButton.setTitle("Back", for: .normal)
		backButton.tintColor = .label
		backButton.setTitleColor(.label, for: .normal)
		backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
		backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
		backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
		let leftItem = UIBarButtonItem(customView: backButton)
		navigationItem.leftBarButtonItem = leftItem

		let titles: [String]
		if viewingOwnProfile {
			titles = ["Likes you", "You Like"]
		} else {
			titles = ["Likes them", "They Like"]
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

		// Visible in-view back button overlay to guarantee visibility regardless of nav bar styling
		let overlay = UIButton(type: .system)
		overlay.translatesAutoresizingMaskIntoConstraints = false
		overlay.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
		overlay.setTitle("Back", for: .normal)
		overlay.tintColor = .label
		overlay.setTitleColor(.label, for: .normal)
		overlay.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		overlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
		overlay.layer.cornerRadius = 18
		overlay.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
		overlay.addTarget(self, action: #selector(onBack), for: .touchUpInside)
		view.addSubview(overlay)
		NSLayoutConstraint.activate([
			overlay.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
			overlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
		])
		self.backOverlayButton = overlay
		view.bringSubviewToFront(overlay)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Do not globally override app nav bar color; only adjust tint for visibility
		navigationController?.navigationBar.tintColor = .label
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		// Restore tint control to app default (white) when leaving, so the rest of the app remains blue-themed
		navigationController?.navigationBar.tintColor = .white
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		guard let overlay = backOverlayButton else { return }
		overlay.layoutIfNeeded()
		let overlayHeight = max(36, overlay.bounds.height)
		let desiredTopInset: CGFloat = overlayHeight + 16
		if tableView.contentInset.top != desiredTopInset {
			tableView.contentInset.top = desiredTopInset
			tableView.scrollIndicatorInsets.top = desiredTopInset
		}
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
			vc.preferDarkBackButton = true
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


