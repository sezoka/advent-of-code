import { run } from "./aoc.js";


// function day1(input) {
//     const { leftList, rightList } = parseInput(input);
//     const sortedLeftList = sortArray(leftList);
//     const sortedRightList = sortArray(rightList);
//     
//     const { part1Res, cntMap } = calculatePart1(sortedLeftList, sortedRightList);
//     const part2Res = calculatePart2(sortedLeftList, cntMap);
//     
//     console.log(`part1: ${part1Res}, part2: ${part2Res}`);
// }

// function parseInput(input) {
//     const leftList = new Array(1000).fill(0);
//     const rightList = new Array(1000).fill(0);
//     let i = 0;

//     const lines = input.split('\n');
//     for (const line of lines) {
//         if (line.length === 0) break;
//         const leftNum = parseInt(line.substring(0, 5), 10);
//         const rightNum = parseInt(line.substring(8), 10);
//         leftList[i] = leftNum;
//         rightList[i] = rightNum;
//         i += 1;
//     }

//     return { leftList, rightList };
// }

// function sortArray(array) {
//     return array.sort((a, b) => a - b);
// }

// function calculatePart1(leftList, rightList) {
//     let part1Res = 0;
//     const cntMap = new Array(99999).fill(0);
//     
//     for (let j = 0; j < 1000; j++) {
//         const a = leftList[j];
//         const b = rightList[j];
//         cntMap[b] += 1;
//         part1Res += Math.abs(a - b);
//     }

//     return { part1Res, cntMap };
// }

// function calculatePart2(leftList, cntMap) {
//     let part2Res = 0;
//     for (const num of leftList) {
//         part2Res += num * cntMap[num];
//     }
//     return part2Res;
// }

function day5(input) {
    const ordering_rules = new Map();
    const lines = input.split('\n');
    let line_idx = 0;
    for (; ; line_idx += 1) {
        const line = lines[line_idx];
        if (line.length == 0) break;
        const before = Number(line.slice(0, 2))
        const after = Number(line.slice(3));
        const before_entry = ordering_rules.get(before);
        if (before_entry === undefined) {
            ordering_rules.set(before, [after]);
        } else {
            before_entry.push(after);
        }
    }

    var part1_res = 0;
    var part2_res = 0;
    main_loop: for (; line_idx < lines.length; line_idx += 1) {
        const line = lines[line_idx];
        const nums = [];
        const nums_strs = line.split(",");
        for (let i = 0; i < nums_strs.length; i += 1) {
            const num_str = nums_strs[i];
            const num = Number(num_str);
            nums.push(num);
        }

        for (let i = 0; i < nums.length; i += 1) {
            const num = nums[i];
            const num_rules = ordering_rules.get(num);
            const rest = nums.slice(i + 1);
            for (let j = 0; j < rest.length; j += 1) {
                const num_with_lower_priority = rest[j];
                const is_before = num_rules.includes(num_with_lower_priority);
                if (!is_before) {
                    const sorted = nums.sort((lhs, rhs) => {
                        return ordering_rules.get(rhs).includes(lhs) ? 1 : -1;
                    });
                    const middle = sorted[Math.trunc(nums.length / 2)];
                    part2_res += middle;
                    continue main_loop;
                }
            }
        }
        const middle = nums[Math.trunc(nums.length / 2)];
        part1_res += middle;
    }

    console.log(`part1: ${part1_res}, part2: ${part2_res}\n`);
}

// run("../input/day1", day1);
run("../input/day5", day5);

