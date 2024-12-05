package aoc

import "core:bytes"
import "core:fmt"
import "core:slice"
import "core:sort"
import "core:strconv"

main :: proc() {
    run("../input/day1", day1)
}

day1 :: proc(input: []byte) {
    input_temp := input
    left_list: [dynamic]i32
    right_list: [dynamic]i32
    for line in bytes.split_iterator(&input_temp, {'\n'}) {
        if len(line) == 0 do break
        left_num, _ := strconv.parse_int(string(line[0:5]))
        right_num, _ := strconv.parse_int(string(line[8:]))
        append(&left_list, i32(left_num))
        append(&right_list, i32(right_num))
    }
    slice.sort(left_list[:])
    slice.sort(right_list[:])
    part1_res: i32
    cnt_map: map[i32]i32
    for i in 0 ..< len(left_list) {
        a := left_list[i]
        b := right_list[i]
        cnt_map[b] += 1
        part1_res += abs(a - b)
    }
    part2_res: i32
    for num in left_list {
        cnt, exists := cnt_map[num]
        if exists {
            part2_res += num * cnt
        }
    }
    fmt.printf("part1: %d, part2: %d\n", part1_res, part2_res)
}
