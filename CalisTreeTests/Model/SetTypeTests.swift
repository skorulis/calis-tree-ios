// Created by Alex Skorulis on 15/5/2026.

import Foundation
import Testing
@testable import CalisTree

struct SetTypeTests {

    @Test func testEncoding() async throws {
        let example1 = SetType.reps(10)
        let data = try JSONEncoder().encode(example1)
        let text = String(data: data, encoding: .utf8)
        #expect(text == "{\"reps\":{\"_0\":10}}")
    }

}


