import time

def read_input(path):
    with open(path, 'r', encoding='utf-8') as file:
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

    lines = input.split('\n')
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

run("../input/day1", day1)
