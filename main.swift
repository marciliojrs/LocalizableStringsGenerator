#!/usr/bin/swift

//
//  main.swift
//  LocalizableStringsGenerator
//
//  Created by Marcilio Junior on 11/28/15.
//  Copyright © 2015 Mobilitech. All rights reserved.
//

import Foundation

// MARK: - String Extension

extension String {
    
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
                return from ..< to
        }
        
        return nil
    }
    
}

// MARK: - Main function

func openEachFileAt(path: String, destinationPath: String) {
    do {
        var list: Set<String> = []
        
        let subdirectories = try NSFileManager.defaultManager().subpathsOfDirectoryAtPath(path)
        let swiftFiles = subdirectories.filter { $0.hasSuffix(".swift") }
        let regex = try NSRegularExpression(pattern: "\"([^\"]*)\".localized", options: .CaseInsensitive)
        
        for file in swiftFiles {
            let source = try String(contentsOfFile: path + file, encoding: NSUTF8StringEncoding)
            let matches = regex.matchesInString(source, options: .ReportProgress, range: NSMakeRange(0, source.characters.count))
            
            for match in matches {
                match.range
                let newRange = NSMakeRange(match.range.location, match.range.length - ".localized".characters.count)
                let s = source.substringWithRange(source.rangeFromNSRange(newRange)!)
                list.insert(s)
            }
        }
        
        var contents = ""
        for key in list {
            contents += key + " = " + key + ";\n"
        }
        
        let writePath = destinationPath + "Localizable.strings"
        try contents.writeToFile(writePath, atomically: true, encoding: NSUTF8StringEncoding)
        print("Arquivo gerado com sucesso")
    }
    catch (let error) {
        print(error)
    }
}

openEachFileAt(Process.arguments[1], destinationPath: Process.arguments[2])
