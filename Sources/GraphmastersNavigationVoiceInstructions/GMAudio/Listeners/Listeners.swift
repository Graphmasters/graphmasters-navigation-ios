import Foundation

public final class Listeners<T> {
    private var contents = NSMutableSet()

    /**
     Returns the number of references currently in the set.

     Includes potential nil references, so this number >= allObjects.count
     */
    public var count: Int {
        return contents.count
    }

    public init() {}

    /**
     Adds the specified object to the set.
     */
    public func add(_ object: T) {
        contents.add(object)
    }

    /**
     Removes the specified object from the set.
     */
    public func remove(_ object: T) {
        contents.remove(object)
    }
}

extension Listeners: Sequence {
    public typealias Iterator = ListenersIterator<T>

    public func makeIterator() -> Iterator {
        return ListenersIterator(contents.makeIterator())
    }
}

public final class ListenersIterator<T>: IteratorProtocol {
    private var iterator: NSFastEnumerationIterator

    fileprivate init(_ iterator: NSFastEnumerationIterator) {
        self.iterator = iterator
    }

    public func next() -> T? {
        while let obj = iterator.next() {
            if let target = obj as? T {
                return target
            }
        }
        return nil
    }
}
