local Fn = {}

function Fn.ireduce(tbl, func, acc)
	for i, v in ipairs(tbl) do
		acc = func(acc, v, i)
	end
	return acc
end

function Fn.kreduce(tbl, func, acc)
	for i, v in pairs(tbl) do
		if type(i) == "string" then
			acc = func(acc, v, i)
		end
	end
	return acc
end

function Fn.reduce(tbl, func, acc)
	for i, v in pairs(tbl) do
		acc = func(acc, v, i)
	end
	return acc
end

return Fn
