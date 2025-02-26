import Foundation
import SwiftUI
import Combine

// ViewModel for illness management
class IllnessViewModel: ObservableObject {
    @Published var illnesses: [Illness] = []
    @Published var selectedIllness: Illness?
    @Published var newIllness = Illness(patientName: "", startDate: Date())
    @Published var isLoading: Bool = false
    @Published var isSyncing: Bool = false
    
    private let service: IllnessService
    
    init(service: IllnessService) {
        self.service = service
        loadIllnesses()
    }
    
    func loadIllnesses() {
        isLoading = true
        service.loadIllnesses { [weak self] loadedIllnesses in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.illnesses = loadedIllnesses
                self.isLoading = false
            }
        }
    }
    
    func addIllness() {
        guard !newIllness.patientName.isEmpty else { return }
        
        service.saveIllness(newIllness) { [weak self] savedIllness in
            guard let self = self, let illness = savedIllness else { return }
            DispatchQueue.main.async {
                self.newIllness = Illness(patientName: "", startDate: Date())
                self.loadIllnesses()
                self.selectedIllness = illness
            }
        }
    }
    
    func updateIllness(_ illness: Illness) {
        service.saveIllness(illness) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadIllnesses()
            }
        }
    }
    
    func deleteIllness(_ illness: Illness) {
        service.deleteIllness(illness) { [weak self] success in
            guard let self = self, success else { return }
            DispatchQueue.main.async {
                if self.selectedIllness?.id == illness.id {
                    self.selectedIllness = nil
                }
                self.loadIllnesses()
            }
        }
    }
    
    func syncIllnesses() {
        isSyncing = true
        service.syncIllnesses { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadIllnesses()
                self.isSyncing = false
            }
        }
    }
}
