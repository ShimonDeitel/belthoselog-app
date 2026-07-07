import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ComponentLogStore
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: ComponentLog? = nil
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                ComponentLogTheme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editingItem = item
                        } label: {
                            row(for: item)
                        }
                        .listRowBackground(ComponentLogTheme.card)
                        .accessibilityIdentifier("row_\(item.name)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Belt and Hose Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                ComponentLogFormView(mode: .add) { new in
                    if !store.add(new) {
                        showingPaywall = true
                    }
                }
            }
            .sheet(item: $editingItem) { item in
                ComponentLogFormView(mode: .edit(item)) { updated in
                    store.update(updated)
                } onDelete: {
                    store.delete(id: item.id)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(ComponentLogTheme.accent)
    }

    @ViewBuilder
    private func row(for item: ComponentLog) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(ComponentLogTheme.bodyFont)
                .foregroundColor(ComponentLogTheme.textPrimary)
            Text(item.detail)
                .font(ComponentLogTheme.captionFont)
                .foregroundColor(ComponentLogTheme.textSecondary)
            Text(item.date, style: .date)
                .font(ComponentLogTheme.captionFont)
                .foregroundColor(ComponentLogTheme.accent)
        }
        .padding(.vertical, 4)
    }
}

enum ComponentLogFormMode {
    case add
    case edit(ComponentLog)
}

struct ComponentLogFormView: View {
    let mode: ComponentLogFormMode
    var onSave: (ComponentLog) -> Void
    var onDelete: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var detail: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Component name") {
                    TextField("Component name", text: $name)
                        .accessibilityIdentifier("nameField")
                }
                Section("Condition") {
                    TextField("Condition", text: $detail)
                        .accessibilityIdentifier("detailField")
                }
                Section("Replaced date") {
                    DatePicker("Replaced date", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("dateField")
                }
                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .accessibilityIdentifier("noteField")
                }
                if case .edit = mode, let onDelete {
                    Section {
                        Button("Delete", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(isEditing ? "Edit Component" : "New Component")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear(perform: populate)
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func populate() {
        if case .edit(let item) = mode {
            name = item.name
            detail = item.detail
            date = item.date
            note = item.note
        }
    }

    private func save() {
        var item: ComponentLog
        if case .edit(let existing) = mode {
            item = existing
        } else {
            item = ComponentLog(name: name, detail: detail, date: date)
        }
        item.name = name
        item.detail = detail
        item.date = date
        item.note = note
        onSave(item)
        dismiss()
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
        .environmentObject(ComponentLogStore())
        .environmentObject(PurchaseManager())
}
