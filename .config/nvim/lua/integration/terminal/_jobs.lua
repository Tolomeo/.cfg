local fn = require("_shared.fn")
local validator = require("_shared.validator")

---@class TerminalJob
---@field buffer number

---@class TerminalJobs
local Jobs = {
	_current = 0,
}

---@type fun(self: TerminalJobs, job_buffer: number): number | nil
Jobs.find_index_by_buffer = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, job_buffer)
	local job_index = fn.find_index(self, function(job)
		return job.buffer == job_buffer
	end)

	if not job_index then
		return nil
	end

	return job_index
end

Jobs.find_by_buffer = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, job_buffer)
	local job_index = self:find_index_by_buffer(job_buffer)

	return job_index and self[job_index] or nil
end

---This logic relies on terminal buffer names being defined as term://{cwd}//{pid}:{cmd}
Jobs.find_index_by_cmd = validator.f.arguments({
	validator.f.equal(Jobs),
	"string",
}) .. function(self, cmd)
	local job_index = fn.find_index(self, function(job)
		return string.match(job.file, "term://.+//%d+:" .. cmd)
	end)

	if not job_index then
		return nil
	end

	return job_index
end

Jobs.find_by_cmd = validator.f.arguments({
	validator.f.equal(Jobs),
	"string",
}) .. function(self, cmd)
	local job_index = self:find_index_by_cmd(cmd)

	return job_index and self[job_index] or nil
end

---@type fun(self: TerminalJobs, window: number): TerminalJob | nil
Jobs.find_index_by_window = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, window)
	return self:find_index_by_buffer(vim.api.nvim_win_get_buf(window))
end

Jobs.find_by_window = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, window)
	local job_index = self:find_index_by_window(window)

	return job_index and self[job_index] or nil
end

---@type fun(self: TerminalJobs, job: TerminalJob)
Jobs.register = validator.f.arguments({
	validator.f.equal(Jobs),
	validator.f.shape({ buffer = "number", file = "string" }),
}) .. function(self, job)
	table.insert(self, job)
	self._current = #self
end

---@type fun(self: TerminalJobs, job_buffer: number)
Jobs.unregister = validator.f.arguments({
	validator.f.equal(Jobs),
	"number",
}) .. function(self, job_buffer)
	local job_index = self:find_index_by_buffer(job_buffer)

	if not job_index then
		return
	end

	table.remove(self, job_index)

	if not self[self._current] then
		self._current = self[1] and 1 or 0
	end
end

function Jobs:count()
	return #self
end

---@type fun(self: TerminalJobs, job_buffer: number | nil): TerminalJob | nil, number
Jobs.current = validator.f.arguments({ validator.f.equal(Jobs), validator.f.optional("number") })
	.. function(self, job_index)
		if not job_index then
			return self[self._current], self._current
		end

		self._current = self[job_index] and job_index or self._current

		return self[self._current], self._current
	end

---@type fun(self: TerminalJobs, job_buffer: number | nil): TerminalJob | nil, number
Jobs.next = validator.f.arguments({ validator.f.equal(Jobs), validator.f.optional("number") })
	.. function(self, job_index)
		local index = job_index and job_index or self._current
		local next_index = self[index + 1] and index + 1 or 1

		self._current = next_index
		return self:current()
	end

---@type fun(self: TerminalJobs, job_buffer: number | nil): TerminalJob | nil, number
Jobs.prev = validator.f.arguments({ validator.f.equal(Jobs), validator.f.optional("number") })
	.. function(self, job_index)
		local index = job_index and job_index or self._current
		local next_index = self[index - 1] and index - 1 or #self

		self._current = next_index
		return self:current()
	end

return Jobs
