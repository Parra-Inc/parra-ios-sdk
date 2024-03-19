//
//  FeedbackFormByIdSample.swift
//  Sample
//
//  Created by Mick MacCallum on 2/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can use your own custom logic for determining how
/// and when to present a Parra Feedback Form. The steps to achieve this are:
///
/// 1. Create an `@State` variable to control the presentation state of the
///    feedback form.
/// 2. Pass the identifier of the form you wish to present and the isPresented
///    binding to the `presentParraFeedbackForm` modifier.
/// 3. When you're ready to present the form, update the value of `isPresented`
///    to `true`. The form will be fetched and presented automatically.
struct FeedbackFormByIdSample: View {
    @State var isPresented = false // #1

    var body: some View {
        VStack {
            Button("Fetch and present feedback form") {
                isPresented = true
            }
        }
        .presentParraFeedbackForm( // #2
            by: "65e6186e-365c-40cf-99d8-dadde255f4f5",
            isPresented: $isPresented
        )
    }
}

#Preview {
    ParraAppPreview {
        FeedbackFormByIdSample()
    }
}
