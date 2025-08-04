// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let appBlueColor = ColorAsset(name: "AppBlueColor")
    internal static let appDisableGrayColor = ColorAsset(name: "AppDisableGrayColor")
    internal static let appNewBlackColor = ColorAsset(name: "AppNewBlackColor")
    internal static let appNewInfoColor = ColorAsset(name: "AppNewInfoColor")
    internal static let appPopularInfoColor = ColorAsset(name: "AppPopularInfoColor")
    internal static let appSeperatorColor = ColorAsset(name: "AppSeperatorColor")
    internal static let appTitleDarkColor = ColorAsset(name: "AppTitleDarkColor")
    internal static let appTitleLightColor = ColorAsset(name: "AppTitleLightColor")
    internal static let appWorkoutBottom = ColorAsset(name: "AppWorkoutBottom")
  }
  internal enum Onboarding {
    internal static let bkgndBattery = ImageAsset(name: "Onboarding/Bkgnd - Battery")
    internal static let bkgndClasses = ImageAsset(name: "Onboarding/Bkgnd - Classes")
    internal static let bkgndDownloads = ImageAsset(name: "Onboarding/Bkgnd - Downloads")
    internal static let bkgndFilter = ImageAsset(name: "Onboarding/Bkgnd - Filter")
    internal static let bkgndMetrics = ImageAsset(name: "Onboarding/Bkgnd - Metrics")
    internal static let bkgndPacer = ImageAsset(name: "Onboarding/Bkgnd - Pacer")
    internal static let bkgndProfile = ImageAsset(name: "Onboarding/Bkgnd - Profile")
    internal static let bkgndSeries = ImageAsset(name: "Onboarding/Bkgnd - Series")
    internal static let onboardingPointer = ImageAsset(name: "Onboarding/onboarding_pointer")
  }
  internal enum TabBars {
    internal static let icFilter = ImageAsset(name: "ic_filter")
    internal static let iconBatteryTabbar = ImageAsset(name: "icon_battery_tabbar")
    internal static let iconBatteryTabbarSelected = ImageAsset(name: "icon_battery_tabbar_selected")
    internal static let iconClassesTabbar = ImageAsset(name: "icon_classes_tabbar")
    internal static let iconClassesTabbarSelected = ImageAsset(name: "icon_classes_tabbar_selected")
    internal static let iconDownloadTabbar = ImageAsset(name: "icon_download_tabbar")
    internal static let iconDownloadTabbarSelected = ImageAsset(name: "icon_download_tabbar_selected")
    internal static let iconFilterTabbar = ImageAsset(name: "icon_filter_tabbar")
    internal static let iconFilterTabbarSelected = ImageAsset(name: "icon_filter_tabbar_selected")
    internal static let iconMetricsTabbar = ImageAsset(name: "icon_metrics_tabbar")
    internal static let iconMetricsTabbarSelected = ImageAsset(name: "icon_metrics_tabbar_selected")
    internal static let iconProfileTabbar = ImageAsset(name: "icon_profile_tabbar")
    internal static let iconProfileTabbarSelected = ImageAsset(name: "icon_profile_tabbar_selected")
    internal static let iconSeriesTabbar = ImageAsset(name: "icon_series_tabbar")
    internal static let iconSeriesTabbarSelected = ImageAsset(name: "icon_series_tabbar_selected")
    internal static let iconTempotrainerTabbar = ImageAsset(name: "icon_tempotrainer_tabbar")
    internal static let iconTempotrainerTabbarSelected = ImageAsset(name: "icon_tempotrainer_tabbar_selected")
  }
  internal enum Tutorials {
    internal static let _1 = ImageAsset(name: "Tutorials/1")
    internal static let _10 = ImageAsset(name: "Tutorials/10")
    internal static let _11 = ImageAsset(name: "Tutorials/11")
    internal static let _12 = ImageAsset(name: "Tutorials/12")
    internal static let _13 = ImageAsset(name: "Tutorials/13")
    internal static let _14 = ImageAsset(name: "Tutorials/14")
    internal static let _15 = ImageAsset(name: "Tutorials/15")
    internal static let _16 = ImageAsset(name: "Tutorials/16")
    internal static let _17 = ImageAsset(name: "Tutorials/17")
    internal static let _18 = ImageAsset(name: "Tutorials/18")
    internal static let _2 = ImageAsset(name: "Tutorials/2")
    internal static let _3 = ImageAsset(name: "Tutorials/3")
    internal static let _4 = ImageAsset(name: "Tutorials/4")
    internal static let _5 = ImageAsset(name: "Tutorials/5")
    internal static let _7 = ImageAsset(name: "Tutorials/7")
    internal static let _8 = ImageAsset(name: "Tutorials/8")
    internal static let _9 = ImageAsset(name: "Tutorials/9")
  }
  internal static let appWhiteLogo = ImageAsset(name: "app_white_logo")
  internal static let icApple = ImageAsset(name: "ic_apple")
  internal static let icArrow = ImageAsset(name: "ic_arrow")
  internal static let icBack = ImageAsset(name: "ic_back")
  internal static let icBluetooth = ImageAsset(name: "ic_bluetooth")
  internal static let icDownloadBG = ImageAsset(name: "ic_downloadBG")
  internal static let icEmail = ImageAsset(name: "ic_email")
  internal static let icEquipment = ImageAsset(name: "ic_equipment")
  internal static let icFb = ImageAsset(name: "ic_fb")
  internal static let icGoogle = ImageAsset(name: "ic_google")
  internal static let icLogo = ImageAsset(name: "ic_logo")
  internal static let icNext = ImageAsset(name: "ic_next")
  internal static let icPassword = ImageAsset(name: "ic_password")
  internal static let icProfile = ImageAsset(name: "ic_profile")
  internal static let icSubscriptionLogo = ImageAsset(name: "ic_subscriptionLogo")
  internal static let icWorkoutBG = ImageAsset(name: "ic_workoutBG")
  internal static let icWorkoutProfile = ImageAsset(name: "ic_workoutProfile")
  internal static let iconAchievementDefault = ImageAsset(name: "icon_achievement_default")
  internal static let iconAdd = ImageAsset(name: "icon_add")
  internal static let iconBackArrow = ImageAsset(name: "icon_back_arrow")
  internal static let iconBluetoothDisable = ImageAsset(name: "icon_bluetooth_disable")
  internal static let iconBluetoothEnable = ImageAsset(name: "icon_bluetooth_enable")
  internal static let iconCalendar = ImageAsset(name: "icon_calendar")
  internal static let iconCall = ImageAsset(name: "icon_call")
  internal static let iconCharging = ImageAsset(name: "icon_charging")
  internal static let iconChargingYellow = ImageAsset(name: "icon_charging_yellow")
  internal static let iconChat = ImageAsset(name: "icon_chat")
  internal static let iconCheckAppColor = ImageAsset(name: "icon_check_appColor")
  internal static let iconCheckBig = ImageAsset(name: "icon_check_big")
  internal static let iconCheckCircle = ImageAsset(name: "icon_check_circle")
  internal static let iconClose = ImageAsset(name: "icon_close")
  internal static let iconContinueTutorial = ImageAsset(name: "icon_continue_tutorial")
  internal static let iconContinueTutorialZ2 = ImageAsset(name: "icon_continue_tutorial_Z2")
  internal static let iconCross = ImageAsset(name: "icon_cross")
  internal static let iconDefault = ImageAsset(name: "icon_default")
  internal static let iconDeleteAccount = ImageAsset(name: "icon_delete_account")
  internal static let iconDistance = ImageAsset(name: "icon_distance")
  internal static let iconDownArrow = ImageAsset(name: "icon_down_arrow")
  internal static let iconDownArrowOnly = ImageAsset(name: "icon_down_arrow_only")
  internal static let iconDownloaded = ImageAsset(name: "icon_downloaded")
  internal static let iconDownloading = ImageAsset(name: "icon_downloading")
  internal static let iconEmail = ImageAsset(name: "icon_email")
  internal static let iconFilter = ImageAsset(name: "icon_filter")
  internal static let iconFirmwareUpdate = ImageAsset(name: "icon_firmware_update")
  internal static let iconFullWave = ImageAsset(name: "icon_full_wave")
  internal static let iconHeadset = ImageAsset(name: "icon_headset")
  internal static let iconHeadsetColoured = ImageAsset(name: "icon_headset_coloured")
  internal static let iconHeadsetColouredV2 = ImageAsset(name: "icon_headset_coloured_v2")
  internal static let iconHeadsetHalf = ImageAsset(name: "icon_headset_half")
  internal static let iconHeadsetMinus = ImageAsset(name: "icon_headset_minus")
  internal static let iconHeadsetPlus = ImageAsset(name: "icon_headset_plus")
  internal static let iconHeadsetSyncDistance = ImageAsset(name: "icon_headset_sync_distance")
  internal static let iconHeadsetVerticalIndicator = ImageAsset(name: "icon_headset_vertical_indicator")
  internal static let iconHeadsetVerticalIndicatorZ2 = ImageAsset(name: "icon_headset_vertical_indicator_Z2")
  internal static let iconHeadsetZ2 = ImageAsset(name: "icon_headset_z2")
  internal static let iconInfo = ImageAsset(name: "icon_info")
  internal static let iconInsta = ImageAsset(name: "icon_insta")
  internal static let iconLogout = ImageAsset(name: "icon_logout")
  internal static let iconNextArrow = ImageAsset(name: "icon_next_arrow")
  internal static let iconPairing1 = ImageAsset(name: "icon_pairing_1")
  internal static let iconPairing2 = ImageAsset(name: "icon_pairing_2")
  internal static let iconPairing2Green = ImageAsset(name: "icon_pairing_2_green")
  internal static let iconPause = ImageAsset(name: "icon_pause")
  internal static let iconPauseWhiteSmall = ImageAsset(name: "icon_pause_white_small")
  internal static let iconPlay = ImageAsset(name: "icon_play")
  internal static let iconPlayWhiteBig = ImageAsset(name: "icon_play_white_big")
  internal static let iconPlayWhiteSmall = ImageAsset(name: "icon_play_white_small")
  internal static let iconPowerButton = ImageAsset(name: "icon_power_button")
  internal static let iconRadioColoured = ImageAsset(name: "icon_radio_coloured")
  internal static let iconRadioColouredV2 = ImageAsset(name: "icon_radio_coloured_v2")
  internal static let iconRadioHalf = ImageAsset(name: "icon_radio_half")
  internal static let iconShade = ImageAsset(name: "icon_shade")
  internal static let iconShare = ImageAsset(name: "icon_share")
  internal static let iconSharePopup = ImageAsset(name: "icon_share_popup")
  internal static let iconSide = ImageAsset(name: "icon_side")
  internal static let iconSoftbar = ImageAsset(name: "icon_softbar")
  internal static let iconSplash = ImageAsset(name: "icon_splash")
  internal static let iconStrokePopup = ImageAsset(name: "icon_stroke_popup")
  internal static let iconSyncstatus = ImageAsset(name: "icon_syncstatus")
  internal static let iconThumb = ImageAsset(name: "icon_thumb")
  internal static let iconThumsDownSelected = ImageAsset(name: "icon_thums_down_selected")
  internal static let iconThumsDownUnselected = ImageAsset(name: "icon_thums_down_unselected")
  internal static let iconThumsUpSelected = ImageAsset(name: "icon_thums_up_selected")
  internal static let iconThumsUpUnselected = ImageAsset(name: "icon_thums_up_unselected")
  internal static let iconTransmitter = ImageAsset(name: "icon_transmitter")
  internal static let iconTransmitterVertical = ImageAsset(name: "icon_transmitter_vertical")
  internal static let iconTurnOnTransmitter = ImageAsset(name: "icon_turn_on_transmitter")
  internal static let iconUncheckCircle = ImageAsset(name: "icon_uncheck_circle")
  internal static let iconUpArrow = ImageAsset(name: "icon_up_arrow")
  internal static let iconUpArrowOnly = ImageAsset(name: "icon_up_arrow_only")
  internal static let iconWorkoutComplete = ImageAsset(name: "icon_workout_complete")
  internal static let iconZygoBig = ImageAsset(name: "icon_zygo_big")
  internal static let invisible = ImageAsset(name: "invisible")
  internal static let placeholder = ImageAsset(name: "placeholder")
  internal static let playlistDefault = ImageAsset(name: "playlist_default")
  internal static let seperatorShadow = ImageAsset(name: "seperator_shadow")
  internal static let splashLogo = ImageAsset(name: "splash_logo")
  internal static let visibility = ImageAsset(name: "visibility")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

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
