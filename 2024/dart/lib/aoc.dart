import 'dart:io' as io;

String read_input(String file_path) {
    final file = io.File(file_path);
    try {
        return file.readAsStringSync();
    } catch (e) {
        print('Error reading file: $e');
        throw e;
    }
}

typedef Solution = void Function(String input);

void run(String file_path, Solution solution) {
    final file = read_input(file_path);
    print("==== $file_path");
    final start = DateTime.now();
    solution(file);
    final elapsed = (DateTime.now().microsecondsSinceEpoch - start.microsecondsSinceEpoch).toDouble() / 1000;
    print("==== time: ${elapsed}ms");
}
