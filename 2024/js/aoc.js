import fs from 'fs';

function readInput(path) {
    return fs.readFileSync(path, 'utf8');
}

export function run(path, solution) {
    console.log(`==== ${path}`);
    const startTime = process.hrtime();
    solution(readInput(path));
    "\x1b[2J"
    const elapsedTime = process.hrtime(startTime);
    console.log(`==== time: ${elapsedTime[0]}s ${elapsedTime[1] / 1e6}ms`);
}
