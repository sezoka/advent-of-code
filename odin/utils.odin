package aoc

import "core:fmt"
import "core:os"
import "core:bytes"

read_file :: proc(path: string) -> []byte {
    handle, open_err := os.open(path)
    if (open_err != os.ERROR_NONE) {
        fmt.print("Could not found file using path", path, "\n")
    }
    data, read_err := os.read_entire_file_from_handle(handle)

    return data
}

run_file :: proc(path: string, fn: proc(_: []u8) -> (int, int)) {
    file := read_file(path)
    part_1, part_2 := fn(file)
    fmt.print("\"", path, "\": { \n", sep="")
    fmt.print("  part_1: ", part_1, ",\n", sep = "")
    fmt.print("  part_2: ", part_2, ",\n", sep = "")
    fmt.print("},\n")
    delete(file)
}
