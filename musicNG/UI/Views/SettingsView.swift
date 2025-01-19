//
//  SettingsView.swift
//  musicNG
//
//  Created by Max Sudovsky on 20.12.2024.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var login: String = Settings.shared.username
    @State private var pass: String = Settings.shared.password
    @State private var ip: String = Settings.shared.address
    @State private var shareName: String = Settings.shared.shareName

    @State private var showError: Bool = false
    @State private var errorMessage: String? = nil
    @State private var titleMessage: String = ""

    @State private var showingActionSheet: Bool = false
    @State private var titles: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Connecting to PC")
                    .font(.system(size: 21))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.horizontal, .top], 16)
                
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                    TextField("Login", text: $login)
                        .textContentType(.username)
                        .font(.system(size: 19))
                        .autocorrectionDisabled()
                        .onChange(of: login) { newValue in
                            Settings.shared.username = newValue
                        }
                }
                .padding(.horizontal, 16)
                
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "lock.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                    
                    SecureField("Password", text: $pass)
                        .textContentType(.password)
                        .font(.system(size: 19))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: pass) { newValue in
                            Settings.shared.password = newValue
                        }
                    
                }
                .padding(.horizontal, 16)
                
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "wifi.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                    
                    TextField("IP-address", text: $ip)
                        .font(.system(size: 19))
                        .autocorrectionDisabled()
                        .onChange(of: ip) { newValue in
                            Settings.shared.address = newValue.replacingOccurrences(of: ",", with: ".")
                        }
                }
                .padding(.horizontal, 16)
                
                Button {
                    showShareList()
                } label: {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "folder.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44)
                        Text(shareName.isEmpty ? "Home directory" : shareName)
                            .font(.system(size: 19))
                            .opacity(shareName.isEmpty ? 0.25 : 1)
                        Spacer()
                    }
                }
                .padding(.horizontal, 16)
                
                Button {
                    Downloads.shared.client.updateClient()
                    Downloads.shared.client.listShare { error, data in
                        if let error = error {
                            titleMessage = "Connection error".localized
                            errorMessage = error
                            showError = true
                        } else {
                            titleMessage = "Perfect!".localized
                            errorMessage = "Connection established successfully".localized
                            UIApplication.shared.endEditing()
                            Settings.shared.save()
                        }
                        showError = true
                    }
                    
                } label: {
                    Text("Check connection")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.main)
                        .padding(.horizontal, 16)
                }
                
            }
        }
        .background(.back)
        .okMessage(showingAlert: $showError, title: $titleMessage, subtitle: $errorMessage) {
            errorMessage = nil
            titleMessage = ""
        }
        .confirmationDialog("Select a shared folder", isPresented: $showingActionSheet, titleVisibility: .visible) {
            ForEach(titles, id: \.self) { share in
                Button(share) {
                    shareName = share
                    Settings.shared.shareName = share
                    Downloads.shared.client.updateClient()
                    Settings.shared.save()
                }
            }
        }
        .onSubmit {
            Downloads.shared.client.updateClient()
            Settings.shared.save()
        }
    }
    
    func showShareList() {
        Downloads.shared.client.updateClient()
        Downloads.shared.client.listShare { error, files in
            if let error = error {
                titleMessage = "Connection error".localized
                errorMessage = error
                showError = true
                return
            }

            guard let files = files, files.count > 0 else {
                titleMessage = "Error".localized
                errorMessage = "Connection established, but no shared folders found".localized
                showError = true
                return
            }

            titles = files
            
            showingActionSheet.toggle()
        }
    }
}

#Preview {
    SettingsView()
}
