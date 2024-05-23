import class AsyncAlgorithms.AsyncChannel

public func bytes2chunks(
  bytes: AsyncChannel<UInt8>, chunks: AsyncChannel<[UInt8]>, chunkSize: Int
) async {
  var buf: [UInt8] = []
  for await item in bytes {
    buf.append(item)
    let cnt: Int = buf.count
    if chunkSize <= cnt {
      await chunks.send(buf)
      buf = []
    }
  }
  if 0 < buf.count {
    await chunks.send(buf)
  }
  chunks.finish()
}
