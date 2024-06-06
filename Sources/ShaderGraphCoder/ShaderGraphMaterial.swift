//
//  ShaderGraphMaterial.swift
//  ShaderGraphCoder
//
//  Created by Frank A. Krueger on 2/10/24.
//

import Foundation
import RealityKit

#if os(visionOS)

public extension ShaderGraphMaterial {
    init(surface: SGToken?, geometryModifier: SGToken?) async throws {
        let materialName = "ShaderGraphCoderMaterial"
        let (usda, errors) = getUSDA(materialName: materialName, surface: surface, geometryModifier: geometryModifier)
        if errors.count > 0 {
            throw ShaderGraphCoderError.graphContainsErrors(errors: errors)
        }
        guard let usdaData = usda.data(using: .utf8) else {
            throw ShaderGraphCoderError.failedToEncodeUSDAsData
        }
        try await self.init(named: "/Root/\(materialName)", from: usdaData)
    }
}

#endif
