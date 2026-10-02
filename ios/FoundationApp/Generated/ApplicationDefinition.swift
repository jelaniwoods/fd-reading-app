struct GeneratedFoundationPlanProvenance: Equatable {
    let projectID: String
    let graphVersion: Int
    let targetID: String
    let targetProfile: String
    let loweringRelease: String
    let sourceSHA256: String
}

enum GeneratedApplication {
    static let appearance = ApplicationAppearance(theme: .light)
    static let applicationKeyComponent = "reading-list"
    static let displayName = "Reading List"
    static let railsOrigin = "https://reading-list.invalid"
    static let bundleIdentifier = "invalid.firstdraft.reading-list"
    static let usesPlaceholderIdentity = true
    static let foundationPlan = GeneratedFoundationPlanProvenance(
        projectID: "01a0fd25-6979-7e31-9371-5fea0b2654c3",
        graphVersion: 1,
        targetID: "rails",
        targetProfile: "rails-sketch/2026-09-bookmark-assets",
        loweringRelease: "foundation-plan-rails/ios-application-2026-08",
        sourceSHA256: "bdb2da3752ea1b8a7c9b1fe0ee80a4690302406c3e47729ebc332467439be74f"
    )
    static let navigation = [
        AppNavigationDefinition(
            id: "entity-index:01a0fd25-6b01-7bcb-979c-4c1ab9fe12a9",
            title: "Books",
            systemImageName: "bookmark",
            selectedSystemImageName: "bookmark.fill",
            path: "/books"
        )
    ]
}
