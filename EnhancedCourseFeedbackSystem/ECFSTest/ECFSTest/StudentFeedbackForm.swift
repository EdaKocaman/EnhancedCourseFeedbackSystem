import SwiftUI

struct StudentFeedbackForm: View {
    @State private var topic: String = ""
    @State private var selectedDate = Date()
    @State private var courseName: String = ""
    @State private var courseQualityFeedback: String = ""
    @State private var courseContentFeedback: String = ""
    @State private var teachingMethodologyFeedback: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Student Feedback Form")
                        .font(.title2)
                        .padding(.top, 20)
                        .foregroundColor(.black)
                    
                    Form {
                        Section(header: Text("Feedback Information")) {
                            HStack {
                                Text("Topic:")
                                    .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                Spacer()
                                Text(topic)
                                    .foregroundColor(.black)
                            }
                            HStack {
                                Text("Date:")
                                    .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                Spacer()
                                Text("\(selectedDate, formatter: dateFormatter)")
                                    .foregroundColor(.black)
                            }
                            HStack {
                                Text("Course Name:")
                                    .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                Spacer()
                                Text(courseName)
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Section(header: Text("Feedback")) {
                            VStack {
                                HStack {
                                    Text("Course Quality")
                                        .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                    Spacer()
                                }
                                TextField("Enter Comment...", text: $courseQualityFeedback)
                                    .frame(height: 75)
                                    .padding(.leading)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            .padding(.vertical, 5)
                            
                            VStack {
                                HStack {
                                    Text("Course Content")
                                        .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                    Spacer()
                                }
                                TextField("Enter Comment...", text: $courseContentFeedback)
                                    .frame(height: 75)
                                    .padding(.leading)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .cornerRadius(8)
                            }
                            .padding(.vertical, 5)
                            
                            VStack {
                                HStack {
                                    Text("Teaching Methodology")
                                        .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                    Spacer()
                                }
                                TextField("Enter Comment...", text: $teachingMethodologyFeedback)
                                    .frame(height: 75)
                                    .padding(.leading)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            .padding(.vertical, 5)
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
                }
                .padding(.horizontal)
                .onAppear(perform: fetchFeedbackInfo)
            }
        }
    }
    
    func fetchFeedbackInfo() {
            guard let url = URL(string: "http://localhost:3000/api/feedback_info") else {
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                if let feedbackInfo = try? JSONDecoder().decode(FeedbackInfo.self, from: data) {
                    DispatchQueue.main.async {
                        self.topic = feedbackInfo.topic
                        if let request_date = dateFormatter.date(from: feedbackInfo.request_date) {
                            self.selectedDate = request_date
                        }
                        self.courseName = feedbackInfo.course_name
                    }
                    print("Feedback information received successfully")
                } else {
                    print("Failed to decode feedback information")
                }
            }.resume()
        }
    
    func submitForm() {
        guard let url = URL(string: "http://localhost:3000/api/student_feedbacks") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "courseQualityFeedback": courseQualityFeedback,
            "courseContentFeedback": courseContentFeedback,
            "teachingMethodologyFeedback": teachingMethodologyFeedback
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
            
            // HTTP response'nu kontrol et
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    print("Feedback submitted successfully")
                    alertMessage = "Feedback submitted successfully"
                    showingAlert = true
                } else {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Error submitting feedback: \(responseString ?? "")")
                    alertMessage = "Error submitting feedback: \(responseString ?? "")"
                    showingAlert = true
                }
            }
        }.resume()

    }
}

struct FeedbackInfo: Decodable {
    let topic: String
    let request_date: String
    let course_name: String
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

struct StudentFeedbackForm_Previews: PreviewProvider {
    static var previews: some View {
        StudentFeedbackForm()
    }
}
