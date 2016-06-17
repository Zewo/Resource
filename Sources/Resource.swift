// Resource.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@_exported import Router
@_exported import ContentNegotiationMiddleware

public struct Resource: RouterProtocol {
    public let middleware: [Middleware]
    public let routes: [Route]
    public let fallback: Responder
    public let matcher: RouteMatcher

    public init(_ path: String = "", middleware: [Middleware] = [], mediaTypes: MediaType..., build: (resource: ResourceBuilder) -> Void) {
        let builder = ResourceBuilder(path: path)
        build(resource: builder)

        let contentNegotiaton = ContentNegotiationMiddleware(mediaTypes: mediaTypes)
        self.middleware = [contentNegotiaton] + middleware

        self.fallback = builder.fallback
        self.matcher = TrieRouteMatcher(routes: builder.routes)
        self.routes = builder.routes
    }

    public func match(_ request: Request) -> Route? {
        return matcher.match(request)
    }
}

extension Resource {
    public func respond(to request: Request) throws -> Response {
        let responder = match(request) ?? fallback
        return try middleware.chain(to: responder).respond(to: request)
    }
}
