import 'package:dart/aoc.dart' as aoc;

void main() {
    aoc.run("../input/day1", day1);
    aoc.run("../input/day2", day2);
    aoc.run("../input/day3", day3);
    aoc.run("../input/day4", day4);
    aoc.run("../input/day5", day5);
}

void day5(input) {
    final ordering_rules = new Map<int, List<int>>();
    final lines = input.split('\n');
    int line_idx = 0;
    for (; ; line_idx += 1) {
        final line = lines[line_idx];
        if (line == "") break;
        final before = int.parse(line.substring(0, 2));
        final after = int.parse(line.substring(3));
        final before_entry = ordering_rules[before];
        if (before_entry == null) {
            ordering_rules[before] = [after];
        } else {
            before_entry.add(after);
        }
    }

    line_idx += 1;

    int part1_res = 0;
    int part2_res = 0;
    main_loop: for (; line_idx < lines.length; line_idx += 1) {
        final line = lines[line_idx];
        if (line == "") break;
        List<int> nums = [];
        final nums_strs = line.split(",");
        for (final num_str in nums_strs) {
            final num = int.parse(num_str);
            nums.add(num);
        }

        for (int i = 0; i < nums.length; i += 1) {
            final num = nums[i];
            final num_rules = ordering_rules[num] ?? [];
            final rest = nums.sublist(i + 1);
            for (int j = 0; j < rest.length; j += 1) {
                final num_with_lower_priority = rest[j];
                final is_before = num_rules.contains(num_with_lower_priority);
                if (!is_before) {
                    nums.sort((lhs, rhs) => 
                        ordering_rules[rhs]!.contains(lhs) ? 1 : -1
                    );
                    final middle = nums[nums.length ~/ 2];
                    part2_res += middle;
                    continue main_loop;
                }
            }
        }
        final middle = nums[nums.length ~/ 2];
        part1_res += middle;
    }

    print("part1: $part1_res, part2: $part2_res");
}

void day4(String input) {
    String get_char(String input, int w, int x, int y) {
        final idx = y * w + x;
        if (x < 0 || y < 0 || w <= x || input.length / w <= y) return "";
        return input[idx];
    }

    const xmas = "XMAS";
    bool check_xmas(String input, int w, int x, int y, int xit, int yit) {
        int xx = x;
        int yy = y;
        for (final c in xmas.split("")) {
            if (get_char(input, w, xx, yy) != c) {
                return false;
            }
            xx += xit;
            yy += yit;
        }
        return true;
    }

    bool check_mas(String input, int w, int x, int y) {
        if (get_char(input, w, x, y) != 'A') {
            return false;
        }

        final left_up = get_char(input, w, x - 1, y - 1);
        final left_down = get_char(input, w, x - 1, y + 1);
        final right_up = get_char(input, w, x + 1, y - 1);
        final right_down = get_char(input, w, x + 1, y + 1);
        if ((left_up != 'M' && left_up != 'S') ||
            (left_down != 'M' && left_down != 'S'))
            return false;
        if (left_up == 'M' && right_down != 'S') return false;
        if (left_up == 'S' && right_down != 'M') return false;
        if (left_down == 'M' && right_up != 'S') return false;
        if (left_down == 'S' && right_up != 'M') return false;
        return true;
    }

    int width = 0;
    while (input[width] != '\n') width += 1;
    String buff = "";
    for (final c in input.split("")) {
        if (c != '\n') buff += c;
    }


    int part1_res = 0;
    int part2_res = 0;
    for (int i = 0; i < buff.length; i += 1) {
        final x = i % width;
        final y = (i / width).toInt();
        if (check_xmas(buff, width, x, y, 0, -1)) part1_res += 1;
        if (check_xmas(buff, width, x, y, 1, -1)) part1_res += 1;
        if (check_xmas(buff, width, x, y, 1, 0)) part1_res += 1;
        if (check_xmas(buff, width, x, y, 1, 1)) part1_res += 1;
        if (check_xmas(buff, width, x, y, 0, 1)) part1_res += 1;
        if (check_xmas(buff, width, x, y, -1, 1)) part1_res += 1;
        if (check_xmas(buff, width, x, y, -1, 0)) part1_res += 1;
        if (check_xmas(buff, width, x, y, -1, -1)) part1_res += 1;
        if (check_mas(buff, width, x, y)) {
            part2_res += 1;
        }
    }

    print("part1: $part1_res, part2: $part2_res");
}

