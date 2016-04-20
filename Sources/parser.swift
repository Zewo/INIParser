
import File

public enum Errors : ErrorProtocol {
    case ParseError
}

public class Section {
    let name: String
    var options: [String: String] = [:]
    init(_ name: String){
        self.name = name
    }
    func add_option(_ line: String) throws {
        let line = line.trim()
        var parts: [String]
        if line.contains("=") {
            parts = line.split(separator: "=", maxSplits: 1)
        } else {
            throw Errors.ParseError
        }
        options[parts[0].trim()] = parts[1].trim()
    }
    public func get(_ option: String) -> String? {
        return options[option]
    }
    public subscript(option: String) -> String? {
        return self.get(option)
    }
    public func get(_ option: String) -> Bool? {
        guard let option: String = self.get(option) else {
            return nil
        }
        switch option {
        case "0", "false", "no", "off":
            return false
        case "1", "true", "yes", "on":
            return true
        default:
            return nil
        }
        
    }
    public func get(_ option: String) -> Int? {
        guard let option: String = self.get(option) else {
            return nil
        }
        return Int(option)
    }
    public func get(_ option: String) -> Float? {
        guard let option: String = self.get(option) else {
            return nil
        }
        return Float(option)
        
    }
}
extension Section: CustomStringConvertible {
    public var description: String {
        return self.options.description
    }
}


public class INIParser {
    private var last_section: Section?
    private var sections: [String: Section] = [:]
    public init(){
    }
    public func read(_ pathes: String...) throws {
        for path in pathes {
            let file = try File(path: path)
            let content = try file.readAllBytes()
            let text = String(content)
            try parse(text)
        }
        
    }
    public func parse(_ text: String) throws {
        last_section = nil
        let lines = text.split(separator: "\r\n")
        for line in lines {
            let line = line.trim()
            if line.isEmpty || line.starts(with: ";") || line.starts(with: "#"){
                continue
            }
            if line.starts(with: "[") {
                guard line.ends(with: "]") else {
                    throw Errors.ParseError
                }
                let section_name = line.trim(["[", "]"])
                last_section = Section(section_name)
                sections[section_name] = last_section
            } else {
                guard line.contains("=") else {
                    throw Errors.ParseError
                }
                guard let last_section = last_section else {
                    throw Errors.ParseError
                }
                try last_section.add_option(line)
            }
        }
    }
    
    
    public func get(_ section: String, option: String) -> String? {
        return sections[section]?[option]
    }
    public func get(_ section: String) -> Section? {
        return sections[section]
    }
    public subscript(section: String) -> Section? {
        return self.get(section)
    }
}

extension INIParser: CustomStringConvertible {
    public var description: String {
        return self.sections.description
    }
}

