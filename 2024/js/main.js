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

function day6(input) {
    function getCell(field, w, x, y) {
        if (x < 0 || w <= x || y < 0 || field.length / w <= y) {
            return "\0";
        }
        return field[y * w + x];
    }

    function removeWhitespaces(input) {
        const result = [];
        for (const c of input) {
            if (c !== '\n') {
                result.push(c);
            }
        }
        return result;
    }

    function lineLength(input) {
        for (let i = 0; i < input.length; i++) {
            if (input[i] === "\n") {
                return i;
            }
        }
        return input.length;
    }

    const origField = removeWhitespaces(input);
    const fieldWidth = lineLength(input);
    const fieldHeight = origField.length / fieldWidth;
    let guardStartX = 0;
    let guardStartY = 0;

    for (let i = 0; i < origField.length; i++) {
        if (origField[i] === "^") {
            guardStartX = i % fieldWidth;
            guardStartY = Math.floor(i / fieldWidth);
        }
    }

    let part1Res = 0;
    let part2Res = 0;
    const field = Array(origField.length).fill();
    let isFirstPart = true;

    outer: for (let obstaclePos = 0; obstaclePos < origField.length; obstaclePos++) {
        if (origField[obstaclePos] !== ".") {
            continue;
        }
        for (let i = 0; i < field.length; i++) {
            field[i] = origField[i];
        }
        field[obstaclePos] = "#";
        let guardX = guardStartX;
        let guardY = guardStartY;
        let guardDir = getCell(field, fieldWidth, guardX, guardY);

        inner: while (
            guardX > 0 &&
            guardX < fieldWidth &&
            guardY > 0 &&
            guardY < fieldHeight
        ) {
            if (!isFirstPart) {
                if (
                    field[guardX + guardY * fieldWidth] === guardDir &&
                    guardStartX !== guardX &&
                    guardStartY !== guardY
                ) {
                    part2Res += 1;
                    continue outer;
                }
            }

            if (field[guardX + guardY * fieldWidth] === ".") {
                field[guardX + guardY * fieldWidth] = guardDir;
            }

            let nextPosX = guardX;
            let nextPosY = guardY;

            switch (guardDir) {
                case "^":
                    nextPosY = guardY - 1;
                    break;
                case "v":
                    nextPosY = guardY + 1;
                    break;
                case "<":
                    nextPosX = guardX - 1;
                    break;
                case ">":
                    nextPosX = guardX + 1;
                    break;
                default:
                    console.log(guardDir);
                    throw new Error("Unexpected direction");
            }

            const nextPosCell = getCell(field, fieldWidth, nextPosX, nextPosY);
            switch (nextPosCell) {
                case "#":
                    switch (guardDir) {
                        case "^":
                            guardDir = ">";
                            break;
                        case "v":
                            guardDir = "<";
                            break;
                        case "<":
                            guardDir = "^";
                            break;
                        case ">":
                            guardDir = "v";
                            break;
                    }
                    break;
                case "\0":
                    break inner;
                default:
                    guardX = nextPosX;
                    guardY = nextPosY;
            }
        }

        field[guardX + guardY * fieldWidth] = guardDir;

        if (isFirstPart) {
            for (const c of field) {
                if (c !== "." && c !== "#") {
                    part1Res += 1;
                }
            }
            isFirstPart = false;
        }
    }

    console.log(`part1: ${part1Res}, part2: ${part2Res}\n`);
}

// run("../input/day1", day1);
// run("../input/day5", day5);
run("../input/day6", day6);

