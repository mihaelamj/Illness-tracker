import Foundation

class CSVParser {
    func parseCSV(_ csvString: String, completion: @escaping ([HealthRecord]) -> Void) {
        var records: [HealthRecord] = []
        
        // Split into lines
        let lines = csvString.components(separatedBy: .newlines)
        
        // Skip the header
        let dataLines = lines.dropFirst()
        
        for line in dataLines {
            if line.isEmpty { continue }
            
            // Split by commas, handling quoted fields
            var fields: [String] = []
            var currentField = ""
            var insideQuotes = false
            
            for char in line {
                if char == "\"" {
                    insideQuotes.toggle()
                } else if char == "," && !insideQuotes {
                    fields.append(currentField)
                    currentField = ""
                } else {
                    currentField.append(char)
                }
            }
            
            // Add the last field
            fields.append(currentField)
            
            // Need at least date and time
            guard fields.count >= 2 else { continue }
            
            let dateString = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let timeString = fields[1].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy. HH:mm"
            
            let combinedDateString = "\(dateString) \(timeString)"
            let timestamp = dateFormatter.date(from: combinedDateString) ?? Date()
            
            // Create record
            var record = HealthRecord(
                illnessID: UUID(),  // This needs to be set later
                timestamp: timestamp,
                sampleDate: dateString,
                sampleTime: timeString
            )
            
            // Temperature (index 2)
            if fields.count > 2 && !fields[2].isEmpty {
                let tempString = fields[2].trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: ",", with: ".")
                record.temperature = Double(tempString)
            }
            
            // Treatment (index 3)
            if fields.count > 3 && !fields[3].isEmpty {
                record.treatment = fields[3].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            // Symptoms (index 4)
            if fields.count > 4 && !fields[4].isEmpty {
                record.symptoms = fields[4].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            records.append(record)
        }
        
        completion(records)
    }
}
