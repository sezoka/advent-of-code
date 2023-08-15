package aoc2022

import "core:fmt"
import "core:bytes"

day_1 :: proc(input: []u8) -> (part_1: int, part_2: int) {
    input := input

    top_1 := 0
    top_2 := 0
    top_3 := 0

    for digits_block in bytes.split_iterator(&input, []u8{'\n', '\n'}) {
        digits_block := digits_block

        nums_sum := 0
        for digits in bytes.split_iterator(&digits_block, []u8{'\n'}) {
            num := 0
            for digit in digits {
                num = num * 10 + int(digit) - '0'
            }
            nums_sum += num
        }

        if top_1 < nums_sum {
            top_3 = top_2
            top_2 = top_1
            top_1 = nums_sum
        } else if top_2 < nums_sum {
            top_3 = top_2
            top_2 = nums_sum
        } else if top_3 < nums_sum {
            top_3 = nums_sum
        }
    }

    part_1 = top_1
    part_2 = top_1 + top_2 + top_3

    return part_1, part_2
}
