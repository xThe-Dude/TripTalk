import SwiftUI

struct CatalogFilterSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            Form {
                Section(header: Text("Substance Type").foregroundStyle(Color.ttSectionHeader)) {
                    Picker("Substance", selection: $state.catalogSubstanceTypeFilter) {
                        Text("All").tag(nil as SubstanceType?)
                        ForEach(SubstanceType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type as SubstanceType?)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Potency").foregroundStyle(Color.ttSectionHeader)) {
                    Picker("Potency", selection: $state.catalogPotencyFilter) {
                        Text("All").tag(nil as Potency?)
                        ForEach(Potency.allCases) { p in
                            Text(p.rawValue).tag(p as Potency?)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Difficulty").foregroundStyle(Color.ttSectionHeader)) {
                    Picker("Difficulty", selection: $state.catalogDifficultyFilter) {
                        Text("All").tag(nil as Difficulty?)
                        ForEach(Difficulty.allCases) { d in
                            Text(d.rawValue).tag(d as Difficulty?)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Effects").foregroundStyle(Color.ttSectionHeader)) {
                    Picker("Effect", selection: $state.catalogEffectFilter) {
                        Text("All").tag(nil as EffectTag?)
                        ForEach(EffectTag.allCases) { effect in
                            Text(effect.rawValue).tag(effect as EffectTag?)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                .listRowBackground(Color.white.opacity(0.05))
            }
            .scrollContentBackground(.hidden)
            .background(Color.ttSheetBg)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        appState.resetCatalogFilters()
                    }
                    .foregroundStyle(Color.ttAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.ttAccent)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(Color.ttSheetBg.opacity(0.95))
    }
}
