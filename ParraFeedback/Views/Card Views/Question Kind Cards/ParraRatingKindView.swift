//
//  ParraRatingKindView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/12/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

internal class ParraRatingKindView: UIView, ParraQuestionKindView {
    typealias DataType = RatingQuestionBody
    typealias AnswerType = SingleOptionAnswer

    private let answerHandler: ParraAnswerHandler

    required init(
        question: Question,
        data: DataType,
        config: ParraCardViewConfig,
        answerHandler: ParraAnswerHandler
    ) {
        self.answerHandler = answerHandler

        super.init(frame: .zero)

        backgroundColor = .orange
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func applyConfig(_ config: ParraCardViewConfig) {

    }
}

