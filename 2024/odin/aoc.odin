package aoc

import "core:fmt"
import os "core:os/os2"
import "core:time"

read_input :: proc(file_path: string) -> []byte {
    data, err := os.read_entire_file_from_path(file_path, context.allocator)
    switch err {
    case os.General_Error.None:
        return data
    case os.General_Error.Not_Exist:
        fmt.eprintfln("File '%s' not found", file_path)
    case:
        fmt.eprintfln("Unhandled error in 'read_input': %%", err)
    }
    return data
}

Solution :: proc(input: []byte)

run :: proc(file_path: string, solution: Solution) {
    ally := context.allocator
    defer context.allocator = ally
    context.allocator = context.temp_allocator
    defer free_all(context.allocator)
    file := read_input(file_path)
    fmt.printf("====%s\n", file_path)
    start_time := time.now()
    solution(file)
    end_time := time.now()
    elapsed := time.diff(start_time, end_time)
    fmt.printf("====time: %d\n", elapsed)
}
