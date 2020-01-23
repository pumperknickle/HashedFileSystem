import Regenerate

public protocol HashedFS: RGArtifact {
    associatedtype HashedFSDictionary: RGDictionary where HashedFSDictionary.Value.Artifact == Self, HashedFSDictionary.Key == String
    associatedtype FileScalar: RGScalar where FileScalar.T == String
    associatedtype FileDictionary: RGDictionary where FileDictionary.Value.Artifact == FileScalar, FileDictionary.Key == String
    associatedtype HashedFSAddress: Addressable where HashedFSAddress.Artifact == HashedFSDictionary
    associatedtype FileAddress: Addressable where FileAddress.Artifact == FileDictionary
    
    static var fileSystemsProperty: String! { get }
    static var filesProperty: String! { get }
    
    var fileSystemsAddress: HashedFSAddress! { get }
    var filesAddress: FileAddress! { get }
    
    init(fileSystemsAddress: HashedFSAddress, filesAddress: FileAddress)
}

public extension HashedFS {
    static func empty() -> Self {
        return Self(fileSystemsAddress: HashedFSAddress(artifact: HashedFSDictionary(da: [:])!, complete: true)!, filesAddress: FileAddress(artifact: FileDictionary(da: [:])!, complete: true)!)
    }
    
    func listDirectories(_ path: [String]) -> [String]? {
        guard let fileSystemDictionary = fileSystemsAddress.artifact else { return nil }
        if let firstLeg = path.first {
            guard let childAddress = fileSystemDictionary.children[firstLeg] else { return nil }
            guard let child = childAddress.artifact else { return nil }
            return child.listDirectories(Array(path.dropFirst()))
        }
        return fileSystemDictionary.children.keys()
    }
    
    func getFile(_ path: [String]) -> String? {
        guard let firstLeg = path.first else { return nil }
        if path.count == 1 {
            guard let filesDictionary = filesAddress.artifact else { return nil }
            guard let fileAddress = filesDictionary.children[firstLeg] else { return nil }
            guard let fileScalar = fileAddress.artifact else { return nil }
            return fileScalar.scalar
        }
        guard let fileSystemDictionary = fileSystemsAddress.artifact else { return nil }
        guard let childAddress = fileSystemDictionary.children[firstLeg] else { return nil }
        guard let child = childAddress.artifact else { return nil }
        return child.getFile(Array(path.dropFirst()))
    }
    
    func listFiles(_ path: [String]) -> [String]? {
        if let firstLeg = path.first {
            guard let fileSystemDictionary = fileSystemsAddress.artifact else { return nil }
            guard let childAddress = fileSystemDictionary.children[firstLeg] else { return nil }
            guard let child = childAddress.artifact else { return nil }
            return child.listFiles(Array(path.dropFirst()))
        }
        guard let filesDictionary = filesAddress.artifact else { return nil }
        return filesDictionary.children.keys()
    }
    
    func createFile(_ path: [String], contents: String) -> Self? {
        guard let firstLeg = path.first else { return nil }
        if path.count == 1 {
            guard let filesDictionary = filesAddress.artifact else { return nil }
            let filesScalar = FileScalar(scalar: contents)
            guard let filesAddress = FileDictionary.Value(artifact: filesScalar, complete: true) else { return nil }
            let newDictionary = filesDictionary.setting(key: firstLeg, to: filesAddress)
            guard let newAddress = FileAddress(artifact: newDictionary, complete: true) else { return nil }
            return Self(fileSystemsAddress: fileSystemsAddress, filesAddress: newAddress)
        }
        guard let fileSystemDictionary = fileSystemsAddress.artifact else { return nil }
        guard let child = fileSystemDictionary.children[firstLeg] else { return nil }
        guard let fs = child.artifact else { return nil }
        guard let newFS = fs.createFile(Array(path.dropFirst()), contents: contents) else { return nil }
        guard let newFSAddress = HashedFSDictionary.Value(artifact: newFS, complete: true) else { return nil }
        let newChild = fileSystemDictionary.setting(key: firstLeg, to: newFSAddress)
        guard let newChildAddress = HashedFSAddress(artifact: newChild, complete: true) else { return nil }
        return Self(fileSystemsAddress: newChildAddress, filesAddress: filesAddress)
    }
    
