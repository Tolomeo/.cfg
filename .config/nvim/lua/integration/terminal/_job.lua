local fn = require("_shared.fn")
local validator = require("_shared.validator")

---@class TerminalJob
---@field buffer number

---@class TerminalJobs
local Job = {
	_current = 0,
}

---@type fun(self: TerminalJobs, job_buffer: number): TerminalJob | nil
Job.find_index_by_buffer = validator.f.arguments({
	validator.f.equal(Job),
	"number",
}) .. function(self, job_buffer)
	local job_index = fn.find_index(self, function(job)
		return job.buffer == job_buffer
	end)

	if not job_index then
		return nil
	end

	return self[job_index]
end

---@type fun(self: TerminalJobs, window: number): TerminalJob | nil
Job.find_index_by_window = validator.f.arguments({
	validator.f.equal(Job),
	"number",
}) .. function(self, window)
	return self:find_index_by_buffer(vim.api.nvim_win_get_buf(window))
end

---@type fun(self: TerminalJobs, job: TerminalJob)
Job.register = validator.f.arguments({
	validator.f.equal(Job),
	validator.f.shape({ buffer = "number", file = "string" }),
}) .. function(self, job)
	table.insert(self, job)
	self._current = #self
end

---@type fun(self: TerminalJobs, job_buffer: number)
Job.unregister = validator.f.arguments({
	validator.f.equal(Job),
	"number",
}) .. function(self, job_buffer)
	local job_index = fn.find_index(self, function(job)
		return job.buffer == job_buffer
	end)

	if not job_index then
		return
	end

	table.remove(self, job_index)

	if not self[self._current] then
		self._current = self[1] and 1 or 0
	end
end

function Job:count()
	return #self
end

---@type fun(self: TerminalJobs, job_buffer: number | nil): TerminalJob | nil, number
Job.current = validator.f.arguments({ validator.f.equal(Job), validator.f.optional("number") })
	.. function(self, job_buffer)
		if not job_buffer then
			return self[self._current], self._current
		end

		self._current = fn.find_index(self, function(job)
			return job.buffer == job_buffer
		end) or self._current

		return self[self._current], self._current
	end

---@type fun(self: TerminalJobs, job_buffer: number | nil): TerminalJob | nil, number
Job.next = validator.f.arguments({ validator.f.equal(Job), validator.f.optional("number") })
	.. function(self, job_buffer)
		local index = job_buffer and fn.find_index(self, function(job)
			return job.buffer == job_buffer
		end) or self._current
		local next_index = self[index + 1] and index + 1 or 1

		self._current = next_index
		return self:current()
	end

---@type fun(self: TerminalJobs, job_buffer: number | nil): TerminalJob | nil, number
Job.prev = validator.f.arguments({ validator.f.equal(Job), validator.f.optional("number") })
	.. function(self, job_buffer)
		local index = job_buffer and fn.find_index(self, function(job)
			return job.buffer == job_buffer
		end) or self._current
		local next_index = self[index - 1] and index - 1 or #self

		self._current = next_index
		return self:current()
	end

return Job
