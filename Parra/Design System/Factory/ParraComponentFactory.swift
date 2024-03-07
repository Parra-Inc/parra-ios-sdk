//
//  ParraComponentFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ComponentBuilder {
    // I don't know why, but these generic typealiases have to be nested within
    // a type. If they're top level, any callsite reports not finding them on
    // the Parra module.
    public typealias Factory<
        V: View,
        Config,
        Content,
        Attributes
    > = (
        _ config: Config,
        _ content: Content?,
        _ defaultAttributes: ParraStyleAttributes
    ) -> V?
}

protocol ParraComponentFactory {}

class ComponentFactory<Factory: ParraComponentFactory>: ObservableObject {
    // MARK: - Lifecycle

    init(
        local: Factory?,
        global: GlobalComponentAttributes?,
        theme: ParraTheme
    ) {
        self.local = local
        self.global = global
        self.theme = theme
    }

    // MARK: - Internal

    let local: Factory?
    let global: GlobalComponentAttributes?
    let theme: ParraTheme

    @ViewBuilder
    func buildLabel(
        config: LabelConfig,
        content: LabelContent,
        suppliedFactory: ComponentBuilder.Factory<
            Text,
            LabelConfig,
            LabelContent,
            LabelAttributes
        >? = nil,
        localAttributes: LabelAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?.labelAttributeFactory {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        let mergedAttributes = LabelComponent.applyStandardCustomizations(
            onto: attributes,
            theme: theme,
            config: config
        )

        // If a container level factory function was provided for this
        // component, use it and supply global attribute overrides instead
        // of local, if provided.
        if let builder = suppliedFactory,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedLabelStyle(
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            LabelComponent(
                content: content,
                style: style
            )
        }
    }

    @ViewBuilder
    func buildTextButton(
        variant: ButtonVariant,
        config: TextButtonConfig,
        content: TextButtonContent,
        suppliedFactory: ComponentBuilder.Factory<
            Button<Text>,
            TextButtonConfig,
            TextButtonContent,
            TextButtonAttributes
        >? = nil,
        localAttributes: TextButtonAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?
            .textButtonAttributeFactory
        {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        // Dynamically get default attributes for different button types.
        let mergedAttributes = switch variant {
        case .plain:
            PlainButtonComponent.applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config,
                for: PlainButtonComponent.self
            )
        case .outlined:
            OutlinedButtonComponent.applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config,
                for: OutlinedButtonComponent.self
            )
        case .contained:
            ContainedButtonComponent.applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config,
                for: ContainedButtonComponent.self
            )
        }

        // If a container level factory function was provided for this
        // component, use it and supply global attribute overrides instead
        // of local, if provided.
        if let builder = suppliedFactory,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedTextButtonStyle(
                config: config,
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            switch variant {
            case .plain:
                PlainButtonComponent(
                    config: config,
                    content: content,
                    style: style
                )
            case .outlined:
                OutlinedButtonComponent(
                    config: config,
                    content: content,
                    style: style
                )
            case .contained:
                ContainedButtonComponent(
                    config: config,
                    content: content,
                    style: style
                )
            }
        }
    }

    @ViewBuilder
    func buildImageButton(
        variant: ButtonVariant,
        config: ImageButtonConfig,
        content: ImageButtonContent,
        suppliedFactory: ComponentBuilder.Factory<
            Button<Image>,
            ImageButtonConfig,
            ImageButtonContent,
            ImageButtonAttributes
        >? = nil,
        localAttributes: ImageButtonAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?
            .imageButtonAttributeFactory
        {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        let mergedAttributes = ImageButtonComponent
            .applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config
            )

        // If a container level factory function was provided for this
        // component, use it and supply global attribute overrides instead
        // of local, if provided.
        if let builder = suppliedFactory,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedImageButtonStyle(
                config: config,
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            ImageButtonComponent(
                config: config,
                content: content,
                style: style
            )
        }
    }

    @ViewBuilder
    func buildMenu(
        config: MenuConfig,
        content: MenuContent,
        suppliedFactory: ComponentBuilder.Factory<
            Menu<Text, Button<Text>>,
            MenuConfig,
            MenuContent,
            MenuAttributes
        >? = nil,
        localAttributes: MenuAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?.menuAttributeFactory {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        let mergedAttributes = MenuComponent.applyStandardCustomizations(
            onto: attributes,
            theme: theme,
            config: config
        )

        // If a container level factory function was provided for this
        // component, use it and supply global attribute overrides instead
        // of local, if provided.
        if let builder = suppliedFactory,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedMenuStyle(
                config: config,
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            MenuComponent(
                config: config,
                content: content,
                style: style
            )
        }
    }

    @ViewBuilder
    func buildTextEditor(
        config: TextEditorConfig,
        content: TextEditorContent,
        suppliedFactory: ComponentBuilder.Factory<
            TextEditor,
            TextEditorConfig,
            TextEditorContent,
            TextEditorAttributes
        >? = nil,
        localAttributes: TextEditorAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?
            .textEditorAttributeFactory
        {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        let mergedAttributes = TextEditorComponent
            .applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config
            )

        // If a container level factory function was provided for this component,
        // use it and supply global attribute overrides instead of local, if provided.
        if let builder = suppliedFactory,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedTextEditorStyle(
                config: config,
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            TextEditorComponent(
                config: config,
                content: content,
                style: style
            )
        }
    }

    @ViewBuilder
    func buildTextInput(
        config: TextInputConfig,
        content: TextInputContent,
        suppliedFactory: ComponentBuilder.Factory<
            TextField<Text>,
            TextInputConfig,
            TextInputContent,
            TextInputAttributes
        >? = nil,
        localAttributes: TextInputAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?
            .textInputAttributeFactory
        {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        let mergedAttributes = TextInputComponent
            .applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config
            )

        // If a container level factory function was provided for this component,
        // use it and supply global attribute overrides instead of local, if provided.
        if let builder = suppliedFactory,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedTextInputStyle(
                config: config,
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            TextInputComponent(
                config: config,
                content: content,
                style: style
            )
        }
    }

    @ViewBuilder
    func buildSegment(
        config: SegmentConfig,
        content: SegmentContent,
        suppliedFactory: ComponentBuilder.Factory<
            some View,
            SegmentConfig,
            SegmentContent,
            SegmentAttributes
        >? = nil,
        localAttributes: SegmentAttributes? = nil
    ) -> some View {
        let attributes = if let factory = global?
            .segmentAttributeFactory
        {
            factory(config, content, localAttributes)
        } else {
            localAttributes
        }

        let mergedAttributes = SegmentComponent
            .applyStandardCustomizations(
                onto: attributes,
                theme: theme,
                config: config
            )

        // If a container level factory function was provided for this component,
        // use it and supply global attribute overrides instead of local, if provided.
        if let builder = suppliedFactory,
           let view = builder(config, content, mergedAttributes)
        {
            view
        } else {
            let style = ParraAttributedSegmentStyle(
                config: config,
                content: content,
                attributes: mergedAttributes,
                theme: theme
            )

            SegmentComponent(
                config: config,
                content: content,
                style: style
            )
        }
    }
}
