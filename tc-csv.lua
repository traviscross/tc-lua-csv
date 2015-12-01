-- Copyright (c) 2015 Travis Cross <tc@traviscross.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

-- This library implements a CSV parser and printer.

local csv={}

local read_header
function read_header(stream,sep)
  local l = stream:read()
  if not l then return nil,"header expected" end
  local hs = string.split(l,sep)
  return hs
end

local read_data_f
function read_data_f(stream,sep,accfn)
  local xs = {}
  while true do
    local l = stream:read()
    if not l then break end
    local ls = string.split(l,sep)
    accfn(xs,ls)
  end
  return xs
end

local read_data
function read_data(stream,sep,hs)
  local accfn = function(xs,ls)
    local x = {}
    for i,h in ipairs(hs) do
      x[h] = ls[i]
    end
    table.insert(xs,x)
  end
  return read_data_f(stream,sep,accfn)
end

local read_csv
function read_csv(stream,sep)
  local hs,err = read_header(stream,sep)
  if err then return nil,nil,err end
  local xs = read_data(stream,sep,hs)
  return xs,hs
end
csv.read = read_csv

local load_csv
function load_csv(file,sep)
  local stream = io.open(file,"r")
  if not stream then
    return nil,nil,"Could not open file: "..file
  end
  return read_csv(stream,sep)
end
csv.load = load_csv

local print_csv
function print_csv(stream,sep,xs,hs)
  stream:write(table.join(hs,sep).."\n")
  for _,x in ipairs(xs) do
    for j,h in ipairs(hs) do
      stream:write(x[h])
      if j ~= #hs then stream:write(sep) end
    end
    stream:write("\n")
  end
end
csv.print = print_csv

return csv
