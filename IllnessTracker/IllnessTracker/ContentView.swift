//
//  ContentView.swift
//  IllnessTracker
//
//  Created by Mihaela MJ on 26.02.2025..
//

import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
//    @EnvironmentObject var illnessViewModel: IllnessViewModel
    // Create a single instance of the view model to share throughout the app
    @StateObject private var illnessViewModel = IllnessViewModel(service: MockIllnessService())
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            PatientListView(navigationPath: $navigationPath, illnessViewModel: illnessViewModel)
                .navigationDestination(for: String.self) { patientName in
                    IllnessListView(patientName: patientName, navigationPath: $navigationPath)
                }
                .navigationDestination(for: Illness.self) { illness in
                    IllnessDetailView(illness: illness, navigationPath: $navigationPath)
                }
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .addIllness(let patientName):
                        AddIllnessView(patientName: patientName, navigationPath: $navigationPath)
                    case .addRecord(let illness):
                        AddHealthRecordView(illness: illness, navigationPath: $navigationPath)
                    case .viewAttachments(let illness):
                        AttachmentListView(illness: illness)
                    case .importData(let illness):
                        DataImportView(illness: illness)
                    }
                }
                .navigationTitle("Health Tracker")
        }
    }
}

// Navigation destinations
enum NavigationDestination: Hashable {
    case addIllness(patientName: String)
    case addRecord(illness: Illness)
    case viewAttachments(illness: Illness)
    case importData(illness: Illness)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .addIllness(let patientName):
            hasher.combine(0)
            hasher.combine(patientName)
        case .addRecord(let illness):
            hasher.combine(1)
            hasher.combine(illness.id)
        case .viewAttachments(let illness):
            hasher.combine(2)
            hasher.combine(illness.id)
        case .importData(let illness):
            hasher.combine(3)
            hasher.combine(illness.id)
        }
    }
    
    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.addIllness(let lhsName), .addIllness(let rhsName)):
            return lhsName == rhsName
        case (.addRecord(let lhsIllness), .addRecord(let rhsIllness)):
            return lhsIllness.id == rhsIllness.id
        case (.viewAttachments(let lhsIllness), .viewAttachments(let rhsIllness)):
            return lhsIllness.id == rhsIllness.id
        case (.importData(let lhsIllness), .importData(let rhsIllness)):
            return lhsIllness.id == rhsIllness.id
        default:
            return false
        }
    }
}

#Preview {
    ContentView()
}
