-- https://github.com/runiq/neovim-throttle-debounce
local M = {}

---Validates args for `throttle()` and  `debounce()`.
local function td_validate(fn, ms)
	vim.validate({
		fn = { fn, "f" },
		ms = {
			ms,
			function(ms)
				return type(ms) == "number" and ms > 0
			end,
			"number > 0",
		},
	})
end

--- Throttles a function on the leading edge. Automatically `schedule_wrap()`s.
---
--@param fn (function) Function to throttle
--@param timeout (number) Timeout in ms
--@returns (function, timer) throttled function and timer. Remember to call
---`timer:close()` at the end or you will leak memory!
function M.throttle_leading(fn, ms)
	td_validate(fn, ms)
	local timer = vim.loop.new_timer()
	local running = false

	local function wrapped_fn(...)
		if not running then
			timer:start(ms, 0, function()
				running = false
			end)
			running = true
			pcall(vim.schedule_wrap(fn), select(1, ...))
		end
	end
	return wrapped_fn, timer
end

--- Throttles a function on the trailing edge. Automatically
--- `schedule_wrap()`s.
---
--@param fn (function) Function to throttle
--@param timeout (number) Timeout in ms
--@param last (boolean, optional) Whether to use the arguments of the last
---call to `fn` within the timeframe. Default: Use arguments of the first call.
--@returns (function, timer) Throttled function and timer. Remember to call
---`timer:close()` at the end or you will leak memory!
function M.throttle_trailing(fn, ms, last)
	td_validate(fn, ms)
	local timer = vim.loop.new_timer()
	local running = false

	local wrapped_fn
	if not last then
		function wrapped_fn(...)
			if not running then
				local argv = { ... }
				local argc = select("#", ...)

				timer:start(ms, 0, function()
					running = false
					pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
				end)
				running = true
			end
		end
	else
		local argv, argc
		function wrapped_fn(...)
			argv = { ... }
			argc = select("#", ...)

			if not running then
				timer:start(ms, 0, function()
					running = false
					pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
				end)
				running = true
			end
		end
	end
	return wrapped_fn, timer
end

--- Debounces a function on the leading edge. Automatically `schedule_wrap()`s.
---
--@param fn (function) Function to debounce
--@param timeout (number) Timeout in ms
--@returns (function, timer) Debounced function and timer. Remember to call
---`timer:close()` at the end or you will leak memory!
function M.debounce_leading(fn, ms)
	td_validate(fn, ms)
	local timer = vim.loop.new_timer()
	local running = false

	local function wrapped_fn(...)
		timer:start(ms, 0, function()
			running = false
		end)

		if not running then
			running = true
			pcall(vim.schedule_wrap(fn), select(1, ...))
		end
	end
	return wrapped_fn, timer
end

--- Debounces a function on the trailing edge. Automatically
--- `schedule_wrap()`s.
---
--@param fn (function) Function to debounce
--@param timeout (number) Timeout in ms
--@param first (boolean, optional) Whether to use the arguments of the first
---call to `fn` within the timeframe. Default: Use arguments of the last call.
--@returns (function, timer) Debounced function and timer. Remember to call
---`timer:close()` at the end or you will leak memory!
function M.debounce_trailing(fn, ms, first)
	td_validate(fn, ms)
	local timer = vim.loop.new_timer()
	local wrapped_fn

	if not first then
		function wrapped_fn(...)
			local argv = { ... }
			local argc = select("#", ...)

			timer:start(ms, 0, function()
				pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
			end)
		end
	else
		local argv, argc
		function wrapped_fn(...)
			argv = argv or { ... }
			argc = argc or select("#", ...)

			timer:start(ms, 0, function()
				pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
			end)
		end
	end
	return wrapped_fn, timer
end

return M
