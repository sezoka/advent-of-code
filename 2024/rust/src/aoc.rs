fn read_input(path: &str) -> String {
    return std::fs::read_to_string(path).unwrap();
}

type Solution = fn(input: &str);

pub fn run(path: &str, solution: Solution) {
    println!("==== {}", path);
    let start_time = std::time::Instant::now();
    solution(&read_input(path));
    println!("==== time: {:?}", start_time.elapsed());
}

