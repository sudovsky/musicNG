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

    var body: some View {
        VStack(spacing: 12) {
            Text("Подключение к ПК")
                .font(.system(size: 21))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top], 16)
            
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                
                TextField("Логин", text: $login)
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
                
                SecureField("Пароль", text: $pass)
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
                
                TextField("IP-адрес", text: $ip)
                    .textContentType(.username)
                    .font(.system(size: 19))
                    .autocorrectionDisabled()
                    .onChange(of: ip) { newValue in
                        Settings.shared.address = newValue
                    }
            }
            .padding(.horizontal, 16)

            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "folder.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                
                TextField("Начальный каталог", text: $shareName)
                    .textContentType(.username)
                    .font(.system(size: 19))
                    .autocorrectionDisabled()
                    .onChange(of: shareName) { newValue in
                        Settings.shared.shareName = newValue
                    }
            }
            .padding(.horizontal, 16)
            
            Button {
                
            } label: {
                Text("Проверить подключение")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.main)
                    .padding(.horizontal, 16)
            }

            Spacer()
        }
        .background(.back)
        .onDisappear {
            DispatchQueue.global().async {
                Settings.shared.save()
            }
        }
    }
}

#Preview {
    SettingsView()
}
