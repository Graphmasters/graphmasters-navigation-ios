//
//  FeatureNavigationShared
//  Copyright © 2022, Graphmasters GmbH — All Rights Reserved
//
//  Unauthorized copying of this file, via any medium is strictly prohibited.
//  Proprietary and confidential.
//

import Foundation
import GMCore

public final class AggregatingSessionParamProvider: SessionClientParameterProvider {
    private var parameterProviders: [SessionClientParameterProvider]

    public init(parameterProviders: [SessionClientParameterProvider]) {
        self.parameterProviders = parameterProviders
    }

    public func add(parameterProvider: SessionClientParameterProvider) {
        parameterProviders.append(parameterProvider)
    }

    public func getAdditionalParams(sessionId: String) -> [String: String] {
        return parameterProviders
            .map { $0.getAdditionalParams(sessionId: sessionId) }
            .flattendUsingFirstEntry()
    }
}
