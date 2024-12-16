
const fs = require('fs');

// Function to parse the disk map input
function parseDiskMap(input) {
    const blocks = [];
    let isFile = true; // Start with file
    for (let i = 0; i < input.length; i++) {
        const length = parseInt(input[i], 10);
        blocks.push(isFile ? { id: blocks.length / 2, length } : { length });
        isFile = !isFile; // Alternate between file and free space
    }
    return blocks;
}

// Function to compact the disk map
function compactDiskMap(blocks) {
    let result = [];
    for (const block of blocks) {
        if (block.id !== undefined) {
            // Add the file blocks
            result.push(...Array(block.length).fill(block.id));
        } else {
            // Add free space
            result.push(...Array(block.length).fill('.'));
        }
    }
    return result;
}

// Function to move whole files to the leftmost free space
function moveFilesToLeft(disk, blocks) {
    // Iterate over files in reverse order (highest ID first)
    for (let i = blocks.length - 1; i >= 0; i--) {
        const block = blocks[i];
        if (block.id !== undefined) {
            const fileLength = block.length;
            let freeIndex = disk.indexOf('.'); // Find the first free space

            // Find a span of free space that can fit the file
            while (freeIndex !== -1) {
                // Check if there is enough contiguous free space
                if (disk.slice(freeIndex, freeIndex + fileLength).every(b => b === '.')) {
                    // Move the file to the leftmost free space
                    for (let j = 0; j < fileLength; j++) {
                        disk[freeIndex + j] = block.id; // Place the file ID
                    }
                    // Clear the original file space
                    for (let j = 0; j < fileLength; j++) {
                        disk[disk.lastIndexOf(block.id)] = '.'; // Remove the file from its original position
                    }
                    break; // Move to the next file
                }
                // Move to the next free space
                freeIndex = disk.indexOf('.', freeIndex + 1);
            }
        }
    }
}

// Function to calculate the checksum
function calculateChecksum(disk) {
    let checksum = 0;
    for (let i = 0; i < disk.length; i++) {
        if (disk[i] !== '.') {
            checksum += i * disk[i];
        }
    }
    return checksum;
}

// Main function to read input and process the disk map
function main() {
    const input = fs.readFileSync('../input/day9', 'utf8').trim();
    const blocks = parseDiskMap(input);
    let disk = compactDiskMap(blocks);

    // Move whole files to the leftmost free space
    moveFilesToLeft(disk, blocks);

    const checksum = calculateChecksum(disk);
    console.log('Filesystem Checksum:', checksum);
}

main();

