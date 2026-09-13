//
//  InsightService.swift
//  apprenticeship project
//
//  Created by aakesh y on 4/20/26.
//

import Foundation

struct InsightService {
    let apiKey: String

    func generateInsight(snapshots: [MobilitySnapshot]) async throws -> String {

        let formatted = snapshots.enumerated().map { index, m in
            """
            Day \(index + 1):
            - Speed: \(m.walkingSpeed ?? 0) m/s
            - Step length: \(m.stepLength ?? 0) m
            - Steps: \(m.stepCount)
            - Double support time: \((m.doubleSupportPercent ?? 0) * 100)%
            - Gait asymmetry: \((m.asymmetryPercent ?? 0) * 100)%      
            - Steadiness: \(m.steadinessScore)
            """
        }.joined(separator: "\n\n")

//        let prompt = """
//        You are a health assistant.
//
//        Here is the user's walking data over the past 7 days:
//        \(formatted)
//
//        Interpret this data in terms of:
//        1. Overall mobility health
//        2. Possible fatigue or imbalance
//        3. One actionable suggestion
//
//
//        Give a short insight (2-3 sentences) about their mobility and one simple suggestion.
//        Be concise and natural.
//        """
//        let prompt = """
//        You are a health assistant analyzing gait and mobility data.
//        Your goal is to help identify early signs of walking difficulty, fatigue, or imbalance.
//
//        Here is the user's walking data over the past 7 days:
//        \(formatted)
//
//        Important context:
//        - Walking speed ~1.0–1.4 m/s is typical for healthy adults
//        - Lower step length or steadily decreasing values may indicate fatigue or mobility decline
//        - Lower steadiness score may indicate balance issues
//        - Look for trends over time, not single-day values
//
//        Your task:
//        1. Summarize overall mobility trend (improving, stable, or declining)
//        2. Identify any potential concern (fatigue, imbalance, reduced efficiency)
//        3. Give ONE specific, simple, actionable suggestion
//
//        Rules:
//        - Be concise (3–5 sentences max)
//        - Focus on trends, not individual days
//        - Do NOT over-diagnose; keep language cautious and non-medical
//        - Be clear and supportive, not alarmist
//
//        Output:
//        A short paragraph insight + one actionable suggestion.
//        """
 //       let prompt = """

//        You are a supportive health assistant analyzing 7 days of walking data from Apple HealthKit.
//
//        Here is the user's data:
//        \(formatted)
//
//        Reference ranges for healthy adults:
//        - Walking speed: 1.0–1.4 m/s
//        - Lower step length or steadily decreasing values may indicate fatigue or mobility decline
//        - Steadiness: higher is better
//        - Double support time: lower is generally better
//        - Gait asymmetry: closer to 0% is better
//
//        Analyze the trends across all 7 days (not individual days):
//        1. Describes the overall trend (improving, stable, or declining)
//        2. Notes any potential concern (fatigue, imbalance, reduced efficiency) if present
//        3. Ends with one specific, actionable suggestion
//
//        Tone: supportive, cautious, non-alarmist. Never diagnose. Use hedged language like "may suggest" or "could indicate." Write as if speaking directly to the user.
//        
//        Rules:
//        - Be concise (3–5 sentences max)
//        - Focus on trends, not individual days
//        - Do NOT over-diagnose; keep language cautious and non-medical
//        - Be clear and supportive, not alarmist
//        
//        Output:
//        A short paragraph insight + one actionable suggestion.
        
        let prompt = """
        You are a mobility coach analyzing 7 days of walking data from Apple HealthKit.

        \(formatted)

        Reference ranges: walking speed 1.0–1.4 m/s, lower asymmetry is better, higher steadiness is better.

        Write 2–3 sentences for a mobile health app card. Cover the overall trend and end with one short actionable tip. Use cautious, supportive language (e.g. "may suggest"). No headers, no bullets. Speak directly to the user.
        """


        let url = URL(string:
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)")!

        // return response.text

//        return """
//        Your walking metrics look stable overall.
//        Small variations in step length may indicate mild fatigue or normal daily variation.
//        Try maintaining consistent activity today.
//        """

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // gemini needs this format
//        {
//          "contents": [
//            {
//              "parts": [
//                { "text": "..." }
//              ]
//            }
//          ]
//        }
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        let candidates = json?["candidates"] as? [[String: Any]]
        let content = candidates?.first?["content"] as? [String: Any]
        let parts = content?["parts"] as? [[String: Any]]
        let text = parts?.first?["text"] as? String

        if let http = response as? HTTPURLResponse {
            print("STATUS:", http.statusCode)
        }

        print(String(data: data, encoding: .utf8) ?? "no data")

        return text ?? "No insight generated."
    }
}

