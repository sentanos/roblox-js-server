local groups = {}
local module = {}
local setmetatable = setmetatable
local error = error
local httpService = game:GetService'HttpService'
local postAsync = httpService.PostAsync
local getAsync = httpService.GetAsync
local jsonEncode = httpService.JSONEncode
local jsonDecode = httpService.JSONDecode
local base, key

local function encode (tab)
  return jsonEncode(httpService, tab)
end

local function decode (tab)
  return jsonDecode(httpService, tab)
end

local function post (url, data)
  local body = postAsync(httpService, url, data)
  local success, response = pcall(decode, body)
  if (success) then
  	local err = response.error
  	if (err) then
  	  error(err)
  	else
  	  return response
  	end
  else
  	error('Response was not valid json, full body: '..body)
  end
end

local function http (path, data)
  if not data then
    data = {}
  end
  data.key = key
  return post(base..path, encode(data))
end

function groups.promote (group, userId)
  return http('/promote/'..group..'/'..userId)
end

function groups.demote (group, userId)
  return http('/demote/'..group..'/'..userId)
end

function groups.setRank (group, userId, rank)
  return http('/setRank/'..group..'/'..userId..'/'..rank)
end

function groups.shout (group, message)
  return http('/shout/'..group, {message = message})
end

function groups.post (group, message)
  return http('/post/'..group, {message = message})
end

function groups.handleJoinRequest (group, username, accept)
  local acceptString = accept and 'true' or 'false'
  return http('/handleJoinRequest/'..group..'/'..username..'/'..acceptString)
end

function groups.getPlayers (group, rank, limit, online)
  local job = http('/getPlayers/make/'..group..(rank and '/'..rank or '')..'?limit='..(limit and limit or '-2')..'&online='..(online and 'true' or 'false')).data.uid
  local complete, response = false
  repeat
    local body = getAsync(httpService, base..'/getPlayers/retrieve/'..job)
    local success
    success, response = pcall(decode, body)
    if not success then
    	error('Response was not valid json, full body: '..body)
    end
    complete = response.data.complete
  until complete
  return response
end

function module.message (userId, subject, message)
  return http('/message/'..userId, {subject = subject, body = message})
end

function module.forumPostNew (forumId, subject, body, locked)
  return http('/forumPost/new/'..forumId..'?locked='..(locked and 'true' or 'false'), {subject = subject, body = body})
end

function module.forumPostReply (postId, body, locked)
  return http('/forumPost/reply/'..postId..'?locked='..(locked and 'true' or 'false'), {body = body})
end

return function (domain, newKey, group)
  local isString = (type(domain) == 'string')
  if (not domain) or (not isString) or (isString and #domain <= 0) then
    error('Url is required and must be a string greater than length 0')
  end
  isString = (type(newKey) == 'string')
  if (not newKey) or (not isString) or (isString and #newKey <= 0) then
    error('Key is required and must be a string greater than length 0')
  end

  base = 'http://'..domain
  key = newKey

  if group then
    local isNumber = (type(group) == 'number')
    if (not isNumber) or (group <= 0) then
      error('If group is provided it must be a number greater than 0')
    end

    for name, func in next, groups do
      module[name] = function (...)
        return func(group, ...)
      end
    end
    return module
  end

  for name, func in next, groups do
    module[name] = func
  end
  return module
end
