//
//  UserViewModel.swift
//  ECFSTest
//
//  Created by Eda Kocaman on 25.05.2024.
//

import Foundation

class UserViewModel: ObservableObject {
    func registerUser(username: String, email: String, password: String, name: String) {
        guard let url = URL(string: "http://localhost:3000/api/register") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "name": name
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 201 {
                print("User registered successfully")
            } else {
                print("Failed to register user")
            }
        }.resume()
    }
}
