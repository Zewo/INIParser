# INIParser
INI config parser


### Usage:

```swift
let p = INIParser()

try p.read("/Users/usr/github/INIParser/example.cfg")

print(p.get("section", option:"prop"))
print(p["section"]?.getInt("prop"))
print(p)
```
