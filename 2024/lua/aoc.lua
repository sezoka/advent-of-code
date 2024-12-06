local function read_file(path)
    local file = io.open(path, "r")
    if not file then
        error("Could not open file " .. path)
    end
    local content = file:read("*all")
    file:close()
    return content
end

function Run(path, solution)
    io.write("@=== " .. path .. "\n| ")
    local start_time = os.clock()
    local file = read_file(path)
    solution(file)
    local elapsed = os.clock() - start_time;
    print("| time: " .. (elapsed * 1000) .. "ms");
end
