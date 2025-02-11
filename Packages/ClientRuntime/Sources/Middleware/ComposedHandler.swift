// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0.

// handler chain, used to decorate a handler with middleware
public struct ComposedHandler<MInput, MOutput, Context: MiddlewareContext> {
    // the next handler to call
    let next: AnyHandler<MInput, MOutput, Context>
    
    // the middleware decorating 'next'
    let with: AnyMiddleware<MInput, MOutput, Context>
    
    public init<H: Handler, M: Middleware> (_ realNext: H, _ realWith: M)
    where H.Input == MInput,
          H.Output == MOutput,
          M.MInput == MInput,
          M.MOutput == MOutput,
          M.Context == Context,
          H.Context == Context {
        
        self.next = AnyHandler(realNext)
        self.with = AnyMiddleware(realWith)
    }
}

extension ComposedHandler: Handler {
    public func handle(context: Context, input: MInput) async throws -> MOutput {
        return try await with.handle(context: context, input: input, next: next)
    }
}
