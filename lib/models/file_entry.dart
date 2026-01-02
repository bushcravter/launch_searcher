library;

//
// Flutter packages
//
import 'dart:io';
import 'package:flutter/material.dart';

//
// pub.dev packages
//
//
// internal packages
//

class FileEntry {
  /// The full path to the file.
  final String path;

  /// The name of the file.
  final String filename;

  FileEntry({required this.path, required this.filename});

  /// Creates an instance of [FileEntry] from a single line of text
  /// returned by the 'fd' command.
  factory FileEntry.fromLine(String line) {
    // The line is the full path.
    String path = line.trim();
    // The filename is the last part of the path.
    String filename = path.split('/').last;
    return FileEntry(path: path, filename: filename);
  }

  /// Reads the file entries from the filesystem.
  ///
  /// Executes the `fd` command to find files and converts the output into a
  /// list of [FileEntry] objects.
  ///
  /// Throws an exception if the command fails or returns no output.
  static Future<List<FileEntry>> readFiles() async {
    try {
      // Execute the 'fd' command to find all files.
      // We search from the user's home directory.
      String home = Platform.environment['HOME'] ?? '.';
      final result = await Process.run('fd', ['.', '--type', 'f', '--absolute-path'], workingDirectory: home);

      // Check if the command was successful.
      if (result.exitCode != 0) {
        if (result.stderr.toString().contains('No such file or directory')) {
          throw Exception('"fd" was not found. Is the program installed and in the system PATH?');
        }
        throw Exception('Error executing "fd": ${result.stderr}');
      }

      // The output of the command as a string.
      final String stdout = result.stdout as String;

      // If the output is empty, return an empty list.
      if (stdout.trim().isEmpty) {
        return [];
      }

      // Convert each line of the output into a FileEntry object.
      // Empty lines at the end are ignored.
      final lines = stdout.trim().split('\n');
      return lines.map((line) => FileEntry.fromLine(line)).toList();
    } catch (e) {
      // Pass the error on and log it for debugging.
      debugPrint('Error reading files: $e');
      rethrow;
    }
  }

  /// Opens the file with the default application using `xdg-open`.
  Future<void> launch() async {
    try {
      await Process.start('xdg-open', [path]);
      debugPrint('Successfully launched xdg-open for file: $path');
      exit(0);
    } catch (e) {
      debugPrint('Error launching file: $e');
    }
  }

  /// Filters a list of [FileEntry] objects based on a search term.
  ///
  /// Returns a new list containing only the entries whose filename
  /// contains the [searchTerm] (case-insensitive).
  static List<FileEntry> filterEntries(List<FileEntry> entries, String searchTerm) {
    if (searchTerm.isEmpty) {
      return entries; // If no search term is present, return all entries.
    }

    final lowerCaseSearchTerm = searchTerm.toLowerCase();
    return entries.where((entry) {
      return entry.filename.toLowerCase().contains(lowerCaseSearchTerm);
    }).toList();
  }

  @override
  String toString() {
    return 'FileEntry(path: "$path", filename: "$filename")';
  }
}