void day3(String input) {
    int part_1_res = 0;
    int part_2_res = 0;
    int i = -1;
    bool enabled = true;
    while (i < input.length) {
        i += 1;
        if (input.length <= i + 7) break;
        final prev_i = i;

        if ("don't()" == input.substring(i, i + 7)) {
            enabled = false;
            continue;
        }

        if ("do()" == input.substring(i, i + 4)) {
            enabled = true;
            continue;
        }

        if ("mul(" == input.substring(i, i + 4)) {
            i += 4;
            int start = i;
            while ('0'.codeUnitAt(0) <= input[i].codeUnitAt(0) && input[i].codeUnitAt(0) <= '9'.codeUnitAt(0)) {
                i += 1;
            }
            final x = input.substring(start, i);
            if (input[i] != ',') {
                i = prev_i;
                continue;
            }
            i += 1;
            start = i;
            while ('0'.codeUnitAt(0) <= input[i].codeUnitAt(0) && input[i].codeUnitAt(0) <= '9'.codeUnitAt(0)) {
                i += 1;
            }
            final y = input.substring(start, i);
            if (input[i] != ')') {
                i = prev_i;
                continue;
            }
            final sum = int.parse(x) * int.parse(y);
            part_1_res += sum;
            if (enabled) {
                part_2_res += sum;
            }
        }
    }
    print("part1: $part_1_res, part2: $part_2_res");
}

void day2(String input) {
     bool day_2_is_safe(List<int> nums) {
        final is_ascending = nums[0] < nums[1];
        for (int num_idx = 0; num_idx < nums.length - 1; num_idx += 1) {
            int x = 0;
            if (is_ascending)
                x = nums[num_idx + 1] - nums[num_idx];
            else
                x = nums[num_idx] - nums[num_idx + 1];
            final is_safe = 1 <= x && x <= 3;
            if (!is_safe) return false;
        }
        return true;
    }

    final lines = input.split("\n");
    int safe_reports = 0;
    int reports_that_can_be_fixed = 0;
    for (final line in lines) {
        if (line == "") break;
        List<int> nums = [];
        final num_strs_list = line.split(' ');
        for (final num_str in num_strs_list) {
            if (num_str.length == 0) break;
            final num = int.parse(num_str);
            nums.add(num);
        }

        if (day_2_is_safe(nums.sublist(0, nums.length))) {
            safe_reports += 1;
            continue;
        }
        for (int i = 0; i < nums.length; i += 1) {
            List<int> nums_with_removed_item = [];
            for (int j = 0; j < nums.length; j += 1) {
                if (i == j) continue;
                nums_with_removed_item.add(nums[j]);
            }
            if (day_2_is_safe(nums_with_removed_item.sublist(0, nums.length - 1))) {
                reports_that_can_be_fixed += 1;
                break;
            }
        }
    }
    print("part1: $safe_reports, part2: ${safe_reports + reports_that_can_be_fixed}");
}

void day1(String input) {
    List<int> left_list = [];
    List<int> right_list = [];
    final lines = input.split("\n");
    for (final line in lines) {
        if (line.length == 0) break;
        final left_num = int.parse(line.substring(0, 5));
        final right_num = int.parse(line.substring(8));
        left_list.add(left_num);
        right_list.add(right_num);
    }
    left_list.sort();
    right_list.sort();

    int part1_res = 0;
    Map<int, int> cnt_map = {};
    for (int i = 0; i < left_list.length; i += 1) {
        final a = left_list[i];
        final b = right_list[i];
        cnt_map[b] = (cnt_map[b] ?? 0) + 1;
        part1_res += (a - b).abs();
    }
    int part2_res = 0;
    for (final num in left_list) {
        part2_res += (cnt_map[num] ?? 0) * num;
    }
    print("part1: $part1_res, part2: $part2_res");
}
