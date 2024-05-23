import class AsyncAlgorithms.AsyncChannel
import func Bytes2Chunks.bytes2chunks
import struct Foundation.Data
import class Foundation.FileHandle

func file2chan(file: FileHandle, chan: AsyncChannel<UInt8>) async throws -> Int {
  let dat: Data = try file.read(upToCount: 1) ?? Data()
  for item in dat {
    await chan.send(item)
  }
  return dat.count
}

typealias ByteSource = (AsyncChannel<UInt8>) async throws -> Int

func file2byteSource(file: FileHandle) -> ByteSource {
  return {
    let tgt: AsyncChannel<UInt8> = $0
    return try await file2chan(file: file, chan: tgt)
  }
}

let stdinSource: ByteSource = file2byteSource(file: FileHandle.standardInput)

func sendAll(
  chan: AsyncChannel<UInt8>,
  source: ByteSource,
  stop: Bool
) async throws {
  guard !stop else {
    chan.finish()
    return
  }

  let sentSize: Int = try await source(chan)
  try await sendAll(chan: chan, source: source, stop: sentSize < 1)
}

@main
struct StdinToChunks {
  static func main() async throws {
    let input: AsyncChannel<UInt8> = AsyncChannel()
    Task {
      try await sendAll(chan: input, source: stdinSource, stop: false)
    }
    let chunks: AsyncChannel<[UInt8]> = AsyncChannel()
    Task {
      await bytes2chunks(bytes: input, chunks: chunks, chunkSize: 8)
    }
    let filtered = chunks.filter {
      let chunk: [UInt8] = $0
      return 8 == chunk.count
    }
    for await i64 in filtered {
      i64.withUnsafeBytes {
        let raw: UnsafeRawBufferPointer = $0
        let ptr: UnsafeBufferPointer<Int64> = raw.assumingMemoryBound(
          to: Int64.self
        )
        print(ptr[0])
      }
    }
  }
}