//        print("""
//        Here is the user's walking data:
//        - Walking speed: \(mobility.walkingSpeed) m/s
//        - Step length: \(mobility.stepLength) m
//        - Double support time: \((mobility.doubleSupportPercent ?? 0) * 100)%
//        - Gait asymmetry: \((mobility.asymmetryPercent ?? 0) * 100)%
//        - Steadiness score: \(mobility.steadinessScore)
//        - Step count: \(mobility.stepCount)
//        """)


// private let model = SystemLanguageModel.default
//        let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY")
//
//        private let service = InsightService(apiKey:
//            Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
//        )

//    func generateInsight(mobility: MobilitySnapshot) async throws -> String {
//        print("""
//        Here is the user's walking data:
//        - Walking speed: \(mobility.walkingSpeed) m/s
//        - Step length: \(mobility.stepLength) m
//        - Double support time: \((mobility.doubleSupportPercent ?? 0) * 100)%
//        - Gait asymmetry: \((mobility.asymmetryPercent ?? 0) * 100)%
//        - Steadiness score: \(mobility.steadinessScore)
//        - Step count: \(mobility.stepCount)
//        """)
//
//        let prompt = """
//        You are a health assistant.
//
//        Here is the user's walking data:
//        - Walking speed: \(mobility.walkingSpeed) m/s
//        - Step length: \(mobility.stepLength) m
//        - Double support time: \((mobility.doubleSupportPercent ?? 0) * 100)%
//        - Gait asymmetry: \((mobility.asymmetryPercent ?? 0) * 100)%
//        - Steadiness score: \(mobility.steadinessScore)
//        - Step count: \(mobility.stepCount)
//
//        Interpret this data in terms of:
//        1. Overall mobility health
//        2. Possible fatigue or imbalance
//        3. One actionable suggestion
//
//
//        Give a short insight (2-3 sentences) about their mobility and one simple suggestion.
//        Be concise and natural.
//        """
//
//        let url = URL(string:
//            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)")!
//
//        // return response.text
//
    ////        return """
    ////        Your walking metrics look stable overall.
    ////        Small variations in step length may indicate mild fatigue or normal daily variation.
    ////        Try maintaining consistent activity today.
    ////        """
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // gemini needs this format
    ////        {
    ////          "contents": [
    ////            {
    ////              "parts": [
    ////                { "text": "..." }
    ////              ]
    ////            }
    ////          ]
    ////        }
//        let body: [String: Any] = [
//            "contents": [
//                [
//                    "parts": [
//                        ["text": prompt]
//                    ]
//                ]
//            ]
//        ]
//
//        request.httpBody = try JSONSerialization.data(withJSONObject: body)
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//
//        let candidates = json?["candidates"] as? [[String: Any]]
//        let content = candidates?.first?["content"] as? [String: Any]
//        let parts = content?["parts"] as? [[String: Any]]
//        let text = parts?.first?["text"] as? String
//
//        if let http = response as? HTTPURLResponse {
//            print("STATUS:", http.statusCode)
//        }
//
//        print(String(data: data, encoding: .utf8) ?? "no data")
//
//        return text ?? "No insight generated."
//    }
