import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showSignup = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(FarmTheme.primary)
                    Text("Farm Management")
                        .font(.title2).fontWeight(.bold)
                    Text("Sign in to continue")
                        .font(.caption).foregroundColor(.secondary)
                }

                VStack(spacing: 14) {
                    AuthField(icon: "envelope", placeholder: "Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    AuthField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                }

                if let error { Text(error).font(.caption).foregroundColor(.red) }

                Button {
                    error = auth.login(email: email, password: password)
                } label: {
                    Text("Sign In")
                        .fontWeight(.bold).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(FarmTheme.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button("Don't have an account? Sign Up") { showSignup = true }
                    .font(.subheadline).foregroundColor(FarmTheme.primary)

                Spacer()
            }
            .padding(24)
            .background(FarmTheme.background)
            .sheet(isPresented: $showSignup) { SignupView() }
        }
    }
}

struct SignupView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var role: UserRole = .farmer
    @State private var adminCode = ""
    @State private var error: String?

    private var signupRoles: [UserRole] { [.farmer, .customer, .admin] }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(FarmTheme.primary)
                        Text("Create Account").font(.title3).fontWeight(.bold)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 14) {
                        AuthField(icon: "person", placeholder: "Full Name", text: $name)
                        AuthField(icon: "envelope", placeholder: "Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        AuthField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                        AuthField(icon: "lock.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("I am a:").font(.subheadline).fontWeight(.semibold)
                        HStack(spacing: 8) {
                            ForEach(signupRoles, id: \.self) { r in
                                Button { role = r } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: roleIcon(r)).font(.caption)
                                        Text(r.rawValue.capitalized).font(.caption2).fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .foregroundColor(role == r ? .white : FarmTheme.primary)
                                    .background(role == r ? FarmTheme.primary : FarmTheme.primary.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }

                        roleDescription
                    }

                    if role == .admin {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.shield.fill").foregroundColor(.orange).font(.caption)
                                Text("Admin Invite Code Required").font(.caption).fontWeight(.semibold).foregroundColor(.orange)
                            }
                            AuthField(icon: "key.fill", placeholder: "Enter invite code", text: $adminCode)
                            Text("Contact the platform owner to get an admin invite code.")
                                .font(.caption2).foregroundColor(.secondary)
                        }
                    }

                    if let error { Text(error).font(.caption).foregroundColor(.red) }

                    Button {
                        guard !name.isEmpty, !email.isEmpty else { error = "Fill in all fields"; return }
                        guard password == confirmPassword else { error = "Passwords don't match"; return }
                        guard password.count >= 6 else { error = "Password must be at least 6 characters"; return }
                        error = auth.signup(name: name, email: email, password: password, role: role, adminCode: role == .admin ? adminCode : nil)
                        if error == nil { dismiss() }
                    } label: {
                        Text("Create Account")
                            .fontWeight(.bold).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(FarmTheme.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(24)
            }
            .background(FarmTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }

    private func roleIcon(_ r: UserRole) -> String {
        switch r {
        case .farmer: return "leaf.fill"
        case .customer: return "cart.fill"
        case .admin: return "shield.fill"
        }
    }

    @ViewBuilder
    private var roleDescription: some View {
        switch role {
        case .farmer:
            roleHint(icon: "leaf.fill", color: FarmTheme.primary,
                     text: "Manage fields, crops, livestock. Sell produce on the marketplace. Access AI scanning tools.")
        case .customer:
            roleHint(icon: "cart.fill", color: .blue,
                     text: "Browse and buy fresh produce directly from farmers. Track orders.")
        case .admin:
            roleHint(icon: "shield.fill", color: .orange,
                     text: "Manage platform listings, orders, and users. Requires invite code.")
        }
    }

    private func roleHint(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon).font(.caption).foregroundColor(color).padding(.top, 2)
            Text(text).font(.caption2).foregroundColor(.secondary)
        }
        .padding(10)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(FarmTheme.primary).frame(width: 20)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding(14)
        .background(FarmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: FarmTheme.shadow, radius: 3, y: 1)
    }
}
