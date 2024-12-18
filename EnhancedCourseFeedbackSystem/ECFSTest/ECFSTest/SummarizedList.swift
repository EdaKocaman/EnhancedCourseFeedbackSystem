import SwiftUI

struct SummarizedList: View {
    @State private var selectedCourse: String = ""
    @State private var courseOptions: [String] = []
    @State private var selectedDate: Date = Date()
    @State private var isTeacherMenuOpen = false
    @State private var isLogoutActive = false
    @Environment(\.presentationMode) var presentationMode
    @State private var topic: String = ""
    @State private var courseName: String = ""
    @State private var showDetailedFeedback = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Summarized Feedback List")
                        .font(.title2)
                        .padding(.top, 20)
                        .foregroundColor(.black)
                    
                    HStack {
                        Picker("Select a course", selection: $selectedCourse) {
                            Text("All Courses").tag("")
                            ForEach(courseOptions, id: \.self) { course in
                                Text(course).tag(course)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.leading, 10)
                        
                        DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                            .labelsHidden()
                            .padding(.trailing, 10)
                    }
                    .padding()
                    
                    Form {
                        Section(header: Text("Summary1")) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Topic:")
                                        .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                    Text(topic)
                                        .foregroundColor(.black)
                                }
                                HStack {
                                    Text("Date:")
                                        .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                    Text("\(selectedDate, formatter: dateFormatter)")
                                        .foregroundColor(.black)
                                }
                                HStack {
                                    Text("Course Name:")
                                        .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                    Text(courseName)
                                        .foregroundColor(.black)
                                }
                            }
                            Button(action: {
                                // Show detailed feedback
                                showDetailedFeedback = true
                            }) {
                                Text("Details")
                                NavigationLink(
                                    destination: FeedbackDetailView(),
                                    isActive: $showDetailedFeedback){
                                    }
                            }
                        }}
                    
                    HStack {
                        NavigationLink(destination: FeedbackRequestFormView()) {
                            Text("Request Form")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        NavigationLink(destination: SummarizedList()) {
                            Text("Feedbacks")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
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
                            Text("Teacher Name: Eda Kocaman")
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
                .alert(isPresented: $isLogoutActive) {
                    Alert(title: Text("Logout"), message: Text("Are you sure you want to log out?"), primaryButton: .default(Text("Yes")) {
                        presentationMode.wrappedValue.dismiss()
                    }, secondaryButton: .cancel(Text("No")))
                }
            }
        }
        .onAppear(perform: fetchFeedbackInfo)
        .onAppear(perform: fetchCourses)
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
                    if let requestDate = dateFormatter.date(from: feedbackInfo.request_date) {
                        self.selectedDate = requestDate
                    }
                    self.courseName = feedbackInfo.course_name
                }
                print("Feedback information received successfully")
            } else {
                print("Failed to decode feedback information")
            }
        }.resume()
    }
    
    func fetchCourses() {
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
}

struct FeedbackRequestFormView: View {
    var body: some View {
        Text("Feedback Request Form Page")
    }
}

struct SummarizedList_Previews: PreviewProvider {
    static var previews: some View {
        SummarizedList()
    }
}

