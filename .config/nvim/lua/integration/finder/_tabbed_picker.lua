local Object = require("_shared.object")
local key = require("_shared.key")
local fn = require("_shared.fn")
local arr = require("_shared.array")
local tbl = require("_shared.table")
local validator = require("_shared.validator")
local settings = require("settings")

---@class Cfg.TabbedPicker.Tab
---@field prompt_title string
---@field find function

local TabbedPicker = Object:extend({
	current = 1,
})

TabbedPicker.constructor = validator.f.arguments({
	-- This would be cool but it is not possible because builtin pickers are launched directly
	-- validator.f.list({ validator.f.instance_of(require("telescope.pickers")._Picker) }),
	validator.f.instance_of(TabbedPicker),
	validator.f.list({ validator.f.shape({ prompt_title = "string", find = "function" }) }),
}) .. function(self, tabs)
		arr.push(self, unpack(tabs))
		self.current = 1

		return self.current
	end

function TabbedPicker:get_prompt_title()
	local opt = settings.opt
	local current_picker_title = "[ " .. self[self.current].prompt_title .. " ]"

	-- Creating a table containing all titles making up for the left half of the title
	-- starting from the left half of the current picker title and looping backward
	local i_left = self.current - 1
	local prev_picker_titles = { string.sub(current_picker_title, 1, math.floor(#current_picker_title / 2)) }
	repeat
		if i_left < 1 then
			i_left = #self
		else
			table.insert(prev_picker_titles, 1, self[i_left].prompt_title)
			i_left = i_left - 1
		end
	until i_left == self.current

	-- Creating a table containing all titles making up for the right half of the title
	-- starting from the right half of the current picker title and looping onward
	local i_right = self.current + 1
	local next_picker_titles = {
		string.sub(current_picker_title, (math.floor(#current_picker_title / 2)) + 1, #current_picker_title),
	}
	repeat
		if i_right > #self then
			i_right = 1
		else
			table.insert(next_picker_titles, self[i_right].prompt_title)
			i_right = i_right + 1
		end
	until i_right == self.current

	-- Merging left and right, capping at 40 chars length
	local prompt_title_left = string.reverse(
		string.sub(string.reverse(table.concat(prev_picker_titles, " ")), 1, (20 - #opt.listchars.precedes))
	)
	local prompt_title_right = string.sub(table.concat(next_picker_titles, " "), 1, (20 - #opt.listchars.extends))
	local prompt_title = opt.listchars.precedes .. prompt_title_left .. prompt_title_right .. opt.listchars.extends

	return prompt_title
end

---@param buffer number
---@return boolean
function TabbedPicker:attach_mappings(buffer)
	local keymap = settings.keymap

	key.nmap({
		keymap["buffer.next"],
		fn.bind(self.next, self),
		buffer = buffer,
	}, {
		keymap["buffer.prev"],
		fn.bind(self.prev, self),
		buffer = buffer,
	})

	return true
end

TabbedPicker.get_options = validator.f.arguments({
	validator.f.instance_of(TabbedPicker),
	validator.f.optional(validator.f.shape({ initial_mode = validator.f.one_of({ "normal", "insert" }) })),
}) .. function(self, options)
	options = options or {}

	return vim.tbl_extend("force", options, {
		prompt_title = self:get_prompt_title(),
		attach_mappings = fn.bind(self.attach_mappings, self),
	})
end

function TabbedPicker:prev()
	local options = self:get_options({ initial_mode = "normal" })

	self.current = self.current <= 1 and #self or self.current - 1
	local picker = self[self.current]

	return picker.find(options)
end

function TabbedPicker:next()
	local options = self:get_options({ initial_mode = "normal" })

	self.current = self.current >= #self and 1 or self.current + 1
	local picker = self[self.current]

	return picker.find(options)
end

function TabbedPicker:find(options)
	options = options or {}
	options = tbl.merge(options, self:get_options({ initial_mode = "normal" }))

	local picker = self[self.current]
	return picker.find(options)
end

function TabbedPicker:append(tab)
	table.insert(self, tab)

	if self.current == #self then
		self.current = self[#self - 1] and #self - 1 or #self
	end
end

function TabbedPicker:prepend(tab)
	table.insert(self, 1, tab)

	if self.current == 1 then
		self.current = self[2] and 2 or 1
	end
end

-- function Tabs:remove(picker) end

return TabbedPicker
