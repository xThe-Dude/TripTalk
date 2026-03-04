import SwiftUI

struct CatalogFilterSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $state.catalogCategoryFilter) {
                        Text("All").tag(nil as SubstanceCategory?)
                        ForEach(SubstanceCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat as SubstanceCategory?)
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

                Section("Jurisdiction") {
                    Picker("Jurisdiction", selection: $state.selectedJurisdiction) {
                        ForEach(Jurisdiction.allCases) { j in
                            Text(j.rawValue).tag(j)
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
                        appState.catalogCategoryFilter = nil
                        appState.catalogEffectFilter = nil
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
