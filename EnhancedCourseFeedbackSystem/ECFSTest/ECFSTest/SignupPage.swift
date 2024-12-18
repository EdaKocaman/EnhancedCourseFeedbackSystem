import SwiftUI

struct SignupPage: View {
    @StateObject private var userViewModel = UserViewModel()
    @State private var username: String = ""
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var signupSuccess: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    
                    Text("Enhanced Course Feedback System")
                        .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                        .font(.largeTitle)
                        .padding(.bottom, 20)
                        .multilineTextAlignment(.center)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10.0)
                        .padding(.bottom, 10)
                    
                    TextField("Name Surname", text: $name)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10.0)
                        .padding(.bottom, 10)
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10.0)
                        .padding(.bottom, 10)
                    
                    ZStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 16)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10.0)
                    .padding(.bottom, 10)
                    
                    ZStack {
                        if isConfirmPasswordVisible {
                            TextField("Confirm Password", text: $confirmPassword)
                        } else {
                            SecureField("Confirm Password", text: $confirmPassword)
                        }
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                isConfirmPasswordVisible.toggle()
                            }) {
                                Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 16)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10.0)
                    .padding(.bottom, 20)
                    
                    Button(action: {
                        signupUser()
                    }) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(Color.blue)
                            .cornerRadius(15.0)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Sign Up"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    
                    NavigationLink(destination: ContentView(), isActive: $signupSuccess) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    func signupUser() {
        if username.isEmpty || name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            alertMessage = "Please fill in all fields."
            showingAlert = true
        } else if password != confirmPassword {
            alertMessage = "Passwords do not match."
            showingAlert = true
        } else if !isValidEmail(email) {
            alertMessage = "Invalid email address."
            showingAlert = true
        } else {
            userViewModel.registerUser(username: username, email: email, password: password, name: name)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,64})"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct SignupPage_Previews: PreviewProvider {
    static var previews: some View {
        SignupPage()
    }
}
