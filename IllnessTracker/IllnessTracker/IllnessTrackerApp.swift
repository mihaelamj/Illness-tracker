//
//  IllnessTrackerApp.swift
//  IllnessTracker
//
//  Created by Mihaela MJ on 26.02.2025..
//

import SwiftUI

@main
struct IllnessTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


/**
 
 */

/**
 ```
 Here's a list of files you need to download for the complete health tracking app:
 Core Files:

 Models:
     Illness.swift - The illness tracking model
     HealthRecord.swift - The health record model
     Attachment.swift - The attachment model


 Services:
     IllnessService.swift - Protocol and implementation for illness management
     HealthRecordService.swift - Protocol and implementation for health records
     AttachmentService.swift - Protocol and implementation for attachments
     DataImporter.swift - Utility for importing data from files


 ViewModels:
     IllnessViewModel.swift - ViewModel for illness management
     HealthViewModel.swift - ViewModel for health records
     AttachmentViewModel.swift - ViewModel for attachments


 Views:
     ContentView.swift - Main navigation coordinator
     PatientListView.swift - List of patients
     IllnessListView.swift - List of illnesses for a patient
     IllnessDetailView.swift - Details of an illness with records
     AddIllnessView.swift - Form to add a new illness
     AddHealthRecordView.swift - Form to add a new health record
     AttachmentListView.swift - List of attachments
     TemperatureChartView.swift - Chart for visualizing temperature data
     DataImportView.swift - View for importing data
 
     Components/ - Folder for reusable UI components
         HealthRecordRow.swift - Record row component
         ChartView.swift - Chart implementation
         DocumentPicker.swift - Document picker component
         NoteEntryView.swift - Note entry component

 Utilities:
    CSVParser.swift - Utility for parsing CSV data



 Test Files:

 Unit Tests:

 IllnessTests.swift - Tests for the Illness model
 HealthRecordTests.swift - Tests for the HealthRecord model
 IllnessViewModelTests.swift - Tests for the IllnessViewModel
 HealthViewModelTests.swift - Tests for the HealthViewModel
 CSVImportTests.swift - Tests for CSV data import
 TestData.swift - Sample data for tests


 UI Tests:

 HealthTrackerUITests.swift - UI tests for the app


 Mock Services:

 MockIllnessService.swift - Mock service for illness testing
 MockHealthRecordService.swift - Mock service for health record testing
 MockAttachmentService.swift - Mock service for attachment testing



 Project Files:

 Configuration:

 Xcode project with CloudKit capabilities enabled
 Info.plist with necessary permissions
 Entitlements file for CloudKit



 Currently, I've provided the code in larger chunks that you would need to split into these individual files. Since you'll be using Xcode, you can create a new SwiftUI project and then manually copy the relevant portions of code into each file.
 ```
 */
