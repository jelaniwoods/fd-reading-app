import Foundation
import HotwireNative
import Testing
import UIKit

@testable import FoundationApp

@MainActor
struct GeneratedApplicationDefinitionTests {
    @Test
    func definesFoundationPlanNavigation() {
        let rootURL = URL(string: "https://app.example.test")!
        let entries = AppNavigation.make(rootURL: rootURL)
        let container = AppNavigationContainer(entries: entries)

        #expect(
            GeneratedApplication.navigation.map(\.id) == [
                "entity-index:01a0fd25-6b01-7bcb-979c-4c1ab9fe12a9"
            ]
        )
        #expect(
            GeneratedApplication.navigation.map(\.title) == [
                "Books"
            ]
        )
        #expect(
            GeneratedApplication.navigation.map(\.systemImageName) == [
                "bookmark"
            ]
        )
        #expect(
            GeneratedApplication.navigation.map(\.selectedSystemImageName) == [
                "bookmark.fill"
            ]
        )
        #expect(
            GeneratedApplication.navigation.map(\.path) == [
                "/books"
            ]
        )
        #expect(
            entries.map(\.id) == [
                "entity-index:01a0fd25-6b01-7bcb-979c-4c1ab9fe12a9"
            ]
        )
        #expect(
            entries.map(\.title) == [
                "Books"
            ]
        )
        #expect(
            entries.map(\.url.path) == [
                "/books"
            ]
        )
        #expect(entries.allSatisfy { $0.image != nil })
        #expect(entries.allSatisfy { $0.selectedImage != nil })
        #expect(container.rootViewController is UINavigationController)
        #expect(!(container.rootViewController is UITabBarController))
    }

    @Test
    func identifiesTheGeneratedApplicationAndFoundationPlan() {
        #expect(
            GeneratedApplication.appearance.interfaceStyle
                == .light
        )
        #expect(
            GeneratedApplication.applicationKeyComponent
                == "reading-list"
        )
        #expect(
            GeneratedApplication.displayName
                == "Reading List"
        )
        #expect(
            GeneratedApplication.railsOrigin
                == "https://reading-list.invalid"
        )
        #expect(
            GeneratedApplication.bundleIdentifier
                == "invalid.firstdraft.reading-list"
        )
        #expect(
            GeneratedApplication.usesPlaceholderIdentity
                == true
        )
        #expect(
            GeneratedApplication.foundationPlan.projectID
                == "01a0fd25-6979-7e31-9371-5fea0b2654c3"
        )
        #expect(
            GeneratedApplication.foundationPlan.graphVersion
                == 1
        )
        #expect(
            GeneratedApplication.foundationPlan.targetID
                == "rails"
        )
        #expect(
            GeneratedApplication.foundationPlan.targetProfile
                == "rails-sketch/2026-09-bookmark-assets"
        )
        #expect(
            GeneratedApplication.foundationPlan.loweringRelease
                == "foundation-plan-rails/ios-application-2026-08"
        )
        #expect(
            GeneratedApplication.foundationPlan.sourceSHA256
                == "bdb2da3752ea1b8a7c9b1fe0ee80a4690302406c3e47729ebc332467439be74f"
        )
        #expect(
            Bundle.main.object(
                forInfoDictionaryKey: "FoundationPlanSHA256"
            ) as? String == GeneratedApplication.foundationPlan.sourceSHA256
        )
    }
}
