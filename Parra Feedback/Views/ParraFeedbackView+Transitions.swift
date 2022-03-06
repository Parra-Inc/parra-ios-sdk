//
//  ParraFeedbackView+Transitions.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/2/22.
//

import UIKit

extension ParraFeedbackView {
    func transitionToNextCard(direction: Direction = .right, animated: Bool = false) {
        guard let currentCardInfo = currentCardInfo else {
            transitionToCardItem(cardItems.first, direction: direction, animated: animated)
            
            return
        }
        
        if let currentIndex = cardItems.firstIndex(where: { $0 == currentCardInfo.cardItem }) {
            switch direction {
            case .left:
                if currentIndex == 0 {
                    transitionToCardItem(cardItems.last, direction: .left, animated: animated)
                } else {
                    transitionToCardItem(cardItems[currentIndex - 1], direction: .left, animated: animated)
                }
            case .right:
                if currentIndex == cardItems.count - 1 {
                    transitionToCardItem(nil, direction: .right, animated: animated)
                } else {
                    transitionToCardItem(cardItems[currentIndex + 1], direction: .right, animated: animated)
                }
            }
        } else {
            // You're all caught up for now condition
            switch direction {
            case .left:
                transitionToCardItem(cardItems.last, direction: .left, animated: animated)
            case .right:
                transitionToCardItem(cardItems.first, direction: .right, animated: animated)
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
        
        let applyNextView = {
            if let currentCardInfo = self.currentCardInfo {
                NSLayoutConstraint.deactivate(currentCardInfo.cardView.constraints)
                currentCardInfo.cardView.removeFromSuperview()
                self.currentCardInfo = nil
            }
            
            self.currentCardInfo = CurrentCardInfo(
                cardView: nextCard,
                cardItem: cardItem
            )
        }
        
        if animated {
            backButton.isEnabled = false
            forwardButton.isEnabled = false
            
            self.currentCardInfo?.cardView.transform = .identity
            nextCard.transform = .identity.translatedBy(
                x: direction == .right ? self.frame.width : -self.frame.width,
                y: 0.0
            )
            
            contentView.invalidateIntrinsicContentSize()
            
            UIView.animate(
                withDuration: 0.375,
                delay: 0.0,
                options: [.curveEaseInOut]) {
                    self.currentCardInfo?.cardView.transform = .identity.translatedBy(
                        x: direction == .right ? -self.frame.width : self.frame.width,
                        y: 0.0
                    )
                    nextCard.transform = .identity
                    
                    self.updateVisibleNavigationButtons(visibleButtons: visibleButtons)
                } completion: { _ in
                    applyNextView()
                    
                    self.backButton.isEnabled = true
                    self.forwardButton.isEnabled = true
                }
        } else {
            updateVisibleNavigationButtons(visibleButtons: visibleButtons)
            
            applyNextView()
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

    private func updateVisibleNavigationButtons(visibleButtons: VisibleButtonOptions) {
        let showBack = visibleButtons.contains(.back)
        
        backButton.alpha = showBack ? 1.0 : 0.0
        backButton.isEnabled = showBack
        
        let showForward = visibleButtons.contains(.forward)
        
        forwardButton.alpha = showForward ? 1.0 : 0.0
        forwardButton.isEnabled = showForward
    }
    
    func cardViewFromCardItem(_ cardItem: CardItem?) -> ParraCardView {
        guard let cardItem = cardItem else {
            return ParraActionCardView(
                title: "You're all caught up for now!",
                subtitle: "a subtitle",
                actionTitle: "Have other feedback?"
            ) {
                parraLog("tapped cta")
            }
        }
        
        switch (cardItem.data) {
        case .question(let question):
            return ParraQuestionCardView(
                question: question,
                questionHandler: questionHandler
            )
        }
    }
}