    func makeDirectory(_ path: [String]) -> Self? {
        if let firstLeg = path.first {
            if let fileSystemDictionary = fileSystemsAddress.artifact {
                if let child = fileSystemDictionary.children[firstLeg] {
                    guard let fs = child.artifact else { return nil }
                    guard let newFs = fs.makeDirectory(Array(path.dropFirst())) else { return nil }
                    guard let newFSAddress = HashedFSDictionary.Value(artifact: newFs, complete: true) else { return nil }
                    let newChild = fileSystemDictionary.setting(key: firstLeg, to: newFSAddress)
                    guard let newChildAddress = HashedFSAddress(artifact: newChild, complete: true) else { return nil }
                    return Self(fileSystemsAddress: newChildAddress, filesAddress: filesAddress)
                }
                else {
                    guard let newFS = Self.empty().makeDirectory(Array(path.dropFirst())) else { return nil }
                    guard let newFSAddress = HashedFSDictionary.Value(artifact: newFS, complete: true) else { return nil }
                    let newChild = fileSystemDictionary.setting(key: firstLeg, to: newFSAddress)
                    guard let newChildAddress = HashedFSAddress(artifact: newChild, complete: true) else { return nil }
                    return Self(fileSystemsAddress: newChildAddress, filesAddress: filesAddress)
                }
            }
            else {
                guard let newFS = Self.empty().makeDirectory(Array(path.dropFirst())) else { return nil }
                guard let newFSAddress = HashedFSDictionary.Value(artifact: newFS, complete: true) else { return nil }
                guard let child = HashedFSDictionary(da: [:]) else { return nil }
                let newChild = child.setting(key: firstLeg, to: newFSAddress)
                guard let newChildAddress = HashedFSAddress(artifact: newChild, complete: true) else { return nil }
                return Self(fileSystemsAddress: newChildAddress, filesAddress: filesAddress)
            }
        }
        else {
            return self
        }
    }
    
    func get(property: String) -> CryptoBindable? {
        switch property {
        case Self.fileSystemsProperty:
            return fileSystemsAddress
        case Self.filesProperty:
            return filesAddress
        default:
            return nil
        }
    }
    
    func set(property: String, to child: CryptoBindable) -> Self? {
        switch property {
        case Self.fileSystemsProperty:
            guard let newChild = child as? HashedFSAddress else { return nil }
            return Self(fileSystemsAddress: newChild, filesAddress: filesAddress)
        case Self.filesProperty:
            guard let newChild = child as? FileAddress else { return nil }
            return Self(fileSystemsAddress: fileSystemsAddress, filesAddress: newChild)
        default:
            return nil
        }
    }
    
    static func properties() -> [String] {
        return [fileSystemsProperty, filesProperty]
    }
}

public struct HashedFS256: HashedFS {
    public typealias HashedFSDictionary = Dictionary256<String, Address<Self>>
    public typealias FileScalar = Scalar<String>
    public typealias FileDictionary = Dictionary256<String, Address<FileScalar>>
    public typealias HashedFSAddress = Address<HashedFSDictionary>
    public typealias FileAddress = Address<FileDictionary>
    
    public static let fileSystemsProperty: String! = "fileSystemsProperty"
    public static let filesProperty: String! = "filesProperty"
    
    private let rawFileSystemsAddress: HashedFSAddress!
    private let rawFilesAddress: FileAddress!
    
    public var fileSystemsAddress: HashedFSAddress! { return rawFileSystemsAddress }
    public var filesAddress: FileAddress! { return rawFilesAddress }
    
    public init(fileSystemsAddress: HashedFSAddress, filesAddress: FileAddress) {
        rawFileSystemsAddress = fileSystemsAddress
        rawFilesAddress = filesAddress
    }
}
