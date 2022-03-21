//
//  ParraFeedbackView+Transitions.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import UIKit
import ParraCore

extension ParraFeedbackView: ParraQuestionHandlerDelegate {
    func questionHandlerDidMakeNewSelection(forQuestion question: Question) {
        Task {
            try await Task.sleep(nanoseconds: 333_000_000)

            let (nextCardItem, nextCardItemDiection) = nextCardItem(inDirection: .right)
            
            guard let nextCardItem = nextCardItem, nextCardItemDiection == .right else {
                return
            }
            
            guard !(await ParraFeedback.hasCardBeenCompleted(nextCardItem)) else {
                return
            }
            
            // If there is a next card, we ask the delegate if we should transition.
            let shouldTransition = delegate?.parraFeedbackView?(self, shouldAutoNavigateTo: nextCardItem) ?? true
            
            if shouldTransition {
                suggestTransitionInDirection(.right, animated: true)
            }
        }
    }
}

extension ParraFeedbackView {
    func suggestTransitionInDirection(_ direction: Direction,
                                      animated: Bool) {

        guard canTransitionInDirection(direction) else {
            return
        }
        
        transitionToNextCard(
            direction: direction,
            animated: animated
        )
    }
    
    func transitionToNextCard(direction: Direction = .right,
                              animated: Bool = false) {

        let (nextCardItem, nextCardItemDiection) = nextCardItem(inDirection: direction)
        
        transitionToCardItem(nextCardItem,
                             direction: nextCardItemDiection,
                             animated: animated)
    }
    
    func nextCardItem(inDirection direction: Direction) -> (nextCardItem: CardItem?, nextCardItemDirection: Direction) {
        guard let currentCardInfo = currentCardInfo else {
            return (cardItems.first, direction)
        }
        
        if let currentIndex = cardItems.firstIndex(where: { $0 == currentCardInfo.cardItem }) {
            switch direction {
            case .left:
                if currentIndex == 0 {
                    return (cardItems.last, .left)
                } else {
                    return (cardItems[currentIndex - 1], .left)
                }
            case .right:
                if currentIndex == cardItems.count - 1 {
                    return (nil, .right)
                } else {
                    return (cardItems[currentIndex + 1], .right)
                }
            }
        } else {
            // You're all caught up for now condition
            switch direction {
            case .left:
                return (cardItems.last, .left)
            case .right:
                return (cardItems.first, .right)
            }
        }
    }
    
    func transitionToCardItem(_ cardItem: CardItem?,
                                      direction: Direction,
                                      animated: Bool = false) {
        
        let nextCard = cardViewFromCardItem(cardItem)
        let visibleButtons = visibleNavigationButtonsForCardItem(cardItem)
        
        contentView.addSubview(nextCard)
        
        NSLayoutConstraint.activate([
            nextCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nextCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nextCard.topAnchor.constraint(equalTo: contentView.topAnchor),
            nextCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        delegate?.parraFeedbackView?(self, willDisplay: cardItem)
        
        if animated {
            backButton.isEnabled = false
            forwardButton.isEnabled = false
            
            self.currentCardInfo?.cardView.transform = .identity
            nextCard.transform = .identity.translatedBy(
                x: direction == .right ? self.frame.width : -self.frame.width,
                y: 0.0
            )
            
            contentView.invalidateIntrinsicContentSize()
                        
            let oldCardInfo = currentCardInfo
            currentCardInfo = CurrentCardInfo(
                cardView: nextCard,
                cardItem: cardItem
            )
            if let oldCardInfo = oldCardInfo {
                delegate?.parraFeedbackView?(self, willEndDisplaying: oldCardInfo.cardItem)
            }

            UIView.animate(
                withDuration: 0.375,
                delay: 0.0,
                options: [.curveEaseInOut, .beginFromCurrentState]) {
                    oldCardInfo?.cardView.transform = .identity.translatedBy(
                        x: direction == .right ? -self.frame.width : self.frame.width,
                        y: 0.0
                    )
                    nextCard.transform = .identity
                    
                    self.updateVisibleNavigationButtons(visibleButtons: visibleButtons)
                } completion: { _ in
                    self.backButton.isEnabled = true
                    self.forwardButton.isEnabled = true
                    
                    if let oldCardInfo = oldCardInfo {
                        NSLayoutConstraint.deactivate(oldCardInfo.cardView.constraints)
                        oldCardInfo.cardView.removeFromSuperview()
                        
                        self.delegate?.parraFeedbackView?(self, didEndDisplaying: oldCardInfo.cardItem)
                    }
                    
                    self.delegate?.parraFeedbackView?(self, didDisplay: cardItem)
                }
        } else {
            updateVisibleNavigationButtons(visibleButtons: visibleButtons)

            if let currentCardInfo = self.currentCardInfo {
                delegate?.parraFeedbackView?(self, willEndDisplaying: currentCardInfo.cardItem)

                NSLayoutConstraint.deactivate(currentCardInfo.cardView.constraints)
                currentCardInfo.cardView.removeFromSuperview()
                self.currentCardInfo = nil
                
                delegate?.parraFeedbackView?(self, didEndDisplaying: currentCardInfo.cardItem)
            }
            
            self.currentCardInfo = CurrentCardInfo(
                cardView: nextCard,
                cardItem: cardItem
            )
            
            self.delegate?.parraFeedbackView?(self, didDisplay: cardItem)
        }
    }
    
    private func visibleNavigationButtonsForCardItem(_ cardItem: CardItem?) -> VisibleButtonOptions {
        guard let cardItem = cardItem else {
            return []
        }
        
        guard let index = cardItems.firstIndex(of: cardItem) else {
            return []
        }
        
        var visibleButtons: VisibleButtonOptions = []
        let hasPrevious = index > 0
        if hasPrevious {
            visibleButtons.update(with: .back)
        }
        let hasNext = index < cardItems.count - 1
        if hasNext {
            visibleButtons.update(with: .forward)
        }
        
        return visibleButtons
    }
    
    private func canTransitionInDirection(_ direction: Direction) -> Bool {
        guard let currentCardInfo = currentCardInfo else {
            return false
        }
        
        guard let currentIndex = cardItems.firstIndex(where: { $0 == currentCardInfo.cardItem }) else {
            return false
        }
        
        switch direction {
        case .left:
            return currentIndex > 0 && backButton.isEnabled
        case .right:
            return currentIndex < cardItems.count - 1 && forwardButton.isEnabled
        }
    }

    private func updateVisibleNavigationButtons(visibleButtons: VisibleButtonOptions) {
        let showBack = visibleButtons.contains(.back)
        
        backButton.alpha = showBack ? 1.0 : 0.0
        backButton.isEnabled = showBack
        
        let showForward = visibleButtons.contains(.forward)
        
        forwardButton.alpha = showForward ? 1.0 : 0.0
        forwardButton.isEnabled = showForward
    }
    
    private func cardViewFromCardItem(_ cardItem: CardItem?) -> ParraCardView {
        guard let cardItem = cardItem else {
            if let userProvidedEmptyState = delegate?.completeStateViewForParraFeedbackView?(self) {
                return ParraEmptyCardView(innerView: userProvidedEmptyState)
            } else {
                return ParraActionCardView(
                    title: "You're all caught up for now!",
                    subtitle: "a subtitle",
                    actionTitle: "Have other feedback?"
                ) {
                    parraLog("tapped cta")
                }
            }
        }
        
        let card: ParraCardView
        switch (cardItem.data) {
        case .question(let question):
            card = ParraQuestionCardView(
                question: question,
                questionHandler: questionHandler
            )
        }
                
        return card
    }
}
