import CodexBarCore
import AppKit
import SwiftUI

@MainActor
struct DisplayPane: View {
    private static let maxOverviewProviders = SettingsStore.mergedOverviewProviderLimit

    static func overviewProviderLimitText(limit: Int = Self.maxOverviewProviders) -> String {
        L("overview_choose_providers", String(limit))
    }

    @State private var isOverviewProviderPopoverPresented = false
    @Bindable var settings: SettingsStore
    @Bindable var store: UsageStore

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 16) {
                SettingsSection(contentSpacing: 12) {
                    Text(L("section_menu_bar"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    PreferenceToggleRow(
                        title: L("merge_icons_title"),
                        subtitle: L("merge_icons_subtitle"),
                        binding: self.$settings.mergeIcons)
                    PreferenceToggleRow(
                        title: L("switcher_shows_icons_title"),
                        subtitle: L("switcher_shows_icons_subtitle"),
                        binding: self.$settings.switcherShowsIcons)
                        .disabled(!self.settings.mergeIcons)
                        .opacity(self.settings.mergeIcons ? 1 : 0.5)
                    PreferenceToggleRow(
                        title: L("show_most_used_provider_title"),
                        subtitle: L("show_most_used_provider_subtitle"),
                        binding: self.$settings.menuBarShowsHighestUsage)
                        .disabled(!self.settings.mergeIcons)
                        .opacity(self.settings.mergeIcons ? 1 : 0.5)
                    PreferenceToggleRow(
                        title: L("menu_bar_shows_percent_title"),
                        subtitle: L("menu_bar_shows_percent_subtitle"),
                        binding: self.$settings.menuBarShowsBrandIconWithPercent)
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L("display_mode_title"))
                                .font(.body)
                            Text(L("display_mode_subtitle"))
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        Picker("Display mode", selection: self.$settings.menuBarDisplayMode) {
                            ForEach(MenuBarDisplayMode.allCases) { mode in
                                Text(mode.label).tag(mode)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .frame(maxWidth: 200)
                    }
                    .disabled(!self.settings.menuBarShowsBrandIconWithPercent)
                    .opacity(self.settings.menuBarShowsBrandIconWithPercent ? 1 : 0.5)
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L("wide_progress_gap_title"))
                                .font(.body)
                            Text(L("wide_progress_gap_subtitle"))
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        HStack(spacing: 8) {
                            Slider(
                                value: self.$settings.menuBarWideProgressPercentGap,
                                in: 0.1...2,
                                step: 0.1)
                                .frame(width: 120)
                            Text(String(format: "%.1f pt", self.settings.menuBarWideProgressPercentGap))
                                .font(.footnote.monospacedDigit())
                                .foregroundStyle(.secondary)
                                .frame(width: 44, alignment: .trailing)
                        }
                    }
                    .disabled(
                        !self.settings.menuBarShowsBrandIconWithPercent
                            || self.settings.menuBarDisplayMode != .wideProgress)
                    .opacity(
                        self.settings.menuBarShowsBrandIconWithPercent
                            && self.settings.menuBarDisplayMode == .wideProgress ? 1 : 0.5)
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L("wide_progress_percent_size_title"))
                                .font(.body)
                            Text(L("wide_progress_percent_size_subtitle"))
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        HStack(spacing: 8) {
                            Slider(
                                value: self.$settings.menuBarWideProgressPercentFontSize,
                                in: 6...9.5,
                                step: 0.5)
                                .frame(width: 120)
                            Text(String(format: "%.1f pt", self.settings.menuBarWideProgressPercentFontSize))
                                .font(.footnote.monospacedDigit())
                                .foregroundStyle(.secondary)
                                .frame(width: 44, alignment: .trailing)
                        }
                    }
                    .disabled(
                        !self.settings.menuBarShowsBrandIconWithPercent
                            || self.settings.menuBarDisplayMode != .wideProgress)
                    .opacity(
                        self.settings.menuBarShowsBrandIconWithPercent
                            && self.settings.menuBarDisplayMode == .wideProgress ? 1 : 0.5)
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L("wide_progress_bar_color_title"))
                                .font(.body)
                            Text(L("wide_progress_bar_color_subtitle"))
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        ColorPicker(
                            L("wide_progress_bar_color_title"),
                            selection: self.wideProgressBarColorBinding,
                            supportsOpacity: false)
                            .labelsHidden()
                    }
                    .disabled(
                        !self.settings.menuBarShowsBrandIconWithPercent
                            || self.settings.menuBarDisplayMode != .wideProgress)
                    .opacity(
                        self.settings.menuBarShowsBrandIconWithPercent
                            && self.settings.menuBarDisplayMode == .wideProgress ? 1 : 0.5)
                }

                Divider()

                SettingsSection(contentSpacing: 12) {
                    Text(L("section_menu_content"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    PreferenceToggleRow(
                        title: L("show_usage_as_used_title"),
                        subtitle: L("show_usage_as_used_subtitle"),
                        binding: self.$settings.usageBarsShowUsed)
                    PreferenceToggleRow(
                        title: L("show_reset_time_as_clock_title"),
                        subtitle: L("show_reset_time_as_clock_subtitle"),
                        binding: self.$settings.resetTimesShowAbsolute)
                    PreferenceToggleRow(
                        title: L("show_credits_extra_usage_title"),
                        subtitle: L("show_credits_extra_usage_subtitle"),
                        binding: self.$settings.showOptionalCreditsAndExtraUsage)
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L("multi_account_layout_title"))
                                .font(.body)
                            Text(L("multi_account_layout_subtitle"))
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        Picker(L("multi_account_layout_title"), selection: self.$settings.multiAccountMenuLayout) {
                            ForEach(MultiAccountMenuLayout.allCases) { layout in
                                Text(layout.label).tag(layout)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .frame(maxWidth: 200)
                    }
                    self.overviewProviderSelector
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .onAppear {
                self.reconcileOverviewSelection()
            }
            .onChange(of: self.settings.mergeIcons) { _, isEnabled in
                guard isEnabled else {
                    self.isOverviewProviderPopoverPresented = false
                    return
                }
                self.reconcileOverviewSelection()
            }
            .onChange(of: self.activeProvidersInOrder) { _, _ in
                if self.activeProvidersInOrder.isEmpty {
                    self.isOverviewProviderPopoverPresented = false
                }
                self.reconcileOverviewSelection()
            }
        }
    }

    private var wideProgressBarColorBinding: Binding<Color> {
        Binding(
            get: {
                Color(nsColor: Self.nsColor(hex: self.settings.menuBarWideProgressBarColorHex) ?? .darkGray)
            },
            set: { color in
                self.settings.menuBarWideProgressBarColorHex = Self.hexString(from: NSColor(color))
            })
    }

    private static func nsColor(hex: String) -> NSColor? {
        let sanitized = SettingsStore.sanitizedMenuBarWideProgressBarColorHex(hex)
        let start = sanitized.index(after: sanitized.startIndex)
        guard let value = Int(sanitized[start...], radix: 16) else { return nil }
        return NSColor(
            calibratedRed: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1)
    }

    private static func hexString(from color: NSColor) -> String {
        let resolved = color.usingColorSpace(.sRGB) ?? color
        let red = min(255, max(0, Int((resolved.redComponent * 255).rounded())))
        let green = min(255, max(0, Int((resolved.greenComponent * 255).rounded())))
        let blue = min(255, max(0, Int((resolved.blueComponent * 255).rounded())))
        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    private var overviewProviderSelector: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 12) {
                Text(L("overview_tab_providers_title"))
                    .font(.body)
                Spacer(minLength: 0)
                if self.showsOverviewConfigureButton {
                    Button(L("configure")) {
                        self.isOverviewProviderPopoverPresented = true
                    }
                    .offset(y: 1)
                    .popover(isPresented: self.$isOverviewProviderPopoverPresented, arrowEdge: .bottom) {
                        self.overviewProviderPopover
                    }
                }
            }

            if !self.settings.mergeIcons {
                Text(L("overview_enable_merge_icons_hint"))
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            } else if self.activeProvidersInOrder.isEmpty {
                Text(L("overview_no_providers_hint"))
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            } else {
                Text(self.overviewProviderSelectionSummary)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
    }

    private var overviewProviderPopover: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(Self.overviewProviderLimitText())
                .font(.headline)
            Text(L("overview_rows_follow_order"))
                .font(.footnote)
                .foregroundStyle(.tertiary)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(self.activeProvidersInOrder, id: \.self) { provider in
                        Toggle(
                            isOn: Binding(
                                get: { self.overviewSelectedProviders.contains(provider) },
                                set: { shouldSelect in
                                    self.setOverviewProviderSelection(provider: provider, isSelected: shouldSelect)
                                })) {
                            Text(self.providerDisplayName(provider))
                                .font(.body)
                        }
                        .toggleStyle(.checkbox)
                        .disabled(
                            !self.overviewSelectedProviders.contains(provider) &&
                                self.overviewSelectedProviders.count >= Self.maxOverviewProviders)
                    }
                }
            }
            .frame(maxHeight: 220)
        }
        .padding(12)
        .frame(width: 280)
    }

    private var activeProvidersInOrder: [UsageProvider] {
        self.store.enabledProviders()
    }

    private var overviewSelectedProviders: [UsageProvider] {
        self.settings.resolvedMergedOverviewProviders(
            activeProviders: self.activeProvidersInOrder,
            maxVisibleProviders: Self.maxOverviewProviders)
    }

    private var showsOverviewConfigureButton: Bool {
        self.settings.mergeIcons && !self.activeProvidersInOrder.isEmpty
    }

    private var overviewProviderSelectionSummary: String {
        let selectedNames = self.overviewSelectedProviders.map(self.providerDisplayName)
        guard !selectedNames.isEmpty else { return L("overview_no_providers_selected") }
        return selectedNames.joined(separator: ", ")
    }

    private func providerDisplayName(_ provider: UsageProvider) -> String {
        ProviderDescriptorRegistry.descriptor(for: provider).metadata.displayName
    }

    private func setOverviewProviderSelection(provider: UsageProvider, isSelected: Bool) {
        _ = self.settings.setMergedOverviewProviderSelection(
            provider: provider,
            isSelected: isSelected,
            activeProviders: self.activeProvidersInOrder,
            maxVisibleProviders: Self.maxOverviewProviders)
    }

    private func reconcileOverviewSelection() {
        _ = self.settings.reconcileMergedOverviewSelectedProviders(
            activeProviders: self.activeProvidersInOrder,
            maxVisibleProviders: Self.maxOverviewProviders)
    }
}
