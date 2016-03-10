
import File

public enum Errors : ErrorType {
    case ParseError
}

class Section {
    let name: String
    var options: [String: String] = [:]
    init(_ name: String){
        self.name = name
    }
    func add_option(line: String) throws {
        let line = line.trim()
        var parts: [String]
        if line.contains("=") {
            parts = line.split("=", maxSplit: 1)
        } else {
            throw Errors.ParseError
        }
        options[parts[0].trim()] = parts[1].trim()
    }
    func get(option: String) -> String? {
        return options[option]
    }
    subscript(option: String) -> String? {
        return self.get(option)
    }
    func getBool(option: String) -> Bool? {
        guard let option = self.get(option) else {
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
    func getInt(option: String) -> Int? {
        guard let option = self.get(option) else {
            return nil
        }
        return Int(option)
    }
    func getFloat(option: String) -> Float? {
        guard let option = self.get(option) else {
            return nil
        }
        return Float(option)
        
    }
}
extension Section: CustomStringConvertible {
    var description: String {
        return self.options.description
    }
}


public class INIParser {
    private var last_section: Section?
    private var sections: [String: Section] = [:]
    
    func read(pathes: String...) throws {
        for path in pathes {
            let file = try File(path: path)
            let content = try file.read()
            let text = String(content)
            try parse(text)
        }
        
    }
    func parse(text: String) throws {
        last_section = nil
        let lines = text.split("\n")
        for line in lines {
            let line = line.trim()
            if line.isEmpty || line.startsWith(";") || line.startsWith("#"){
                continue
            }
            if line.startsWith("[") {
                guard line.endsWith("]") else {
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
    
    
    func get(section: String, option: String) -> String? {
        return sections[section]?[option]
    }
    func get(section: String) -> Section? {
        return sections[section]
    }
    subscript(section: String) -> Section? {
        return self.get(section)
    }
}

extension INIParser: CustomStringConvertible {
    public var description: String {
        return self.sections.description
    }
}

