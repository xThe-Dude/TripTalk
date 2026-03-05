import SwiftUI

struct CatalogFilterSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            Form {
                Section("Substance Type") {
                    Picker("Substance", selection: $state.catalogSubstanceTypeFilter) {
                        Text("All").tag(nil as SubstanceType?)
                        ForEach(SubstanceType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type as SubstanceType?)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Potency") {
                    Picker("Potency", selection: $state.catalogPotencyFilter) {
                        Text("All").tag(nil as Potency?)
                        ForEach(Potency.allCases) { p in
                            Text(p.rawValue).tag(p as Potency?)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Difficulty") {
                    Picker("Difficulty", selection: $state.catalogDifficultyFilter) {
                        Text("All").tag(nil as Difficulty?)
                        ForEach(Difficulty.allCases) { d in
                            Text(d.rawValue).tag(d as Difficulty?)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Effects") {
                    Picker("Effect", selection: $state.catalogEffectFilter) {
                        Text("All").tag(nil as EffectTag?)
                        ForEach(EffectTag.allCases) { effect in
                            Text(effect.rawValue).tag(effect as EffectTag?)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        appState.resetCatalogFilters()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
