local groups = {}
local module = {}
local setmetatable = setmetatable
local error = error
local wait = wait
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

local function request (url, method, suppress, data)
  local body = method(httpService, url, data)
  local success, response = pcall(decode, body)
  local err
  if success then
    err = response.error
  else
    err = 'Response was not valid json, full body: '..body
  end
  if not err and suppress then
    return true, response
  elseif not err then
    return response
  elseif suppress then
    return false, err
  else
    error(err)
  end
end

local http = {
  post = function (path, data, suppress)
    if not data then
      data = {}
    end
    data.key = key
    return request(base..path, postAsync, suppress, encode(data))
  end,
  get = function (path, suppress)
    return request(base..path, getAsync, suppress)
  end
}

function groups.promote (group, userId)
  return http.post('/promote/'..group..'/'..userId)
end

function groups.demote (group, userId)
  return http.post('/demote/'..group..'/'..userId)
end

function groups.setRank (group, userId, rank)
  return http.post('/setRank/'..group..'/'..userId..'/'..rank)
end

function groups.shout (group, message)
  return http.post('/shout/'..group, {message = message})
end

function groups.post (group, message)
  return http.post('/post/'..group, {message = message})
end

function groups.handleJoinRequest (group, username, accept)
  local acceptString = accept and 'true' or 'false'
  return http.post('/handleJoinRequest/'..group..'/'..username..'/'..acceptString)
end

function groups.getPlayers (group, rank, limit, online)
  local job = http.post('/getPlayers/make/'..group..(rank and '/'..rank or '')..'?limit='..(limit and limit or '-2')..'&online='..(online and 'true' or 'false')).data.uid
  local complete, response = false
  repeat
    wait(0.5)
    local success
    success, response = http.get('/getPlayers/retrieve/'..job, true)
    if not success and response:match('$Response was not valid json') then
      error(response)
    elseif success then
      complete = response.data.complete
    end
  until complete
  return response
end

function module.message (userId, subject, message)
  return http.post('/message/'..userId, {subject = subject, body = message})
end

function module.forumPostNew (forumId, subject, body, locked)
  return http.post('/forumPost/new/'..forumId..'?locked='..(locked and 'true' or 'false'), {subject = subject, body = body})
end

function module.forumPostReply (postId, body, locked)
  return http.post('/forumPost/reply/'..postId..'?locked='..(locked and 'true' or 'false'), {body = body})
end

function module.getBlurb (userId)
  return http.get('/getBlurb/'..userId)
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
