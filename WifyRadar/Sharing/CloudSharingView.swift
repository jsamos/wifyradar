import CloudKit
import CoreData
import UIKit

enum CloudSharingPresentationError: LocalizedError {
    case noPresenter

    var errorDescription: String? {
        switch self {
        case .noPresenter:
            return "Couldn’t find a screen to show Manage Sharing."
        }
    }
}

@MainActor
final class CloudSharingCoordinator: NSObject, UICloudSharingControllerDelegate {
    static let shared = CloudSharingCoordinator()

    private let persistence = PersistenceController.shared
    private var onFailure: ((Error) -> Void)?

    func present(for list: SharedList, onFailure: ((Error) -> Void)? = nil) {
        self.onFailure = onFailure
        let objectID = list.objectID
        let title = list.name ?? "List"
        let container = persistence.container
        let ckContainer = persistence.ckContainer

        let controller = UICloudSharingController { _, completion in
            Task { @MainActor in
                do {
                    guard let list = try self.persistence.viewContext.existingObject(with: objectID) as? SharedList else {
                        completion(nil, nil, PersistenceError.missingShareURL)
                        return
                    }
                    let share = try await self.persistence.share(list)
                    share[CKShare.SystemFieldKey.title] = title as CKRecordValue
                    share.publicPermission = .none
                    completion(share, ckContainer, nil)
                } catch {
                    completion(nil, nil, error)
                }
            }
        }

        controller.availablePermissions = [.allowReadWrite, .allowPrivate]
        controller.delegate = self
        controller.modalPresentationStyle = .formSheet

        guard let presenter = Self.topViewController() else {
            onFailure?(CloudSharingPresentationError.noPresenter)
            self.onFailure = nil
            return
        }

        if let popover = controller.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        presenter.present(controller, animated: true)
    }

    func itemTitle(for csc: UICloudSharingController) -> String? {
        csc.share?[CKShare.SystemFieldKey.title] as? String ?? "List"
    }

    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        onFailure?(error)
    }

    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        persistPresentedShare(csc.share)
    }

    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        persistPresentedShare(csc.share)
    }

    private func persistPresentedShare(_ share: CKShare?) {
        guard let share, let privateStore = persistence.privateStore else { return }
        persistence.container.persistUpdatedShare(share, in: privateStore) { _, error in
            if let error {
                print("persistUpdatedShare failed: \(error)")
            }
        }
    }

    private static func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
