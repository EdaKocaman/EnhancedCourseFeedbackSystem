import SwiftUI

struct FeedbackDetail: Decodable, Hashable {
    var course_quality: String
    var course_content: String
    var teaching_methodology: String
}

struct FeedbackDetailView: View {
    @State private var feedbackDetails: [FeedbackDetail] = []
    @State private var topic = ""
    @State private var selectedDate = Date()
    @State private var courseName = ""

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
                        Section() {
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
                    ScrollView {
                        VStack {
                            ForEach(feedbackDetails, id: \.self) { feedback in
                                VStack(alignment: .leading) {
                                    Text("Course Quality")
                                        .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                    Text(feedback.course_quality)
                                        .frame(height: 75)
                                        .frame(maxWidth: .infinity)
                                        .padding(.leading)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .padding(.bottom, 5)
                                    
                                    Text("Course Content")
                                        .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                    Text(feedback.course_content)
                                        .frame(height: 75)
                                        .frame(maxWidth: .infinity)
                                        .padding(.leading)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .padding(.bottom, 5)
                                    
                                    Text("Teaching Methodology")
                                        .foregroundColor(Color(red: 150/255, green: 150/255, blue: 150/255))
                                    Text(feedback.teaching_methodology)
                                        .frame(height: 75)
                                        .frame(maxWidth: .infinity)
                                        .padding(.leading)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .padding(.bottom, 5)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
                        }
                    }
                
            .onAppear(perform: fetchFeedbackDetails)
            .navigationBarTitle("", displayMode: .inline)
            .onAppear(perform: fetchFeedbackInfo)

        }
    }

    private func fetchFeedbackDetails() {
        guard let url = URL(string: "http://localhost:3000/api/stu_feedback") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
            }
            
            if let errorString = String(data: data, encoding: .utf8) {
                print("Error string: \(errorString)")
            }
            
            do {
                let feedbackDetails = try JSONDecoder().decode([FeedbackDetail].self, from: data)
                DispatchQueue.main.async {
                    self.feedbackDetails = feedbackDetails
                }
                print("Feedback information received successfully")
            } catch {
                print("Failed to decode feedback information: \(error)")
            }
        }.resume()
    }
    
    private func fetchFeedbackInfo() {
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

struct FeedbackDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackDetailView()
    }
}
