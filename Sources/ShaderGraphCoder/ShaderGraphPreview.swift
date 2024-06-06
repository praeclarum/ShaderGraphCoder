//
//  ShaderGraphPreview.swift
//  HoloVids
//
//  Created by Frank A. Krueger on 6/5/24.
//

#if os(visionOS)

import SwiftUI
import RealityKit

struct ShaderGraphPreview: View {
    let surface: SGToken?
    let geometryModifier: SGToken? = nil
    @State private var error: String? = nil
    var body: some View {
        VStack {
            if let e = error {
                Text(e)
                    .font(.title)
                    .padding()
                    .background(.red)
                    .foregroundStyle(.white)
                    .frame(maxWidth: 600)
            }
            RealityView { content in
                do {
                    let mat = try await ShaderGraphMaterial(surface: surface, geometryModifier: geometryModifier)
                    let entity0 = ModelEntity(mesh: .generateBox(size: 0.2/sqrt(2)), materials: [mat])
                    entity0.transform.translation = [-0.1, 0.0, 0.0]
                    let entity1 = ModelEntity(mesh: .generateSphere(radius: 0.1), materials: [mat])
                    entity1.transform.translation = [0.1, 0.0, 0.0]
                    content.add(entity0)
                    content.add(entity1)
                }
                catch {
                    if case ShaderGraphCoderError.graphContainsErrors(errors: let es) = error {
                        self.error = es.joined(separator: "\n")
                    }
                    else {
                        self.error = error.localizedDescription
                    }
                }
            }
        }
    }
}

#Preview {
    ShaderGraphPreview(surface: (.blue*(sin(.time * 2.0 * SGValue.pi)*0.5 + 0.5)).pbrSurface())
}

#endif
