mod aoc;

fn main() {
    aoc::run("../input/day1", day1)
}

fn day1(input: &str) {
    let mut left_list: [i32; 1000] = [0; 1000];
    let mut right_list: [i32; 1000] = [0; 1000];
    let mut i = 0;
    for line in input.lines() {
        let left_num: i32 = line[0..5].parse().unwrap();
        let right_num: i32 = line[8..].parse().unwrap();
        left_list[i] = left_num;
        right_list[i] = right_num;
        i += 1;
    }
    left_list.sort_unstable();
    right_list.sort_unstable();
    let mut part1_res = 0;
    let mut cnt_map: [u8; 99999] = [0; 99999];
    for i in 0..1000 {
        let a = left_list[i];
        let b = right_list[i];
        cnt_map[b as usize] += 1;
        // println!("{:?}", entry.);
        part1_res += (a - b).abs();
    }
    let mut part2_res = 0;
    for num in left_list {
        part2_res += num * cnt_map[num as usize] as i32;
    }
    println!("part1: {}, part2: {}", part1_res, part2_res);
}
