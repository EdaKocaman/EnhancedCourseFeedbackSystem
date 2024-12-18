//
//  ContentView.swift
//  ECFSTest
//
//  Created by Eda Kocaman on 18.05.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var showingSignupPage: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding(.top, -50)
                    .padding()
                
                Text("Enhanced Course Feedback System")
                    .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                    .font(.largeTitle)
                    .padding(.bottom, 20)
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10.0)
                    .padding(.bottom, 10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10.0)
                    .padding(.bottom, 20)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Button(action: {
                    showingSignupPage = true
                }) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.green)
                        .cornerRadius(15.0)
                }
                .sheet(isPresented: $showingSignupPage) {
                    SignupPage()
                }
                
                NavigationLink(destination: FeedbackRequestFormPage(), isActive: $isLoggedIn) {
                    EmptyView()
                }
                .hidden() // Do not show the navigation link directly
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    func login() {
        guard !username.isEmpty, !password.isEmpty else {
            alertMessage = "Please enter both username and password."
            showingAlert = true
            return
        }
        
        guard let url = URL(string: "http://localhost:3000/api/login") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("Login successful")
                    isLoggedIn = true // Set isLoggedIn to true if login is successful
                } else {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Login failed: \(responseString ?? "")")
                    alertMessage = "Login failed: \(responseString ?? "")"
                    showingAlert = true
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
 
