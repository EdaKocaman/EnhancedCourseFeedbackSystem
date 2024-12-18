//
//  RegistrationView.swift
//  ECFSTest
//
//  Created by Eda Kocaman on 25.05.2024.
//

import SwiftUI

struct RegistrationView: View {
    @ObservedObject var userViewModel = UserViewModel()
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            TextField("Name", text: $name)
            Button("Register") {
                userViewModel.registerUser(username: username, email: email, password: password, name: name)
            }
        }
    }
}
