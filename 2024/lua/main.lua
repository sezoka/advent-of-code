dofile("aoc.lua")

function SplitLines(input)
    local lines = {}
    for line in string.gmatch(input, "[^\n]+") do
        table.insert(lines, line)
    end
    return lines
end

function PrintArray(t)
    io.write("[")
    for key, value in pairs(t) do
        if type(value) == "table" then
            io.write(key .. ":")
            PrintArray(value) -- Recursively print nested tables
        else
            io.write(value .. ", ")
        end
    end
    io.write("]\n")
end

function Day1(input)
    local left_list = {}
    local right_list = {}
    local lines = SplitLines(input)
    for _, line in ipairs(lines) do
        if line == "" then break end;
        local left_num = tonumber(string.sub(line, 0, 5));
        local right_num = tonumber(string.sub(line, 8));
        table.insert(left_list, left_num)
        table.insert(right_list, right_num)
    end
    table.sort(left_list)
    table.sort(right_list)

    local part1_res = 0;
    local cnt_map = {}
    for i = 1, #left_list do
        PrintArray(left_list)
        local a = left_list[i]
        local b = right_list[i]
        cnt_map[b] = (cnt_map[b] or 0) + 1
        part1_res = part1_res + math.abs(a - b)
    end

    local part2_res = 0
    for _, num in ipairs(left_list) do
        part2_res = part2_res + (cnt_map[num] or 0) * num;
    end
    print("part1: " .. part1_res .. " part2: " .. part2_res);
end

Run("../input/day1", Day1)
