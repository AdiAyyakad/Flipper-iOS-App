import Core
import Combine
import Inject
import Foundation

@MainActor
class DeviceViewModel: ObservableObject {
    @Published var appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var isPairingIssue = false

    @Published var device: Peripheral?
    @Published var status: Status = .noDevice {
        didSet { isPairingIssue = status == .pairingIssue }
    }

    var protobufVersion: String {
        device?.information?.protobufRevision ?? ""
    }

    var firmwareVersion: String {
        guard let info = device?.information else {
            return ""
        }

        let version = info
            .softwareRevision
            .split(separator: " ")
            .prefix(2)
            .reversed()
            .joined(separator: " ")

        return .init(version)
    }

    var firmwareBuild: String {
        guard let info = device?.information else {
            return ""
        }

        let build = info
            .softwareRevision
            .split(separator: " ")
            .suffix(1)
            .joined(separator: " ")

        return .init(build)
    }

    var internalSpace: String {
        device?.storage?.internal?.description ?? ""
    }

    var externalSpace: String {
        device?.storage?.external?.description ?? ""
    }

    init() {
        appState.$device
            .receive(on: DispatchQueue.main)
            .assign(to: \.device, on: self)
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.status, on: self)
            .store(in: &disposeBag)
    }

    func showWelcomeScreen() {
        appState.forgetDevice()
        appState.isFirstLaunch = true
    }

    func sync() {
        Task { await appState.synchronize() }
    }
}

extension String {
    static var noDevice: String { "No device" }
    static var unknown: String { "Unknown" }
}

extension StorageSpace: CustomStringConvertible {
    public var description: String {
        "\(free.hr) / \(total.hr)"
    }
}

extension Int {
    var hr: String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(self))
    }
}
