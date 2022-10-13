import Foundation

/// Provides constants regarding app information.
///
/// - Note: Most values are provided by the main bundles `Info.plist`.
public enum App {
    public static var versionCode: Int { Int(buildNumber) ?? 0 }

    // Main info dictionary.
    public static var infoDictionary = Bundle.main.infoDictionary!

    // MARK: - Names

    /// Display name of the application.
    public static var name = infoDictionary["CFBundleDisplayName"] as! String

    /// Bundle identifier of the application.
    public static var bundleIdentifier = infoDictionary["CFBundleIdentifier"] as! String

    /// Build number.
    public static var buildNumber = infoDictionary["CFBundleVersion"] as! String

    /// Human-readable version name for this application.
    public static var version = infoDictionary["CFBundleShortVersionString"] as! String
}
