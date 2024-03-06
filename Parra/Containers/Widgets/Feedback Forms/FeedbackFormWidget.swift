//
//  FeedbackFormWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct FeedbackFormWidget: Container {
    // MARK: - Lifecycle

    init(
        config: FeedbackFormWidgetConfig,
        style: FeedbackFormWidgetStyle,
        componentFactory: ComponentFactory<FeedbackFormWidgetFactory>,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.style = style
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Public

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    fieldViews
                }
            }
            .contentMargins(
                .all,
                style.contentPadding,
                for: .scrollContent
            )
            .scrollDismissesKeyboard(.interactively)

            WidgetFooter(
                primaryActionBuilder: {
                    componentFactory.buildTextButton(
                        variant: .contained,
                        component: \.submitButton,
                        config: config.submitButton,
                        content: contentObserver.content.submitButton,
                        localAttributes: nil
                    )
                    .disabled(!contentObserver.content.canSubmit)
                },
                secondaryActionBuilder: nil,
                contentPadding: style.contentPadding
            )
        }
        .applyBackground(style.background)
        .padding(style.padding)
        .environmentObject(contentObserver)
        .environmentObject(componentFactory)
    }

    // MARK: - Internal

    let componentFactory: ComponentFactory<FeedbackFormWidgetFactory>
    @StateObject var contentObserver: ContentObserver
    let config: FeedbackFormWidgetConfig
    let style: FeedbackFormWidgetStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            componentFactory.buildLabel(
                component: \.title,
                config: config.title,
                content: contentObserver.content.title,
                localAttributes: nil
            )

            componentFactory.buildLabel(
                component: \.description,
                config: config.description,
                content: contentObserver.content.description,
                localAttributes: nil
            )
        }
    }

    var fieldViews: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(contentObserver.content.fields) { fieldWithState in
                let field = fieldWithState.field

                switch field.data {
                case .feedbackFormSelectFieldData(let data):
                    let content = MenuContent(
                        title: field.title,
                        placeholder: data.placeholder,
                        helper: field.helperText,
                        options: data.options.map { fieldOption in
                            MenuContent.Option(
                                id: fieldOption.id,
                                title: fieldOption.title,
                                value: fieldOption.id
                            )
                        }
                    ) { option in
                        onFieldValueChanged(
                            field: field,
                            value: option?.value
                        )
                    }

                    componentFactory.buildMenu(
                        component: \.selectFields,
                        config: config.selectFields.withFormTextFieldData(data),
                        // no customization currently exists
                        content: content,
                        localAttributes: nil
                    )
                case .feedbackFormTextFieldData(let data):
                    let content = TextEditorContent(
                        title: field.title,
                        placeholder: data.placeholder,
                        helper: field.helperText,
                        errorMessage: fieldWithState.state.errorMessage
                    ) { newText in
                        onFieldValueChanged(
                            field: field,
                            value: newText
                        )
                    }

                    componentFactory.buildTextEditor(
                        component: \.textFields,
                        config: config.textFields.withFormTextFieldData(data),
                        content: content,
                        localAttributes: nil
                    )
                case .feedbackFormInputFieldData(let data):
                    let content = TextInputContent(
                        title: field.title,
                        placeholder: data.placeholder,
                        helper: field.helperText,
                        errorMessage: fieldWithState.state.errorMessage
                    ) { newText in
                        onFieldValueChanged(
                            field: field,
                            value: newText
                        )
                    }

                    componentFactory.buildTextInput(
                        component: \.inputFields,
                        config: config.inputFields.withFormTextFieldData(data),
                        content: content,
                        localAttributes: nil
                    )
                }
            }
        }
    }

    // MARK: - Private

    private func onFieldValueChanged(
        field: FeedbackFormField,
        value: String?
    ) {
        contentObserver.onFieldValueChanged(
            field: field,
            value: value
        )
    }
}

#Preview {
    ParraContainerPreview { _, componentFactory in
        FeedbackFormWidget(
            config: .default,
            style: .default(with: .default),
            componentFactory: componentFactory,
            contentObserver: .init(
                initialParams: .init(
                    formData: .init(
                        title: "Leave feedback",
                        description: "We'd love to hear from you. Your input helps us make our product better.",
                        fields: FeedbackFormField.validStates()
                    )
                )
            )
        )
    }
}
