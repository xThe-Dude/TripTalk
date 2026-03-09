import SwiftUI

struct ServicesFilterSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private var allOfferings: [String] {
        Array(Set(appState.services.flatMap { $0.offerings })).sorted()
    }

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            Form {
                Section(header: Text("Offerings").foregroundStyle(Color.ttSectionHeader)) {
                    Picker("Offering", selection: $state.servicesOfferingFilter) {
                        Text("All").tag(nil as String?)
                        ForEach(allOfferings, id: \.self) { offering in
                            Text(offering).tag(offering as String?)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Jurisdiction").foregroundStyle(Color.ttSectionHeader)) {
                    Picker("Jurisdiction", selection: $state.selectedJurisdiction) {
                        ForEach(Jurisdiction.allCases) { j in
                            Text(j.rawValue).tag(j)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                    .onChange(of: appState.selectedJurisdiction) {
                        appState.updateJurisdiction(appState.selectedJurisdiction)
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))
            }
            .scrollContentBackground(.hidden)
            .background(Color.ttSheetBg)
            .navigationTitle("Filter Services")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        appState.servicesOfferingFilter = nil
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
