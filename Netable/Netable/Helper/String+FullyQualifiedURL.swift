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
     * Make the provided path into a fully qualified URL. It may be invalid or partially qualified.
     *
     * - parameter path: The request path to qualify.
     *
     * - Throws: `NetableError` if the provided URL is invalid and unable to be corrected.
     *
     * - returns: A fully qualified URL if successful, an `Error` if not.
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
