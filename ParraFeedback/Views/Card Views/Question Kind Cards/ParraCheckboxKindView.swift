//
//  ParraCheckboxKindView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/12/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

// "checkbox" means multiple selection from a variable number of options
internal class ParraCheckboxKindView: UIView, ParraQuestionKindView {
    typealias DataType = CheckboxQuestionBody
    typealias AnswerType = MultiOptionAnswer

    private let contentContainer = UIStackView(frame: .zero)
    private var optionViewMap = [ParraBorderedButton: CheckboxQuestionOption]()

    private let question: Question
    private let answerHandler: ParraAnswerHandler

    required init(
        question: Question,
        data: DataType,
        config: ParraCardViewConfig,
        answerHandler: ParraAnswerHandler
    ) {
        self.question = question
        self.answerHandler = answerHandler

        super.init(frame: .zero)

        contentContainer.axis = .vertical
        contentContainer.alignment = .fill
        contentContainer.spacing = 8.0
        contentContainer.distribution = .equalCentering
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentContainer)

        generateOptions(
            for: data,
            config: config,
            currentState: answerHandler.initialState(
                for: question
            )
        )

        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 8
            ),
            contentContainer.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -8
            ),
            contentContainer.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),
            contentContainer.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: 8
            ),
            contentContainer.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor,
                constant: -8
            )
        ])

        applyConfig(config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func applyConfig(_ config: ParraCardViewConfig) {
        for optionView in optionViewMap.keys {
            optionView.applyConfig(config)
        }
    }

    private func generateOptions(for data: DataType,
                                 config: ParraCardViewConfig,
                                 currentState: AnswerType?) {
        optionViewMap.removeAll()

        for option in data.options {
            let isSelected = (currentState?.options ?? []).contains(option.id)

            let button = ParraBorderedButton(
                title: option.title,
                optionId: option.id,
                isInitiallySelected: isSelected,
                config: config
            )
            button.delegate = self

            optionViewMap[button] = option
            contentContainer.addArrangedSubview(button)
        }
    }
}

extension ParraCheckboxKindView: ParraBorderedButtonDelegate, ViewTimer {
    func buttonShouldSelect(button: ParraBorderedButton,
                            optionId: String) -> Bool {
        return true
    }

    func buttonDidSelect(button: ParraBorderedButton,
                         optionId: String) {

        guard let option = optionViewMap[button], option.id == optionId else {
            return
        }

        answerHandler.update(
            answer: QuestionAnswer(
                kind: .radio,
                data: SingleOptionAnswer(optionId: option.id)
            ),
            for: question
        )

        selectionDidUpdate()
    }

    func buttonDidDeselect(button: ParraBorderedButton,
                           optionId: String) {
        answerHandler.update(answer: nil, for: question)

        selectionDidUpdate()
    }

    private func selectionDidUpdate() {
        performAfter(delay: 5.0) { [self] in
            answerHandler.commitAnswers(for: question)
        }
    }
}
