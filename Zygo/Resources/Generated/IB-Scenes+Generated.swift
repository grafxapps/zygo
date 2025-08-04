// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import SideMenuSwift
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length implicit_return

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum CountingLapsAnimaitionZ2VC: StoryboardType {
    internal static let storyboardName = "CountingLapsAnimaitionZ2VC"

    internal static let countingLapsAnimationZ2VC = SceneType<Zygo.CountingLapsAnimaitionZ2VC>(storyboard: Self.self, identifier: "CountingLapsAnimationZ2VC")
  }
  internal enum HeadsetDFUUpdateVerifyVC: StoryboardType {
    internal static let storyboardName = "HeadsetDFUUpdateVerifyVC"

    internal static let headsetDFUUpdateVerifyVC = SceneType<Zygo.HeadsetDFUUpdateVerifyVC>(storyboard: Self.self, identifier: "HeadsetDFUUpdateVerifyVC")
  }
  internal enum Instructor: StoryboardType {
    internal static let storyboardName = "Instructor"

    internal static let instructorViewController = SceneType<Zygo.InstructorViewController>(storyboard: Self.self, identifier: "InstructorViewController")

    internal static let instructorsListViewController = SceneType<Zygo.InstructorsListViewController>(storyboard: Self.self, identifier: "InstructorsListViewController")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: Self.self)
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<Zygo.NavigationController>(storyboard: Self.self)

    internal static let badgesVC = SceneType<Zygo.BadgesVC>(storyboard: Self.self, identifier: "BadgesVC")

    internal static let batteyVC = SceneType<Zygo.BatteyVC>(storyboard: Self.self, identifier: "BatteyVC")

    internal static let contentNavigation = SceneType<Zygo.NavigationController>(storyboard: Self.self, identifier: "ContentNavigation")

    internal static let downloadsViewController = SceneType<Zygo.DownloadsViewController>(storyboard: Self.self, identifier: "DownloadsViewController")

    internal static let filterViewController = SceneType<Zygo.FilterViewController>(storyboard: Self.self, identifier: "FilterViewController")

    internal static let historyViewController = SceneType<Zygo.HistoryViewController>(storyboard: Self.self, identifier: "HistoryViewController")

    internal static let homeTabBar = SceneType<Zygo.HomeTabBar>(storyboard: Self.self, identifier: "HomeTabBar")

    internal static let homeTabBarContainerVC = SceneType<Zygo.HomeTabBarContainerVC>(storyboard: Self.self, identifier: "HomeTabBarContainerVC")

    internal static let infoViewController = SceneType<Zygo.InfoViewController>(storyboard: Self.self, identifier: "InfoViewController")

    internal static let metricsBTVC = SceneType<Zygo.MetricsBTVC>(storyboard: Self.self, identifier: "MetricsBTVC")

    internal static let metricsViewController = SceneType<Zygo.MetricsViewController>(storyboard: Self.self, identifier: "MetricsViewController")

    internal static let profileViewController = SceneType<Zygo.ProfileViewController>(storyboard: Self.self, identifier: "ProfileViewController")

    internal static let tempoTrainerViewController = SceneType<Zygo.TempoTrainerViewController>(storyboard: Self.self, identifier: "TempoTrainerViewController")

    internal static let workoutDetailViewController = SceneType<Zygo.WorkoutDetailViewController>(storyboard: Self.self, identifier: "WorkoutDetailViewController")

    internal static let workoutPlayerViewController = SceneType<Zygo.WorkoutPlayerViewController>(storyboard: Self.self, identifier: "WorkoutPlayerViewController")

    internal static let workoutSeriesViewController = SceneType<Zygo.WorkoutSeriesViewController>(storyboard: Self.self, identifier: "WorkoutSeriesViewController")

    internal static let workoutsViewController = SceneType<Zygo.WorkoutsViewController>(storyboard: Self.self, identifier: "WorkoutsViewController")
  }
  internal enum ReferFriend: StoryboardType {
    internal static let storyboardName = "ReferFriend"
  }
  internal enum Registration: StoryboardType {
    internal static let storyboardName = "Registration"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Self.self)

    internal static let createProfileViewController = SceneType<Zygo.CreateProfileViewController>(storyboard: Self.self, identifier: "CreateProfileViewController")

    internal static let forgotpasswordViewController = SceneType<Zygo.ForgotpasswordViewController>(storyboard: Self.self, identifier: "ForgotpasswordViewController")

    internal static let loginNavigation = SceneType<UIKit.UINavigationController>(storyboard: Self.self, identifier: "LoginNavigation")

    internal static let signInViewController = SceneType<Zygo.SignInViewController>(storyboard: Self.self, identifier: "SignInViewController")

    internal static let signUpViewController = SceneType<Zygo.SignUpViewController>(storyboard: Self.self, identifier: "SignUpViewController")

    internal static let subscriptionCancelVC = SceneType<Zygo.SubscriptionCancelVC>(storyboard: Self.self, identifier: "SubscriptionCancelVC")

    internal static let subscriptionViewController = SceneType<Zygo.SubscriptionViewController>(storyboard: Self.self, identifier: "SubscriptionViewController")

    internal static let verifyForgotPasswordViewController = SceneType<Zygo.VerifyForgotPasswordViewController>(storyboard: Self.self, identifier: "VerifyForgotPasswordViewController")
  }
  internal enum RenameBluetoothIDVC: StoryboardType {
    internal static let storyboardName = "RenameBluetoothIDVC"

    internal static let renameBluetoothIDVC = SceneType<Zygo.RenameBluetoothIDVC>(storyboard: Self.self, identifier: "RenameBluetoothIDVC")
  }
  internal enum SideMenu: StoryboardType {
    internal static let storyboardName = "SideMenu"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: Self.self)

    internal static let alreadyUpdatedVC = SceneType<Zygo.AlreadyUpdatedVC>(storyboard: Self.self, identifier: "AlreadyUpdatedVC")

    internal static let bluetoothViewController = SceneType<Zygo.BluetoothViewController>(storyboard: Self.self, identifier: "BluetoothViewController")

    internal static let changePasswordVC = SceneType<Zygo.ChangePasswordVC>(storyboard: Self.self, identifier: "ChangePasswordVC")

    internal static let contactUsViewController = SceneType<Zygo.ContactUsViewController>(storyboard: Self.self, identifier: "ContactUsViewController")

    internal static let countingLapsAnimationVC = SceneType<Zygo.CountingLapsAnimationVC>(storyboard: Self.self, identifier: "CountingLapsAnimationVC")

    internal static let customerSupportVC = SceneType<Zygo.CustomerSupportVC>(storyboard: Self.self, identifier: "CustomerSupportVC")

    internal static let firmwareUpdateSuccessVC = SceneType<Zygo.FirmwareUpdateSuccessVC>(storyboard: Self.self, identifier: "FirmwareUpdateSuccessVC")

    internal static let firmwareUpdateVC = SceneType<Zygo.FirmwareUpdateVC>(storyboard: Self.self, identifier: "FirmwareUpdateVC")

    internal static let getStartedVC = SceneType<Zygo.GetStartedVC>(storyboard: Self.self, identifier: "GetStartedVC")

    internal static let hallOfFameVC = SceneType<Zygo.HallOfFameVC>(storyboard: Self.self, identifier: "HallOfFameVC")

    internal static let headsetNotConnectedVC = SceneType<Zygo.HeadsetNotConnectedVC>(storyboard: Self.self, identifier: "HeadsetNotConnectedVC")

    internal static let headsetSyncAnimationVC = SceneType<Zygo.HeadsetSyncAnimationVC>(storyboard: Self.self, identifier: "HeadsetSyncAnimationVC")

    internal static let helpVC = SceneType<Zygo.HelpVC>(storyboard: Self.self, identifier: "HelpVC")

    internal static let menuNavigation = SceneType<Zygo.MenuViewController>(storyboard: Self.self, identifier: "MenuNavigation")

    internal static let pairingVC = SceneType<Zygo.PairingVC>(storyboard: Self.self, identifier: "PairingVC")

    internal static let preFirmwareUpdateVC = SceneType<Zygo.PreFirmwareUpdateVC>(storyboard: Self.self, identifier: "PreFirmwareUpdateVC")

    internal static let settingsViewController = SceneType<Zygo.SettingsViewController>(storyboard: Self.self, identifier: "SettingsViewController")

    internal static let sideMenu = SceneType<SideMenuSwift.SideMenuController>(storyboard: Self.self, identifier: "SideMenu")

    internal static let walkieTalkieVC = SceneType<Zygo.WalkieTalkieVC>(storyboard: Self.self, identifier: "WalkieTalkieVC")

    internal static let yourAchievementViewController = SceneType<Zygo.YourAchievementViewController>(storyboard: Self.self, identifier: "YourAchievementViewController")
  }
  internal enum TutorialsZ2VC: StoryboardType {
    internal static let storyboardName = "TutorialsZ2VC"

    internal static let tutorialsZ2VC = SceneType<Zygo.TutorialsZ2VC>(storyboard: Self.self, identifier: "TutorialsZ2VC")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: BundleToken.bundle)
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    return storyboard.storyboard.instantiateViewController(identifier: identifier, creator: block)
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController(creator: block) else {
      fatalError("Storyboard \(storyboard.storyboardName) does not have an initial scene.")
    }
    return controller
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
