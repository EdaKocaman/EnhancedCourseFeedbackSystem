import SwiftUI

struct FeedbackRequestFormPage: View {
    @State private var selectedCourse: String = ""
    @State private var courseOptions: [String] = ["SENG306", "SENG326", "SENG352", "SENG384"]
    @State private var selectedDate: Date = Date()
    @State private var topic: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var isTeacherMenuOpen = false
    @State private var isLogoutActive = false // Logout state
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var studentEmail: String = ""
    @State private var studentEmails: [String] = []

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Request Form")
                        .font(.title2)
                        .padding(.top, 20)
                        .foregroundColor(.black)
                    
                    Form {
                        Section(header: Text("Course Name")) {
                            Picker("Select a course", selection: $selectedCourse) {
                                ForEach(courseOptions, id: \.self) { course in
                                    Text(course)
                                }
                            }
                        }
                        
                        Section(header: Text("Date")) {
                            DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                        }
                        
                        Section(header: Text("Topic")) {
                            VStack {
                                TextField("Enter topic...", text: $topic)
                                    .padding(.bottom, 150)
                                    .padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                        
                    }
                    .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                    .navigationBarItems(
                        leading: Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                        },
                        trailing: Button(action: {
                            self.isTeacherMenuOpen.toggle()
                        }) {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                    )
                    .popover(isPresented: $isTeacherMenuOpen) {
                        VStack {
                            Button(action: {
                                self.isTeacherMenuOpen = false
                            }) {
                                Text("Teacher Name: Eda Poyraz")
                                    .foregroundColor(.black)
                                    .padding()
                            }
                            Button(action: {
                                self.isTeacherMenuOpen = false
                                self.isLogoutActive = true
                            }) {
                                Text("Logout")
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                    }

                    Button(action: {
                        submitForm()
                    }) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Submission Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    
                    HStack {
                        NavigationLink(destination: FeedbackRequestFormPage()) {
                            Text("Request Form")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                       NavigationLink(destination: SummarizedList()) {
                            Text("Feedbacks")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                .background(
                    NavigationLink(destination: ContentView(), isActive: $isLogoutActive) {
                        EmptyView()
                    }
                )
            }
        }
    }

    func fetchStudentEmails() {
        guard let url = URL(string: "http://localhost:3000/api/students") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let emails = try JSONDecoder().decode([String].self, from: data)
                DispatchQueue.main.async {
                    self.studentEmails = emails
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func submitForm() {
        guard let url = URL(string: "http://localhost:3000/api/feedback_requests") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "topic": topic,
            "date": ISO8601DateFormatter().string(from: selectedDate),
            "courseName": selectedCourse
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                alertMessage = "No data received: \(error?.localizedDescription ?? "Unknown error")"
                showingAlert = true
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    print("Feedback request submitted successfully")
                    alertMessage = "Feedback request submitted successfully"
                    showingAlert = true
                } else {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Error submitting feedback request: \(responseString ?? "")")
                    alertMessage = "Error submitting feedback request: \(responseString ?? "")"
                    showingAlert = true
                }
            }
        }.resume()
    }
}
/*func fetchCourses() {
    guard let url = URL(string: "http://localhost:3000/api/courses") else {
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data else {
            print("No data received: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
        if let courses = try? JSONDecoder().decode([String].self, from: data) {
            DispatchQueue.main.async {
                self.courseOptions = courses
            }
            print("Courses fetched successfully")
        } else {
            print("Failed to fetch courses")
        }
    }.resume()
}*/

struct FeedbackRequestFormPage_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackRequestFormPage()
    }
}
