---@see https://github.com/luvit/luvit/blob/master/deps/fs.lua
local uv = vim.loop

local Fs = {}

local function noop() end

function Fs.existsSync(path)
	local stat, err = uv.fs_stat(path)
	return stat ~= nil, err
end

function Fs.readFileSync(path)
	local fd, stat, chunk, err
	fd, err = uv.fs_open(path, "r", 438 --[[ 0666 ]])
	if err then
		return false, err
	end
	stat, err = uv.fs_fstat(fd)
	if stat then
		if stat.size > 0 then
			chunk, err = uv.fs_read(fd, stat.size, 0)
		else
			local chunks = {}
			local pos = 0
			while true do
				chunk, err = uv.fs_read(fd, 8192, pos)
				if not chunk or #chunk == 0 then
					break
				end
				pos = pos + #chunk
				chunks[#chunks + 1] = chunk
			end
			if not err then
				chunk = table.concat(chunks)
			end
		end
	end
	uv.fs_close(fd, noop)
	return chunk, err
end

function Fs.writeFileSync(path, data)
	local _, fd, err
	fd, err = uv.fs_open(path, "w", 438 --[[ 0666 ]])
	if err then
		return false, err
	end
	_, err = uv.fs_write(fd, data, 0)
	uv.fs_close(fd, noop)
	return not err, err
end

function Fs.mkdirSync(path, mode)
	if mode == nil then
		mode = 511
	elseif type(mode) == "string" then
		mode = tonumber(mode, 8)
	end
	return uv.fs_mkdir(path, mode)
end

function Fs.statSync(path)
	return uv.fs_stat(path)
end

return Fs
