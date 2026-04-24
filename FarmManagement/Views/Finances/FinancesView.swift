import SwiftUI

struct FinancesView: View {
    @EnvironmentObject var store: DataStore
    @State private var showAdd = false

    var totalIncome: Double { store.transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount } }
    var totalExpense: Double { store.transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount } }
    var profit: Double { totalIncome - totalExpense }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    profitBanner
                    HStack(spacing: 10) {
                        StatBadge(icon: "arrow.down.circle", value: "R\(totalIncome)", label: "Income", color: .green)
                        StatBadge(icon: "arrow.up.circle", value: "R\(totalExpense)", label: "Expenses", color: .red)
                    }

                    if store.transactions.isEmpty {
                        FarmCard {
                            HStack {
                                Image(systemName: "banknote")
                                    .foregroundColor(FarmTheme.subtle)
                                Text("No transactions yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Transactions")
                                .font(.headline)
                            ForEach(store.transactions) { t in
                                FarmCard {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(t.type == .income ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                                                .frame(width: 38, height: 38)
                                            Image(systemName: t.type == .income ? "arrow.down.left" : "arrow.up.right")
                                                .font(.caption)
                                                .foregroundColor(t.type == .income ? .green : .red)
                                        }
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(t.description)
                                                .fontWeight(.medium)
                                                .font(.subheadline)
                                            Text(t.category)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("\(t.type == .income ? "+" : "-")R\(t.amount, specifier: "%.2f")")
                                                .fontWeight(.semibold)
                                                .font(.subheadline)
                                                .foregroundColor(t.type == .income ? .green : .red)
                                            Text(t.date, style: .date)
                                                .font(.caption2)
                                                .foregroundColor(FarmTheme.subtle)
                                        }
                                    }
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        store.deleteTransaction(t)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(FarmTheme.background)
            .navigationTitle("Finances")
            .toolbar {
                Button { showAdd = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(FarmTheme.primary)
                }
            }
            .sheet(isPresented: $showAdd) { AddTransactionView() }
        }
    }

    private var profitBanner: some View {
        VStack(spacing: 4) {
            Text("Net Profit")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            Text("R\(profit, specifier: "%.2f")")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(profit >= 0 ? FarmTheme.gradient : LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct AddTransactionView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss
    @State private var type: TransactionType = .expense
    @State private var category = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var description = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Details") {
                    TextField("Description", text: $description)
                    TextField("Category", text: $category)
                    TextField("Amount (R)", text: $amount).keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addTransaction(Transaction(type: type, category: category,
                                                          amount: Double(amount) ?? 0, date: date, description: description))
                        dismiss()
                    }
                    .disabled(description.isEmpty || amount.isEmpty)
                    .fontWeight(.semibold)
                    .foregroundColor(FarmTheme.primary)
                }
            }
        }
    }
}
