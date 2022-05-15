//
//  ParraFeedback.swift
//  Feedback
//
//  Created by Mick MacCallum on 3/12/22.
//

import Foundation
import ParraCore

/// <#Description#>
public class ParraFeedback: NSObject, ParraModule {
    internal static let shared = ParraFeedback()
    internal let dataManager = ParraFeedbackDataManager()
    
    private override init() {
        super.init()

        Parra.registerModule(module: self)
    }
    
    public static var name: String = "Feedback"
        
    /// <#Description#>
    /// - Parameter completion: <#completion description#>
    public class func fetchFeedbackCards(withCompletion completion: @escaping (Result<[CardItem], ParraError>) -> Void) {
        Task {
            do {
                let cards = try await fetchFeedbackCards()
                
                DispatchQueue.main.async {
                    completion(.success(cards))
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(ParraError.dataLoadingError(error.localizedDescription)))
                }
            }
        }
    }
    
    /// <#Description#>
    /// - Parameter completion: <#completion description#>
    public class func fetchFeedbackCards(withCompletion completion: @escaping ([CardItem], Error?) -> Void) {
        fetchFeedbackCards { result in
            switch result {
            case .success(let cards):
                completion(cards, nil)
            case .failure(let parraError):
                let error = NSError(
                    domain: ParraFeedback.errorDomain(),
                    code: 20,
                    userInfo: [
                        NSLocalizedDescriptionKey: parraError.localizedDescription
                    ]
                )
                
                completion([], error)
            }
        }
    }
    
    /// <#Description#>
    /// - Returns: <#description#>
    public class func fetchFeedbackCards() async throws -> [CardItem] {
        let cards = try await Parra.API.getCards()
        
        // Only keep cards that we don't already have an answer cached for. This isn't something that
        // should ever even happen, but in event that new cards are retreived that include cards we
        // already have an answer for, we'll keep the answered cards hidden and they'll be flushed
        // the next time a sync is triggered.
        var cardsToKeep = [CardItem]()

        for card in cards {
            switch card.data {
            case .question(let question):
                let previouslyCleared = await shared.dataManager.hasClearedCompletedCardWithId(card: card)
                let cardData = await shared.dataManager.completedCardData(forId: question.id)
            
                if !previouslyCleared && cardData == nil {
                    cardsToKeep.append(card)
                }
            }
        }
                
        shared.dataManager.setCards(cards: cardsToKeep)
        
        return cardsToKeep
    }
    
    /// Triggers an immediate sync of any stored ParraFeedback data with the Parra API. Instead of using this method, you should prefer to call `Parra.triggerSync()`
    /// on the ParraCore module, which can better handle enqueuing multiple sync requests. Sync calls will automatically happen when:
    /// 1. Calling `Parra.logout()`
    /// 2. The application transitions to or from the active state.
    /// 3. There is a significant time change on the system clock.
    /// 4. All cards for a `ParraFeedbackView` are completed.
    /// 5. A `ParraFeedbackView` is deinitialized or removed from the view hierarchy.
    ///
    public func triggerSync() async {
        await sendCardData()
    }
    
    /// <#Description#>
    /// - Parameter cardItem: <#cardItem description#>
    /// - Returns: <#description#>
    public class func hasCardBeenCompleted(_ cardItem: CardItem) async -> Bool {
        let completed = await shared.dataManager.completedCardData(forId: cardItem.id)
        
        return completed != nil
    }
    
    /// <#Description#>
    /// - Returns: <#description#>
    public func hasDataToSync() async -> Bool {
        let answers = await dataManager.currentCompletedCardData()
        
        return !answers.isEmpty
    }
    
    private func sendCardData() async {
        let completedCardData = await dataManager.currentCompletedCardData()
        let completedCards = Array(completedCardData.values)
        
        let completedChunks = completedCards.chunked(into: ParraFeedback.Constant.maxBulkAnswers)

        await withTaskGroup(of: Void.self) { group in
            for chunk in completedChunks {
                group.addTask {
                    do {
                        try await self.uploadCompletedCards(chunk)
                        try await self.dataManager.clearCompletedCardData(completedCards: chunk)
                        await self.dataManager.removeCardsForCompletedCards(completedCards: chunk)
                    } catch let error {
                        parraLogE("Error uploading card data: \(ParraError.networkError(error.localizedDescription))")
                    }
                }
            }
        }
    }

    private func uploadCompletedCards(_ cards: [CompletedCard]) async throws {
        try await Parra.API.bulkAnswerQuestions(cards: cards)
    }
}
