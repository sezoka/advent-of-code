import time


def read_input(path):
    with open(path, "r", encoding="utf-8") as file:
        return file.read()


def run(path, solution):
    print(f"==== {path}")
    start_time = time.time()
    solution(read_input(path))
    elapsed_time = time.time() - start_time
    print(f"==== time: {elapsed_time:.6f}s")


def day1(input):
    left_list = [0] * 1000
    right_list = [0] * 1000
    i = 0

    lines = input.split("\n")
    for line in lines:
        if len(line) == 0:
            break
        left_num = int(line[0:5])
        right_num = int(line[8:])
        left_list[i] = left_num
        right_list[i] = right_num
        i += 1

    left_list.sort()
    right_list.sort()

    part1_res = 0
    cnt_map = [0] * 99999
    for j in range(1000):
        a = left_list[j]
        b = right_list[j]
        cnt_map[b] += 1
        part1_res += abs(a - b)

    part2_res = 0
    for num in left_list:
        part2_res += num * cnt_map[num]

    print(f"part1: {part1_res}, part2: {part2_res}")


# Example usage:
# day1("12345 67890\n23456 78901\n...")  # Replace with actual input


def day6(input):
    def get_cell(field: list[str], w, x, y):
        if x < 0 or w <= x or y < 0 or len(field) / w <= y:
            return "\0"
        return field[y * w + x]

    def remove_whitespaces(input):
        result = []
        for c in input:
            if c != "\n":
                result.append(c)
        return result

    def line_length(input):
        for i, c in enumerate(input):
            if c == "\n":
                return i
        return len(input)

    orig_field = remove_whitespaces(input)
    field_width = line_length(input)
    field_height = len(orig_field) / field_width
    guard_start_x = 0
    guard_start_y = 0
    for i, c in enumerate(orig_field):
        if c == "^":
            guard_start_x = i % field_width
            guard_start_y = i // field_width
    part1_res = 0
    part2_res = 0
    field = ["0"] * len(orig_field)
    is_first_part = True
    for obstacle_pos in range(len(orig_field)):
        if orig_field[obstacle_pos] != ".":
            continue
        for i in range(len(field)):
            field[i] = orig_field[i]
        field[obstacle_pos] = "#"
        guard_x = guard_start_x
        guard_y = guard_start_y
        guard_dir = get_cell(field, field_width, guard_x, guard_y)

        is_continue = False

        while (
            0 < guard_x
            and guard_x < field_width
            and 0 < guard_y
            and guard_y < field_height
        ):
            if not is_first_part:
                if (
                    field[guard_x + guard_y * field_width] == guard_dir
                    and guard_start_x != guard_x
                    and guard_start_y != guard_y
                ):
                    part2_res += 1
                    is_continue = True
                    break

            if field[guard_x + guard_y * field_width] == ".":
                field[guard_x + guard_y * field_width] = guard_dir

            next_pos_x = guard_x
            next_pos_y = guard_y
            match guard_dir:
                case "^":
                    next_pos_y = guard_y - 1
                case "v":
                    next_pos_y = guard_y + 1
                case "<":
                    next_pos_x = guard_x - 1
                case ">":
                    next_pos_x = guard_x + 1
                case _:
                    print(guard_dir)
                    raise RuntimeError

            next_pos_cell = get_cell(field, field_width, next_pos_x, next_pos_y)
            match next_pos_cell:
                case "#":
                    match guard_dir:
                        case "^":
                            guard_dir = ">"
                        case "v":
                            guard_dir = "<"
                        case "<":
                            guard_dir = "^"
                        case ">":
                            guard_dir = "v"
                case "\0":
                    break
                case _:
                    guard_x = next_pos_x
                    guard_y = next_pos_y

        field[guard_x + guard_y * field_width] = guard_dir

        if is_continue:
            continue

        if is_first_part:
            for c in field:
                if c != "." and c != "#":
                    part1_res += 1
            is_first_part = False

    print(f"part1: {part1_res}, part2: {part2_res}\n")


def find_antennas_and_antinodes(map_input):
    # Parse the map input
    antennas = {}
    for y, line in enumerate(map_input):
        for x, char in enumerate(line):
            if char.isalnum():  # Check if it's an antenna (letter or digit)
                if char not in antennas:
                    antennas[char] = []
                antennas[char].append((x, y))

    antinode_locations = set()

    # Calculate antinodes for each frequency
    for freq, positions in antennas.items():
        n = len(positions)
        for i in range(n):
            for j in range(n):
                if i != j:
                    x1, y1 = positions[i]
                    x2, y2 = positions[j]
                    dx = x2 - x1
                    dy = y2 - y1
                    # Check if one antenna is twice as far as the other
                    if abs(dx) == 2 * abs(dy) or abs(dy) == 2 * abs(dx):
                        # Calculate antinode positions
                        antinode_x1 = x1 + dx // 2
                        antinode_y1 = y1 + dy // 2
                        antinode_x2 = x2 + dx // 2
                        antinode_y2 = y2 + dy // 2
                        antinode_locations.add((antinode_x1, antinode_y1))
                        antinode_locations.add((antinode_x2, antinode_y2))

    return len(antinode_locations)


# Example map input
map_input = [
    "............",
    "........0...",
    ".....0......",
    ".......0....",
    "....0.......",
    "......A.....",
    "............",
    "............",
    "........A...",
    ".........A..",
    "............",
    "............",
]

# Calculate the number of unique antinode locations
result = find_antennas_and_antinodes(map_input)
print("Number of unique locations with antinodes:", result)
