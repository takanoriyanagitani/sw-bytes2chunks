import XCTest

import class AsyncAlgorithms.AsyncChannel

@testable import func Bytes2Chunks.bytes2chunks

final class Bytes2ChunksTests: XCTestCase {
  func testEmpty() async throws {
    let inputs: AsyncChannel<UInt8> = AsyncChannel()
    let outputs: AsyncChannel<[UInt8]> = AsyncChannel()
    inputs.finish()
    Task {
      await bytes2chunks(bytes: inputs, chunks: outputs, chunkSize: 16)
    }
    var cnt: Int = 0
    for await _ in outputs {
      cnt += 1
    }
    XCTAssertEqual(cnt, 0)
  }

  func testDouble() async throws {
    let inputs: AsyncChannel<UInt8> = AsyncChannel()
    let outputs: AsyncChannel<[UInt8]> = AsyncChannel()
    Task {
      await inputs.send(1)
      await inputs.send(2)
      await inputs.send(3)
      await inputs.send(4)
      inputs.finish()
    }
    Task {
      await bytes2chunks(bytes: inputs, chunks: outputs, chunkSize: 2)
    }
    var cnt: Int = 0
    for await _ in outputs {
      cnt += 1
    }
    XCTAssertEqual(cnt, 2)
  }

  func testPartial() async throws {
    let inputs: AsyncChannel<UInt8> = AsyncChannel()
    let outputs: AsyncChannel<[UInt8]> = AsyncChannel()

    Task {
      await inputs.send(1)
      await inputs.send(2)
      await inputs.send(3)
      await inputs.send(4)
      await inputs.send(5)
      inputs.finish()
    }

    Task {
      await bytes2chunks(bytes: inputs, chunks: outputs, chunkSize: 2)
    }

    var chunks: AsyncChannel<_>.Iterator = outputs.makeAsyncIterator()

    let c1: [UInt8] = await chunks.next() ?? []
    XCTAssertEqual(c1, [1, 2])

    let c2: [UInt8] = await chunks.next() ?? []
    XCTAssertEqual(c2, [3, 4])

    let c3: [UInt8] = await chunks.next() ?? []
    XCTAssertEqual(c3, [5])
  }
}
