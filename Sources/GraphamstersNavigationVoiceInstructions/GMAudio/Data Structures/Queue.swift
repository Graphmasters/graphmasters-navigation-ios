import Foundation

public struct Queue<T> {
    private var list: [T]

    public init(initialQueue: [T] = [T]()) {
        list = initialQueue
    }

    public mutating func enqueue(_ element: T) {
        list.append(element)
    }

    public mutating func enqueue(_ elements: [T]) {
        list.append(contentsOf: elements)
    }

    public mutating func dequeue() -> T? {
        if !list.isEmpty {
            return list.removeFirst()
        } else {
            return nil
        }
    }

    public mutating func dequeue(until isValid: (T) -> Bool) -> T? {
        while let element = dequeue() {
            guard isValid(element) else {
                continue
            }
            return element
        }
        return nil
    }

    public func peek() -> T? {
        if !list.isEmpty {
            return list[0]
        } else {
            return nil
        }
    }

    public var isEmpty: Bool {
        return list.isEmpty
    }

    public var count: Int {
        return list.count
    }

    @discardableResult
    public mutating func removeAll() -> [T] {
        let oldList = list
        list.removeAll()
        return oldList
    }
}

extension Queue: Sequence {
    public typealias Iterator = QueueIterator<T>

    public func makeIterator() -> QueueIterator<T> {
        Iterator(list.makeIterator())
    }
}

public extension Queue where T: Hashable {
    mutating func remove(_ element: T) {
        list.removeAll { $0 == element }
    }
}

public final class QueueIterator<T>: IteratorProtocol {
    private var iterator: IndexingIterator<[T]>

    fileprivate init(_ iterator: IndexingIterator<[T]>) {
        self.iterator = iterator
    }

    public func next() -> T? {
        while let obj = iterator.next() {
            return obj
        }
        return nil
    }
}
