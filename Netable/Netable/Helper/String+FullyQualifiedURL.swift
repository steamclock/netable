//
//  String+FullyQualifiedURL.swift
//  Netable
//
//  Created by Brendan on 2022-09-28.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation

extension String {
    /**
     * Attempts to turn the given string into a fully qualified URL.
     * If the provided URL has a scheme, we check to make sure that scheme is supported and return an `URL`.
     * If not, we attempt to prepend the provided `baseURL` and return the whole thing.
     *
     * - parameter baseURL: The base URL to attempt to attach to the string
     *
     * - Throws: `NetableError` if the provided URL is invalid and unable to be corrected.
     *
     * - returns: A fully qualified `URL`.
     */
    internal func fullyQualifiedURL(from baseURL: URL) throws -> URL {
        if self.isEmpty { return baseURL }

        // Make sure the url is a well formed path.
        guard let url = URL(string: self) else {
            throw NetableError.malformedURL
        }

        let finalURL: URL

        if url.scheme != nil {
            // Fully qualified URL, check it's okay.
            finalURL = url

            guard finalURL.absoluteString.hasPrefix(baseURL.absoluteString) else {
                throw NetableError.wrongServer
            }
        } else {
            // Partially qualified URL, add baseURL.
            guard let combinedURL = URL(string: self, relativeTo: baseURL) else {
                throw NetableError.malformedURL
            }

            finalURL = combinedURL
        }

        return finalURL
    }

}
