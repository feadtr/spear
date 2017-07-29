--[[                                    Dev @lIMyIl         
   _____    _        _    _    _____    Dev @EMADOFFICAL 
  |_   _|__| |__    / \  | | _| ____|   Dev @h_k_a  
    | |/ __| '_ \  / _ \ | |/ /  _|     Dev @IX00XI
    | |\__ \ | | |/ ___ \|   <| |___    Dev @H_173
    |_||___/_| |_/_/   \_\_|\_\_____|   Dev @lIESIl
              CH > @TshAkETEAM
--]]
serpent = require('serpent')
serp = require 'serpent'.block
http = require("socket.http")
https = require("ssl.https")
http.TIMEOUT = 10
lgi = require ('lgi')
TSHAKE=dofile('utils.lua')
json=dofile('json.lua')
JSON = (loadfile  "./libs/dkjson.lua")()
redis = (loadfile "./libs/JSON.lua")()
redis = (loadfile "./libs/redis.lua")()
database = Redis.connect('127.0.0.1', 6379)
notify = lgi.require('Notify')
tdcli = dofile('tdcli.lua')
notify.init ("Telegram updates")
sudos = dofile('sudo.lua')
chats = {}
day = 86400
  -----------------------------------------------------------------------------------------------
                                     -- start functions --
  -----------------------------------------------------------------------------------------------
function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  return var
end
-----------------------------------------------------------------------------------------------
function is_admin(user_id)
    local var = false
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	 if admin then
	    var = true
	 end
  for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_vip_group(gp_id)
    local var = false
	local hashs =  'bot:vipgp:'
    local vip = database:sismember(hashs, gp_id)
	 if vip then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function is_owner(user_id, chat_id)
    local var = false
    local hash =  'bot:owners:'..chat_id
    local owner = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
    return var
end

-----------------------------------------------------------------------------------------------
function is_mod(user_id, chat_id)
    local var = false
    local hash =  'bot:mods:'..chat_id
    local mod = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	local hashss =  'bot:owners:'..chat_id
    local owner = database:sismember(hashss, user_id)
	 if mod then
	    var = true
	 end
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
    return var
end
-----------------------------------------------------------------------------------------------
function is_banned(user_id, chat_id)
    local var = false
	local hash = 'bot:banned:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end

function is_gbanned(user_id)
  local var = false
  local hash = 'bot:gbanned:'
  local banned = database:sismember(hash, user_id)
  if banned then
    var = true
  end
  return var
end
-----------------------------------------------------------------------------------------------
function is_muted(user_id, chat_id)
    local var = false
	local hash = 'bot:muted:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end

function is_gmuted(user_id, chat_id)
    local var = false
	local hash = 'bot:gmuted:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function get_info(user_id)
  if database:hget('bot:username',user_id) then
    text = '@'..(string.gsub(database:hget('bot:username',user_id), 'false', '') or '')..''
  end
  get_user(user_id)
  return text
  --db:hrem('bot:username',user_id)
end
function get_user(user_id)
  function dl_username(arg, data)
    username = data.username or ''

    --vardump(data)
    database:hset('bot:username',data.id_,data.username_)
  end
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, dl_username, nil)
end
local function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
local function check_filter_words(msg, value)
  local hash = 'bot:filters:'..msg.chat_id_
  if hash then
    local names = database:hkeys(hash)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_mod(msg.sender_user_id_, msg.chat_id_)then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
end
-----------------------------------------------------------------------------------------------
function resolve_username(username,cb)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, cb, nil)
end
  -----------------------------------------------------------------------------------------------
function changeChatMemberStatus(chat_id, user_id, status)
  tdcli_function ({
    ID = "ChangeChatMemberStatus",
    chat_id_ = chat_id,
    user_id_ = user_id,
    status_ = {
      ID = "ChatMemberStatus" .. status
    },
  }, dl_cb, nil)
end
  -----------------------------------------------------------------------------------------------
function getInputFile(file)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  return infile
end
  -----------------------------------------------------------------------------------------------
function del_all_msgs(chat_id, user_id)
  tdcli_function ({
    ID = "DeleteMessagesFromUser",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, nil)
end

  local function deleteMessagesFromUser(chat_id, user_id, cb, cmd)
    tdcli_function ({
      ID = "DeleteMessagesFromUser",
      chat_id_ = chat_id,
      user_id_ = user_id
    },cb or dl_cb, cmd)
  end
  -----------------------------------------------------------------------------------------------
function getChatId(id)
  local chat = {}
  local id = tostring(id)
  
  if id:match('^-100') then
    local channel_id = id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end
  
  return chat
end
  -----------------------------------------------------------------------------------------------
function chat_leave(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Left")
end
  -----------------------------------------------------------------------------------------------
function from_username(msg)
   function gfrom_user(extra,result,success)
   if result.username_ then
   F = result.username_
   else
   F = 'nil'
   end
    return F
   end
  local username = getUser(msg.sender_user_id_,gfrom_user)
  return username
end
  -----------------------------------------------------------------------------------------------
function chat_kick(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Kicked")
end
  -----------------------------------------------------------------------------------------------
function do_notify (user, msg)
  local n = notify.Notification.new(user, msg)
  n:show ()
end
  -----------------------------------------------------------------------------------------------
local function getParseMode(parse_mode)  
  if parse_mode then
    local mode = parse_mode:lower()
  
    if mode == 'markdown' or mode == 'md' then
      P = {ID = "TextParseModeMarkdown"}
    elseif mode == 'html' then
      P = {ID = "TextParseModeHTML"}
    end
  end
  return P
end
  -----------------------------------------------------------------------------------------------
local function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendContact(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, phone_number, first_name, last_name, user_id)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageContact",
      contact_ = {
        ID = "Contact",
        phone_number_ = phone_number,
        first_name_ = first_name,
        last_name_ = last_name,
        user_id_ = user_id
      },
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessagePhoto",
      photo_ = getInputFile(photo),
      added_sticker_file_ids_ = {},
      width_ = 0,
      height_ = 0,
      caption_ = caption
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUserFull(user_id,cb)
  tdcli_function ({
    ID = "GetUserFull",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
-----------------------------------------------------------------------------------------------
function dl_cb(arg, data)
end
-----------------------------------------------------------------------------------------------
local function send(chat_id, reply_to_message_id, disable_notification, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendaction(chat_id, action, progress)
  tdcli_function ({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessage" .. action .. "Action",
      progress_ = progress or 100
    }
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function changetitle(chat_id, title)
  tdcli_function ({
    ID = "ChangeChatTitle",
    chat_id_ = chat_id,
    title_ = title
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function edit(chat_id, message_id, reply_markup, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function setphoto(chat_id, photo)
  tdcli_function ({
    ID = "ChangeChatPhoto",
    chat_id_ = chat_id,
    photo_ = getInputFile(photo)
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function add_user(chat_id, user_id, forward_limit)
  tdcli_function ({
    ID = "AddChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id,
    forward_limit_ = forward_limit or 50
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function delmsg(arg,data)
  for k,v in pairs(data.messages_) do
    delete_msg(v.chat_id_,{[0] = v.id_})
  end
end
-----------------------------------------------------------------------------------------------
function unpinmsg(channel_id)
  tdcli_function ({
    ID = "UnpinChannelMessage",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function blockUser(user_id)
  tdcli_function ({
    ID = "BlockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function unblockUser(user_id)
  tdcli_function ({
    ID = "UnblockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function getBlockedUsers(offset, limit)
  tdcli_function ({
    ID = "GetBlockedUsers",
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function delete_msg(chatid,mid)
  tdcli_function ({
  ID="DeleteMessages", 
  chat_id_=chatid, 
  message_ids_=mid
  },
  dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function chat_del_user(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, 'Editor')
end
-----------------------------------------------------------------------------------------------
function getChannelMembers(channel_id, offset, filter, limit)
  if not limit or limit > 200 then
    limit = 200
  end
  tdcli_function ({
    ID = "GetChannelMembers",
    channel_id_ = getChatId(channel_id).ID,
    filter_ = {
      ID = "ChannelMembers" .. filter
    },
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getChannelFull(channel_id)
  tdcli_function ({
    ID = "GetChannelFull",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function channel_get_bots(channel,cb)
local function callback_admins(extra,result,success)
    limit = result.member_count_
    getChannelMembers(channel, 0, 'Bots', limit,cb)
    channel_get_bots(channel,get_bots)
end

  getChannelFull(channel,callback_admins)
end
-----------------------------------------------------------------------------------------------
local function getInputMessageContent(file, filetype, caption)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  local inmsg = {}
  local filetype = filetype:lower()

  if filetype == 'animation' then
    inmsg = {ID = "InputMessageAnimation", animation_ = infile, caption_ = caption}
  elseif filetype == 'audio' then
    inmsg = {ID = "InputMessageAudio", audio_ = infile, caption_ = caption}
  elseif filetype == 'document' then
    inmsg = {ID = "InputMessageDocument", document_ = infile, caption_ = caption}
  elseif filetype == 'photo' then
    inmsg = {ID = "InputMessagePhoto", photo_ = infile, caption_ = caption}
  elseif filetype == 'sticker' then
    inmsg = {ID = "InputMessageSticker", sticker_ = infile, caption_ = caption}
  elseif filetype == 'video' then
    inmsg = {ID = "InputMessageVideo", video_ = infile, caption_ = caption}
  elseif filetype == 'voice' then
    inmsg = {ID = "InputMessageVoice", voice_ = infile, caption_ = caption}
  end

  return inmsg
end

-----------------------------------------------------------------------------------------------
function send_file(chat_id, type, file, caption,wtf)
local mame = (wtf or 0)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = mame,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = getInputMessageContent(file, type, caption),
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUser(user_id, cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end 
-----------------------------------------------------------------------------------------------
function tdcli_update_callback(data)
	-------------------------------------------
  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    --vardump(data)
    local d = data.disable_notification_
    local chat = chats[msg.chat_id_]
	-------------------------------------------
	if msg.date_ < (os.time() - 30) then
       return false
    end
	-------------------------------------------
	if not database:get("bot:enable:"..msg.chat_id_) and not is_admin(msg.sender_user_id_, msg.chat_id_) then
      return false
    end
    -------------------------------------------
      if msg and msg.send_state_.ID == "MessageIsSuccessfullySent" then
	  --vardump(msg)
	   function get_mymsg_contact(extra, result, success)
             --vardump(result)
       end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,get_mymsg_contact)
         return false 
      end
    -------------* EXPIRE *-----------------
    if not database:get("bot:charge:"..msg.chat_id_) then
     if database:get("bot:enable:"..msg.chat_id_) then
      database:del("bot:enable:"..msg.chat_id_)
      for k,v in pairs(sudo_users) do
      end
      end
    end
    --------- ANTI FLOOD -------------------
	local hash = 'flood:max:'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_mod(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:'..msg.chat_id_
        if not database:get(hashse) then
                if not is_mod(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
		                chat_kick(msg.chat_id_, msg.sender_user_id_)
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
						local bhash =  'bot:banned:'..msg.chat_id_
                        database:sadd(bhash, user_id)
                           send(msg.chat_id_, msg.id_, 1, '● - `الايدي` 📍: *'..msg.sender_user_id_..'* \n`قمت بعمل تكرار للرسائل المحدده` ⚠️\n`وتم حظرك من المجموعه` ❌', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	
	local hash = 'flood:max:warn'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_mod(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:warn'..msg.chat_id_
        if not database:get(hashse) then
                if not is_mod(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
						local bhash =  'bot:muted:'..msg.chat_id_
                        database:sadd(bhash, user_id)
                           send(msg.chat_id_, msg.id_, 1, '● - `الايدي` 📍: *'..msg.sender_user_id_..'* \n`قمت بعمل تكرار للرسائل المحدده` ⚠️\n`وتم كتمك في المجموعه` ❌', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	
	local hash = 'flood:max:del'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_mod(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:del'..msg.chat_id_
        if not database:get(hashse) then
                if not is_mod(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
                           send(msg.chat_id_, msg.id_, 1, '● - `الايدي` 📍: *'..msg.sender_user_id_..'* \n`قمت بعمل تكرار للرسائل المحدده` ⚠️\n`وتم مسح كل رسائلك` ❌', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	-------------------------------------------
	database:incr("bot:allmsgs")
	if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
        elseif id:match('^(%d+)') then
        if not database:sismember("bot:userss",msg.chat_id_) then
            database:sadd("bot:userss",msg.chat_id_)
        end
        else
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
     end
    end
	-------------------------------------------
    -------------* MSG TYPES *-----------------
   if msg.content_ then
   	if msg.reply_markup_ and  msg.reply_markup_.ID == "ReplyMarkupInlineKeyboard" then
		print("Send INLINE KEYBOARD")
	msg_type = 'MSG:Inline'
	-------------------------
    elseif msg.content_.ID == "MessageText" then
	text = msg.content_.text_
		print("SEND TEXT")
	msg_type = 'MSG:Text'
	-------------------------
	elseif msg.content_.ID == "MessagePhoto" then
	print("SEND PHOTO")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Photo'
	-------------------------
	elseif msg.content_.ID == "MessageChatAddMembers" then
	print("NEW ADD TO GROUP")
	msg_type = 'MSG:NewUserAdd'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" then
		print("JOIN TO GROUP")
	msg_type = 'MSG:NewUserLink'
	-------------------------
	elseif msg.content_.ID == "MessageSticker" then
		print("SEND STICKER")
	msg_type = 'MSG:Sticker'
	-------------------------
	elseif msg.content_.ID == "MessageAudio" then
		print("SEND MUSIC")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Audio'
	-------------------------
	elseif msg.content_.ID == "MessageVoice" then
		print("SEND VOICE")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Voice'
	-------------------------
	elseif msg.content_.ID == "MessageVideo" then
		print("SEND VIDEO")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Video'
	-------------------------
	elseif msg.content_.ID == "MessageAnimation" then
		print("SEND GIF")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Gif'
	-------------------------
	elseif msg.content_.ID == "MessageLocation" then
		print("SEND LOCATION")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Location'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" then
	msg_type = 'MSG:NewUser'
	-------------------------
	elseif msg.content_.ID == "MessageContact" then
		print("SEND CONTACT")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Contact'
	-------------------------
	end
   end
    -------------------------------------------
    -------------------------------------------
    if ((not d) and chat) then
      if msg.content_.ID == "MessageText" then
        do_notify (chat.title_, msg.content_.text_)
      else
        do_notify (chat.title_, msg.content_.ID)
      end
    end
  -----------------------------------------------------------------------------------------------
                                     -- end functions --
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
                                     -- start code --
  -----------------------------------------------------------------------------------------------
  -------------------------------------- Process mod --------------------------------------------
  -----------------------------------------------------------------------------------------------
  
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  --------------------------******** START MSG CHECKS ********-------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
if is_banned(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
          delete_msg(chat,msgs)
		  return 
end

if is_gbanned(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
          delete_msg(chat,msgs)
		  return 
end

if is_muted(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
          delete_msg(chat,msgs)
		  return 
end
if database:get('bot:muteall'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
        return 
end

if database:get('bot:muteallwarn'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الوسائط تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
        return 
end

if database:get('bot:muteallban'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الوسائط تم قفلها ممنوع ارسالها</code> ❌\n● - <code>تم طردك</code> ⚠️", 1, 'html')
        return 
end
    database:incr('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	database:incr('group:msgs'..msg.chat_id_)
if msg.content_.ID == "MessagePinMessage" then
  if database:get('pinnedmsg'..msg.chat_id_) and database:get('bot:pin:mute'..msg.chat_id_) then
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
    database:incr('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	database:incr('group:msgs'..msg.chat_id_)
if msg.content_.ID == "MessagePinMessage" then
  if database:get('pinnedmsg'..msg.chat_id_) and database:get('bot:pin:warn'..msg.chat_id_) then
   send(msg.chat_id_, msg.id_, 1, "● - `الايدي ` 📍: _"..msg.sender_user_id_.."_\n● - `المعرف ` 🚹 : "..get_info(msg.sender_user_id_).."\n● - `التثبيت مقفول لا تستطيع التثبيت حاليا` ⚠️", 1, 'md')
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
if database:get('bot:viewget'..msg.sender_user_id_) then 
    if not msg.forward_info_ then
		send(msg.chat_id_, msg.id_, 1, '● - `قم بارسال المنشور من القناة` ✔️', 1, 'md')
		database:del('bot:viewget'..msg.sender_user_id_)
	else
		send(msg.chat_id_, msg.id_, 1, '● - <code>عدد المشاهدات </code>: ↙️\n● - '..msg.views_..' ', 1, 'html')
        database:del('bot:viewget'..msg.sender_user_id_)
	end
end
if msg_type == 'MSG:Photo' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
     if database:get('bot:photo:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
      end
        if database:get('bot:photo:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
		   chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الصور تم قفلها ممنوع ارسالها</code> ❌\n● - <code>تم طردك</code> ⚠️", 1, 'html')

          return 
   end
        if database:get('bot:photo:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الصور تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
        if msg.content_.caption_ then
          check_filter_words(msg, msg.content_.caption_)
          if database:get('bot:links:mute'..msg.chat_id_) then
            if msg.content_.caption_:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt].[Mm][Ee]") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
        end
        end
end
   elseif msg.content_.ID == 'MessageDocument' then
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:document:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
      end
        if database:get('bot:document:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الملفات تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:document:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الملفات تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
   end

  elseif msg_type == 'MSG:MarkDown' then
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:markdown:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
      end
        if database:get('bot:markdown:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الماركدون تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:markdown:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الماركدون تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
 end
 
  elseif msg_type == 'MSG:Inline' then
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:inline:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:inline:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الانلاين تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:inline:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الانلاين تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
   end
  elseif msg_type == 'MSG:Sticker' then
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:sticker:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:sticker:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الملصقات تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:sticker:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الملصقات تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:NewUserLink' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   function get_welcome(extra,result,success)
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = 'Hi {firstname} 😃'
    end
    local text = text:gsub('{firstname}',(result.first_name_ or ''))
    local text = text:gsub('{lastname}',(result.last_name_ or ''))
    local text = text:gsub('{username}',(result.username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
	  if database:get("bot:welcome"..msg.chat_id_) then
        getUser(msg.sender_user_id_,get_welcome)
      end
elseif msg_type == 'MSG:NewUserAdd' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
      --vardump(msg)
   if msg.content_.members_[0].username_ and msg.content_.members_[0].username_:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
	  end
   end
   if is_banned(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
   end
   if database:get("bot:welcome"..msg.chat_id_) then
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = 'Hi {firstname} 😃'
    end
    local text = text:gsub('{firstname}',(msg.content_.members_[0].first_name_ or ''))
    local text = text:gsub('{lastname}',(msg.content_.members_[0].last_name_ or ''))
    local text = text:gsub('{username}',('@'..msg.content_.members_[0].username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
elseif msg_type == 'MSG:Contact' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:contact:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:contact:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>جهات الاتصال تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:contact:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>جهات الاتصال تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Audio' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:music:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:music:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الاغاني تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:music:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الاغاني تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Voice' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:voice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:voice:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الصوتيات تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:voice:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الصوتيات تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Location' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:location:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:location:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الشبكات تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:location:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الشبكات تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Video' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:video:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:video:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الفيديوهات تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:video:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "<code>ايديك : </code><i>"..msg.sender_user_id_.."</i>\n<code>الفيديوهات تم قفلها ممنوع ارسالها</code>", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Gif' then
 if not is_mod(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:gifs:mute'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:gifs:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الصور المتحركه تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:gifs:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الصور المتحركه تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Text' then
 --vardump(msg)
    if database:get("bot:group:link"..msg.chat_id_) == 'Waiting For Link!\nPls Send Group Link' and is_mod(msg.sender_user_id_, msg.chat_id_) then if text:match("(https://telegram.me/joinchat/%S+)") or text:match("(https://t.me/joinchat/%S+)") then 	 local glink = text:match("(https://telegram.me/joinchat/%S+)") or text:match("(https://t.me/joinchat/%S+)") local hash = "bot:group:link"..msg.chat_id_ database:set(hash,glink) 			 send(msg.chat_id_, msg.id_, 1, '*New link Set!*', 1, 'md') send(msg.chat_id_, 0, 1, '<b>New Group link:</b>\n'..glink, 1, 'html')
      end
   end
    function check_username(extra,result,success)
	 --vardump(result)
	local username = (result.username_ or '')
	local svuser = 'user:'..result.id_
	if username then
      database:hset(svuser, 'username', username)
    end
	if username and username:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(result.id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, result.id_)
		 return false
		 end
	  end
   end
    getUser(msg.sender_user_id_,check_username)
   database:set('bot:editid'.. msg.id_,msg.content_.text_)
   if not is_mod(msg.sender_user_id_, msg.chat_id_) then
    check_filter_words(msg, text)
	if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or 
text:match("[Tt].[Mm][Ee]") or
text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
     if database:get('bot:links:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
       if database:get('bot:links:ban'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الروابط تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
  end
       if database:get('bot:links:warn'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الروابط تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
	end
 end

            if text then
              local _nl, ctrl_chars = string.gsub(text, '%c', '')
              local _nl, real_digits = string.gsub(text, '%d', '')
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              local hash = 'bot:sens:spam'..msg.chat_id_
              if not database:get(hash) then
                sens = 300
              else
                sens = tonumber(database:get(hash))
              end
              if database:get('bot:spam:mute'..msg.chat_id_) and string.len(text) > (sens) or ctrl_chars > (sens) or real_digits > (sens) then
                delete_msg(chat,msgs)
              end
          end 
          
            if text then
              local _nl, ctrl_chars = string.gsub(text, '%c', '')
              local _nl, real_digits = string.gsub(text, '%d', '')
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              local hash = 'bot:sens:spam:warn'..msg.chat_id_
              if not database:get(hash) then
                sens = 300
              else
                sens = tonumber(database:get(hash))
              end
              if database:get('bot:spam:warn'..msg.chat_id_) and string.len(text) > (sens) or ctrl_chars > (sens) or real_digits > (sens) then
                delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الكلايش تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
              end
          end 

	if text then
     if database:get('bot:text:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:text:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الدردشه تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:text:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الدردشه تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
end
end
if msg.forward_info_ then
if database:get('bot:forward:ban'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
		                chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>التوجيه تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
	end
   end

if msg.forward_info_ then
if database:get('bot:forward:warn'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>التوجيه تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
	end
   end
end
elseif msg_type == 'MSG:Text' then
   if text:match("@") or msg.content_.entities_[0] and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:tag:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>المعرفات <@> تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:tag:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>المعرفات <@> تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
 end
   	if text:match("#") then
      if database:get('bot:hashtag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:hashtag:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>التاكات <#> تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:hashtag:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>التاكات <#> تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
end

   	if text:match("/") then
      if database:get('bot:cmd:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end 
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
      if database:get('bot:cmd:ban'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الشارحه </> تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
	end 
	      if database:get('bot:cmd:warn'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>الشارحه </> تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
	end 
	end
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
      if database:get('bot:webpage:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:webpage:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>المواقع تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:webpage:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>المواقع تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
 end
   	if text:match("[\216-\219][\128-\191]") then
      if database:get('bot:arabic:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:arabic:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>اللغه العربيه تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:arabic:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>اللغه العربيه تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
 end
   	  if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
      if database:get('bot:english:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	  end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
	          if database:get('bot:english:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>اللغه الانكليزيه تم قفلها ممنوع ارسالها</code> ⚠️\n● - <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:english:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "● - <code>الايدي 📍 : </code><i>"..msg.sender_user_id_.."</i>\n● - <code>اللغه الانكليزيه تم قفلها ممنوع ارسالها</code> ⚠️❌", 1, 'html')
          return 
   end
     end
    end
   end
  if database:get('bot:cmds'..msg.chat_id_) and not is_mod(msg.sender_user_id_, msg.chat_id_) then
  return 
else
  
if text == 'هلو' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• هَٰہۧـﮧﮧلْٰاَٰوٍّ໑اَٰتّٰ 🌝☄ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end

if text == 'تشاكي' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• نٍٰـعٍِّـﮧﮧمٍٰ تّٰفِٰـہضلْٰ 🍁🌛ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شلونكم' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• تّٰمٍٰـﮧاَٰمٍٰ وٍّاَٰنٍٰتّٰـہهَٰہۧ 😽⚡️ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شلونك' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• اَٰلْٰـحٌٰمٍٰـﮧﮧدِٰاَٰلْٰلْٰهَٰہۧ وٍّ୭اَٰنٍٰتّٰـهَٰہۧ 😼💛ֆ"
else
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تمام' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• دِٰوٍّ൭مٍٰ يَٰـﮧﮧاَٰرِٰبٌِٰ 😻🌪ֆ"
else
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'هلاو' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• هَٰہۧـہ୪وٍّ୭اَٰتّٰ حٌٰبٌِٰـﮧيَٰ 🤗🌟ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😐' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• شَُـبٌِٰيَٰـكٍٰ صُِـﮧﮧاَٰفِٰنٍٰ عٍِّ خّٰاَٰلْٰتّٰـہكٍٰ😹🖤ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'هاي' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• هَٰہۧـاَٰيَٰـﮧﮧاَٰتّٰ يَٰـرِٰوٍّحٌٰـہيَٰ 🙋🏼‍♂💙ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'بوت' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• تّٰفِٰـضـﮧلْٰ حٌٰبٌِٰـہيَٰ 🌚💫ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اريد اكبل' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• شَُـوٍّ໑فِٰلْٰيَٰ وٍّيَٰـاَٰكٍٰ حٌٰدِٰيَٰـہقٍٰهَٰہۧ وٍّدِٰاَٰيَٰـﮧحٌٰ رِٰسٌٍمٍٰـہيَٰ😾😹💜ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'لتزحف' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• دِٰعٍِّـوٍّ໑فِٰهَٰہۧ زًَاَٰحٌٰـﮧفِٰ عٍِّ خّٰاَٰلْٰـتّٰكٍٰ خّٰـلْٰيَٰ يَٰسٌٍـہتّٰفِٰاَٰدِٰ😾🌈ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'كلخرا' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• خّٰـﮧرِٰاَٰ يَٰتّٰـہرِٰسٌٍ حٌٰلْٰكٍٰـﮧكٍٰ يَٰاَٰخّٰـﮧرِٰاَٰاَٰ💩ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'زاحف' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• زًَاَٰحٌٰـﮧفِٰ عٍِّ اَٰخّٰتّٰـﮧكٍٰ؟ كٍٰضيَٰـﮧتّٰ عٍِّمٍٰرِٰكٍٰ جًِّرِٰجًِّـﮧفِٰ😾😹ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'دي' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• خّٰلْٰيَٰنٍٰـﮧيَٰ اَٰحٌٰبٌِٰـﮧكٍٰ 😾ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'فرخ' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• وٍّيَٰنٍٰـﮧهَٰہۧ؟ خّٰ اَٰحٌٰضـﮧرِٰهَٰہۧ 😾😹ֆ"
else
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تعالي خاص' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• اَٰهَٰہۧـﮧوٍّ໑ ضـﮧلْٰ ضـﮧلْٰ سٌٍـﮧاَٰحٌٰفِٰ كٍٰبٌِٰـﮧرِٰ طَُِمٍٰـہكٍٰ😗😂💚ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اكرهك' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "•دِٰيَٰلْٰـﮧهَٰہۧ شَُـﮧوٍّ୭نٍٰ اَٰطَُِيَٰـقٍٰكٍٰ نٍٰـيَٰ 🙎🏼‍♂🖤ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'احبك' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "•حٌٰبٌِٰيَٰبٌِٰـﮧيَٰ وٍّنٍٰـﮧيَٰ هَٰہۧــمٍٰ😻👅ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'باي' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• وٍّيَٰـﮧنٍٰ رِٰاَٰيَٰـہحٌٰ خّٰلْٰيَٰنٍٰـﮧهَٰہۧ مٍٰتّٰوٍّنٍٰسٌٍيَٰـﮧنٍٰ🙁💔ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'واكف' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• بٌِٰنٍٰلْٰخّٰـﮧرِٰاَٰ وٍّيَٰـﮧنٍٰ وٍّاَٰكٍٰـﮧفِٰ😐😒ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'وين المدير' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• لْٰيَٰـﮧشَُ شَُتّٰـﮧرِٰيَٰدِٰ🤔ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'انجب' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• صُِـﮧاَٰرِٰ سٌٍتّٰـﮧاَٰدِٰيَٰ🐸❤️ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تحبني' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• مٍٰـﮧاَٰدِٰرِٰيَٰ اَٰفِٰكٍٰـﮧرِٰ🙁😹ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🌚' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• فِٰـﮧدِٰيَٰتّٰ صُِخّٰـﮧاَٰمٍٰكٍٰ🙊👄ֆ "
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🙄' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• نٍٰـہزًَلْٰ عٍِّيَٰـنٍٰكٍٰ عٍِّيَٰـﮧبٌِٰ🌚😹ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😒' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• شَُبٌِٰيَٰـﮧكٍٰ كٍٰاَٰلْٰـﮧبٌِٰ خّٰلْٰقٍٰتّٰـﮧكٍٰ😟🐈ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😳' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• هَٰہۧـاَٰ بٌِٰسٌٍ لْٰاَٰ شَُفِٰـﮧتّٰ عٍِّمٍٰتّٰـﮧكٍٰ اَٰلْٰعٍِّـﮧوٍّ໑بٌِٰهَٰہۧ😐😹ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🙁' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• تّٰعٍِّـﮧاَٰلْٰ اَٰشَُكٍٰيَٰلْٰـﮧيَٰ هَٰہۧمٍٰوٍّمٍٰـﮧكٍٰ لْٰيَٰـشَُ • ضاَٰيَٰـﮧجًِّ🙁💔ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🚶💔' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• تّٰعٍِّـﮧاَٰلْٰ اَٰشَُكٍٰيَٰلْٰـﮧيَٰ هَٰہۧمٍٰوٍّمٍٰـﮧكٍٰ لْٰيَٰـشَُ • ضاَٰيَٰـﮧجًِّ🙁💔ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🙂' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• ثِْْكٍٰيَٰـﮧلْٰ نٍٰهَٰہۧنٍٰهَٰہۧنٍٰهَٰہۧنٍٰهَٰہۧ🐛ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🌝' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• مٍٰنٍٰـﮧوٍّ໑رِٰ حٌٰبٌِٰـعٍِّمٍٰـہرِٰيَٰ😽💚ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'صباحو' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• صُِبٌِٰاَٰحٌٰـہكٍٰ عٍِّسٌٍـہلْٰ يَٰعٍِّسٌٍـﮧلْٰ😼🤞ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'صباح الخير' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• صُِبٌِٰاَٰحٌٰـہكٍٰ عٍِّسٌٍـہلْٰ يَٰعٍِّسٌٍـﮧلْٰ😼🤞ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'كفو' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• اَٰهَٰہۧ كٍٰفِٰـﮧوٍّ໑ يَٰبٌِٰہوٍّ୭ اَٰلْٰضـلْٰہوٍّ୭عٍِّ🙀😹ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😌' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• اَٰلْٰمٍٰطَُِلْٰـﮧوٍّ໑بٌِٰ !😕💞ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اها' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• يَٰبٌِٰ قٍٰاَٰبٌِٰـﮧلْٰ اَٰغِِٰشَُـﮧكٍٰ شَُسٌٍاَٰلْٰفِٰـﮧهَٰہۧ حٌٰبٌِٰ😐🌝ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شسمج' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• اَٰسٌٍـمٍٰهَٰہۧـﮧاَٰ جًِّعٍِّجًِّـﮧوٍّ໑عٍِّهَٰہۧ😹👊ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شسمك' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• اَٰسٌٍمٍٰـﮧهَٰہۧ عٍِّبٌِٰـﮧوٍّ໑سٌٍيَٰ لْٰـوٍّ૭سٌٍہيَٰ😾😹💛ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شوف' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• شَُشَُـﮧﮧوٍّ໑فِٰ 🌝🌝ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'مساء الخير' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• مٍٰسٌٍـﮧاَٰء اَٰلْٰحٌٰـﮧبٌِٰ يَٰحٌٰہبٌِٰحٌٰہبٌِٰ🌛🔥ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'المدرسه' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• لْٰتّٰجًِّيَٰـﮧبٌِٰ اَٰسٌٍمٍٰـﮧهَٰہۧ لْٰاَٰ اَٰطَُِـﮧرِٰدِٰكٍٰ🌞✨ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'منو ديحذف رسائلي' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• خّٰـﮧاَٰلْٰتّٰـہكٍٰ 🌚ֆ🌝"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'البوت واكف' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• لْٰجًِّـﮧذَْبٌِٰ حٌٰبٌِٰـہيَٰ 🌞⚡️ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'غلس' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• وٍّ໑كٍٰ بٌِٰـﮧسٌٍ سٌٍـﮧوٍّ୭لْٰفِٰلْٰيَٰ اَٰلْٰسٌٍـﮧاَٰلْٰفِٰهَٰہۧ بٌِٰعٍِّـﮧدِٰيَٰنٍٰ🌝🦅ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'حارة' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• تّٰسٌٍـہمٍٰطَُِ سٌٍمٍٰـﮧطَُِ غِِٰيَٰـﮧرِٰ يَٰرِٰحٌٰمٍٰنٍٰـﮧهَٰہۧ اَٰلْٰاَٰعٍِّبٌِٰـاَٰدِٰيَٰ وٍّيَٰنٍٰـہطَُِيَٰ عٍِّطَُِلْٰـﮧهَٰہۧ 😾💔ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'هههه' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• نٍٰشَُـﮧاَٰلْٰلْٰهَٰہۧ دِٰاَٰيَٰمٍٰـﮧهَٰہۧ💆🏻‍♂💘ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ههههه' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• نٍٰشَُـﮧاَٰلْٰلْٰهَٰہۧ دِٰاَٰيَٰمٍٰـﮧهَٰہۧ💆🏻‍♂💘ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😹' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• نٍٰشَُـﮧاَٰلْٰلْٰهَٰہۧ دِٰاَٰيَٰمٍٰـﮧهَٰہۧ💆🏻‍♂💘ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'وين' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• بٌِٰـﮧﮧأرِٰض اَٰلْٰلْٰهَٰہۧ اَٰلْٰـہوٍّاَٰسٌٍعٍِّـﮧهَٰہۧ😽💜ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'كافي لغوة' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• كٍٰـيَٰفِٰنٍٰـﮧهَٰہۧ نٍٰتّٰـﮧهَٰہۧ شَُعٍِّـہلْٰيَٰكٍٰ😼👊ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'نايمين' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• اَٰنٍٰـﮧيَٰ سٌٍهَٰہۧـہرِٰاَٰنٍٰ اَٰحٌٰرِٰسٌٍـﮧكٍٰمٍٰ مٍٰـﮧטּ تّٰـرِٰاَٰمٍٰـﮧبٌِٰ😿😹🙌ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اكو احد' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• يَٰ عٍِّيَٰـنٍٰـﮧيَٰ اَٰنٍٰـہيَٰ مٍٰـوٍّ૭جًِّـﮧوٍّدِٰ🌝✨ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'فديت' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "•فِٰـﮧﮧدِٰاَٰكٍٰ/جًِّ ثِْْـﮧوٍّ୪لْٰاَٰنٍٰ اَٰلْٰكٍٰـرِٰوٍّ୭بٌِٰ😟😂💚ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شكو' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• كٍٰلْٰـشَُـﮧﮧيَٰ مٍٰـہاَٰكٍٰـﮧوٍّ اَٰرِٰجًِّـعٍِّ نٍٰـاَٰمٍٰ🐼🌩ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اوف' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• هَٰہۧـﮧﮧاَٰيَٰ اَٰوٍّفِٰ مٍٰنٍٰ يَٰـاَٰ نٍٰـوٍّ୭عٍِّ صُِـاَٰرِٰتّٰ اَٰلْٰـسٌٍاَٰلْٰفِٰهَٰہۧ مٍٰتّٰـنٍٰعٍِّرِٰفِٰ🌚🌙ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'احبج' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "•جًِّـﮧذَْاَٰبٌِٰ يَٰـرِٰيَٰدِٰ يَٰطَُِـہكٍٰجًِّ😹🌞⚡️ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'انتة منو' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = "• اَٰنٍٰـﮧﮧيَٰ بٌِٰـوٍّ໑تّٰ💨🌝ֆ"
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end

    ------------------------------------ With Pattern -------------------------------------------
	if text:match("^[Ll][Ee][Aa][Vv][Ee]$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	     chat_leave(msg.chat_id_, bot_id)
    end
    
	if text:match("^مغادره$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	     chat_leave(msg.chat_id_, bot_id)
    end
	-----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('رفع ادمن','setmote')
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee]$")  and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function promote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already moderator._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `بالفعل تم رفعه ادمن` ☑️', 1, 'md')
              end
            else
         database:sadd(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _promoted as moderator._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `تم رفعه ادمن` ☑️', 1, 'md')
              end
	end 
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Mm][Oo][Tt][Ee]) @(.*)$")} 
	function promote_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:mods:'..msg.chat_id_, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User '..result.id_..' promoted as moderator.!</code>'
          else
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم رفعه ادمن</code> ☑️'
            end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],promote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Mm][Oo][Tt][Ee]) (%d+)$")} 	
	        database:sadd('bot:mods:'..msg.chat_id_, apmd[2])
          if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _promoted as moderator._', 1, 'md')
          else
   send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..apmd[2]..'* `تم رفعه ادمن` ☑️', 1, 'md')
          end
    end
	-----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('تنزيل ادمن','remmote')
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function demote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Promoted._', 1, 'md')
              else
send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `بالفعل تم تنزيله من الادمنيه` ⚠️', 1, 'md')
              end
	else
         database:srem(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then

         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Demoted._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `تم تنزيله من الادمنيه` ⚠️', 1, 'md')
	end
  end
  end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Mm][Oo][Tt][Ee]) @(.*)$")} 
	function demote_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Demoted</b>'
          else 
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم تنزيله من الادمنيه</code> ⚠️'
    end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>⚠️'
        end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],demote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Mm][Oo][Tt][Ee]) (%d+)$")} 	
         database:srem(hash, apmd[2])
              if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _Demoted._', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..apmd[2]..'* `تم تنزيله من الادمنيه` ⚠️', 1, 'md')
  end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('حظر','Ban')
	if text:match("^[Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function ban_by_reply(extra, result, success)
	local hash = 'bot:banned:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '● - لا تستطيع حظر الادمنيه والمدراء ⚠️❌', 1, 'md')
end
    else
    if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Banned._', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `بالفعل تم حظره` ⚠️', 1, 'md')
end
		 chat_kick(result.chat_id_, result.sender_user_id_)
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Banned._', 1, 'md')
       else
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `تم حظره` ⚠️', 1, 'md')
end
		 chat_kick(result.chat_id_, result.sender_user_id_)
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,ban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Bb][Aa][Nn]) @(.*)$")} 
	function ban_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '● - لا تستطيع حظر الادمنيه والمدراء ⚠️❌', 1, 'md')
end
    else
	        database:sadd('bot:banned:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Banned.!</b>'
else
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم حظره</code> ⚠️'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apba[2],ban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Bb][Aa][Nn]) (%d+)$")}
	if is_mod(apba[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '● - لا تستطيع حظر الادمنيه والمدراء ⚠️❌', 1, 'md')
end
    else
	        database:sadd('bot:banned:'..msg.chat_id_, apba[2])
		 chat_kick(msg.chat_id_, apba[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apba[2]..'* _Banned._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..apba[2]..'* `تم حظره` ⚠️', 1, 'md')
  	end
	end
end
  ----------------------------------------------unban--------------------------------------------
          local text = msg.content_.text_:gsub('الغاء حظر','unban')
  	if text:match("^[Uu][Nn][Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unban_by_reply(extra, result, success) 
	local hash = 'bot:banned:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Banned._', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `بالفعل تم الغاء حظره` ☑️', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Unbanned._', 1, 'md')
       else
   send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `تم الغاء حظره` ☑️', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Bb][Aa][Nn] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn]) @(.*)$")} 
	function unban_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:banned:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Unbanned.!</b>'
      else
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم الغاء حظره</code> ☑️'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apba[2],unban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Bb][Aa][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn]) (%d+)$")} 	
	        database:srem('bot:banned:'..msg.chat_id_, apba[2])
        if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apba[2]..'* _Unbanned._', 1, 'md')
else
   send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..apba[2]..'* `تم الغاء حظره` ☑️', 1, 'md')
end
  end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('حذف الكل','delall')
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function delall_by_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, '● - لا تستطيع حذف رسائل الادمنيه والمدراء ⚠️❌', 1, 'md')
end
else
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_All Msgs from _ *'..result.sender_user_id_..'* _Has been deleted!!_', 1, 'md')
       else
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `تم حذف كل رسائله` ⚠️', 1, 'md')
end
		     del_all_msgs(result.chat_id_, result.sender_user_id_)
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,delall_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
		local ass = {string.match(text, "^([Dd][Ee][Ll][Aa][Ll][Ll]) (%d+)$")} 
	if is_mod(ass[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, '● - لا تستطيع حذف رسائل الادمنيه والمدراء ⚠️❌', 1, 'md')
end
else
	 		     del_all_msgs(msg.chat_id_, ass[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_All Msgs from _ *'..ass[2]..'* _Has been deleted!!_', 1, 'md')
       else
         send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..ass[2]..'* `تم حذف كل رسائله` ⚠️', 1, 'md')
end    end
	end
 -----------------------------------------------------------------------------------------------
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apbll = {string.match(text, "^([Dd][Ee][Ll][Aa][Ll][Ll]) @(.*)$")} 
	function delall_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, '● - لا تستطيع حذف رسائل الادمنيه والمدراء ⚠️❌', 1, 'md')
end
return false
    end
		 		     del_all_msgs(msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>All Msg From user</b> <code>'..result.id_..'</code> <b>Deleted!</b>'
          else 
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم حذف كل رسائله</code> ⚠️'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apbll[2],delall_by_username)
    end
  -----------------------------------------banall--------------------------------------------------
          local text = msg.content_.text_:gsub('حظر عام','banall')
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll]$") and is_sudo(msg) and msg.reply_to_message_id_ then
            function gban_by_reply(extra, result, success)
              local hash = 'bot:gbanned:'
	if is_admin(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '● - لا تستطيع حظر ادمنيه البوت والمطورين عام ⚠️❌', 1, 'md')
end
    else
              database:sadd(hash, result.sender_user_id_)
              chat_kick(result.chat_id_, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User :</b> '..result.sender_user_id_..' <b>Has been Globally Banned !</b>'
                else
                  texts = '● - <code>العضو </code>'..result.sender_user_id_..'<code> تم حظره عام</code> ⚠️'
end
end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,gban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$") and is_sudo(msg) then
            local apbll = {string.match(text, "^([Bb][Aa][Nn][Aa][Ll][Ll]) @(.*)$")}
            function gban_by_username(extra, result, success)
              if result.id_ then
         	if is_admin(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
            send(msg.chat_id_, msg.id_, 1, '● - لا تستطيع حظر ادمنيه البوت والمطورين عام ⚠️❌', 1, 'md')
end
  else
              local hash = 'bot:gbanned:'
                if database:get('lang:gp:'..msg.chat_id_) then
                texts = '<b>User :</b> <code>'..result.id_..'</code> <b> Has been Globally Banned !</b>'
              else 
                texts = '● - <code>العضو </code>'..result.id_..'<code> تم حظره عام</code> ⚠️'
end
                database:sadd(hash, result.id_)
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User not found!</b>'
                else
                  texts = '<code>خطا </code>⚠️'
                end
            end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            resolve_username(apbll[2],gban_by_username)
          end
          
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$") and is_sudo(msg) then
            local apbll = {string.match(text, "^([Bb][Aa][Nn][Aa][Ll][Ll]) (%d+)$")}
  local hash = 'bot:gbanned:'
	if is_admin(apbll[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
            send(msg.chat_id_, msg.id_, 1, '● - لا تستطيع حظر ادمنيه البوت والمطورين عام ⚠️❌', 1, 'md')
end
    else
	        database:sadd(hash, apbll[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apbll[2]..'* _Has been Globally Banned _', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..apbll[2]..'* `تم حظره عام` ⚠️', 1, 'md')
  	end
	end
end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('الغاء العام','unbanall')
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]$") and is_sudo(msg) and msg.reply_to_message_id_ then
            function ungban_by_reply(extra, result, success)
              local hash = 'bot:gbanned:'
              if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User :</b> '..result.sender_user_id_..' <b>Has been Globally Unbanned !</b>'
             else
                  texts =  '● - <code>العضو '..result.sender_user_id_..' تم الغاء حظره من العام </code> ☑️'
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
              database:srem(hash, result.sender_user_id_)
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,ungban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$") and is_sudo(msg) then
            local apid = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]) @(.*)$")}
            function ungban_by_username(extra, result, success)
              local hash = 'bot:gbanned:'
              if result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                 texts = '<b>User :</b> '..result.id_..' <b>Has been Globally Unbanned !</b>'
                else
                texts = '● - <code>العضو </code>'..result.id_..'<code> تم الغاء حظره من العام</code> ☑️'
                end
                database:srem(hash, result.id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User not found!</b>'
                else 
                  texts = '<code>خطا </code>⚠️'
                        end
              end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            resolve_username(apid[2],ungban_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$") and is_sudo(msg) then
            local apbll = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]) (%d+)$")}
            local hash = 'bot:gbanned:'
              database:srem(hash, apbll[2])
              if database:get('lang:gp:'..msg.chat_id_) then
              texts = '<b>User :</b> '..apbll[2]..' <b>Has been Globally Unbanned !</b>'
            else 
                texts = '● - <code>العضو </code>'..apbll[2]..'<code> تم الغاء حظره من العام</code> ☑️'
end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('كتم','silent')
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function mute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '● - `لا تستطيع كتم الادمنيه والمدراء` ⚠️❌', 1, 'md')
end
    else
    if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already silent._', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `بالفعل تم كتمه` ⚠️', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _silent_', 1, 'md')
       else 
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `تم كتمه` ⚠️', 1, 'md')
end
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,mute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Ss][Ii][Ll][Ee][Nn][Tt]) @(.*)$")} 
	function mute_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '● - `لا تستطيع كتم الادمنيه والمدراء` ⚠️❌', 1, 'md')
end
    else
	        database:sadd('bot:muted:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>silent</b>'
          else 
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم كتمه</code> ⚠️'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apsi[2],mute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Ss][Ii][Ll][Ee][Nn][Tt]) (%d+)$")}
	if is_mod(apsi[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '● - `لا تستطيع كتم الادمنيه والمدراء` ⚠️❌', 1, 'md')
end
    else
	        database:sadd('bot:muted:'..msg.chat_id_, apsi[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apsi[2]..'* _silent_', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..apsi[2]..'* `تم كتمه` ⚠️', 1, 'md')
end
	end
    end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('الغاء كتم','unsilent')
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unmute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not silent._', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `بالفعل تم الغاء كتمه` ☑️', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _unsilent_', 1, 'md')
       else 
   send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `تم الغاء كتمه` ☑️', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unmute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]) @(.*)$")} 
	function unmute_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:muted:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>unsilent.!</b>'
          else 
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم الغاء كتمه</code> ☑️'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apsi[2],unmute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]) (%d+)$")} 	
	        database:srem('bot:muted:'..msg.chat_id_, apsi[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apsi[2]..'* _unsilent_', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..apsi[2]..'* `تم الغاء كتمه` ☑️', 1, 'md')
end
  end
    -----------------------------------------------------------------------------------------------
    local text = msg.content_.text_:gsub('طرد','kick')
  if text:match("^[Kk][Ii][Cc][Kk]$") and msg.reply_to_message_id_ and is_mod(msg.sender_user_id_, msg.chat_id_) then
      function kick_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '● - `لا تستطيع طرد الادمنيه والمدراء` ⚠️❌', 1, 'md')
end
  else
                if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*User* _'..result.sender_user_id_..'_ *Kicked.*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, '● - `العضو` '..result.sender_user_id_..' `تم طرده` ⚠️', 1, 'md')
end
        chat_kick(result.chat_id_, result.sender_user_id_)
        end
	end
   getMessage(msg.chat_id_,msg.reply_to_message_id_,kick_reply)
  end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Kk][Ii][Cc][Kk] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apki = {string.match(text, "^([Kk][Ii][Cc][Kk]) @(.*)$")} 
	function kick_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '● - لا تستطيع طرد الادمنيه والمدراء ⚠️❌', 1, 'md')
end
    else
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Kicked.!</b>'
else
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم طرده</code> ⚠️'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apki[2],kick_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Kk][Ii][Cc][Kk] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apki = {string.match(text, "^([Kk][Ii][Cc][Kk]) (%d+)$")}
	if is_mod(apki[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '● - لا تستطيع طرد الادمنيه والمدراء ⚠️❌', 1, 'md')
end
    else
		 chat_kick(msg.chat_id_, apki[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apki[2]..'* _Kicked._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..apki[2]..'* `تم طرده` ⚠️', 1, 'md')
  	end
	end
end
          -----------------------------------------------------------------------------------------------
 local text = msg.content_.text_:gsub('اضافه','invite')
   if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee]$") and msg.reply_to_message_id_ ~= 0 and is_sudo(msg) then
   function inv_reply(extra, result, success)
    add_user(result.chat_id_, result.sender_user_id_, 5)
                if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*User* _'..result.sender_user_id_..'_ *Add it.*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, '● - `العضو` '..result.sender_user_id_..' `تم اضافته للمجموعه` ☑️', 1, 'md')
   end
   end
    getMessage(msg.chat_id_, msg.reply_to_message_id_,inv_reply)
   end
          -----------------------------------------------------------------------------------------------
   if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee] @(.*)$") and is_sudo(msg) then
    local apss = {string.match(text, "^([Ii][Nn][Vv][Ii][Tt][Ee]) @(.*)$")}
    function invite_by_username(extra, result, success)
     if result.id_ then
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Add it!</b>'
else
            texts = '● - <code>العضو </code>'..result.id_..'<code> تم اضافته للمجموعه</code> ☑️'
end
    add_user(msg.chat_id_, result.id_, 5)
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
            texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
    resolve_username(apss[2],invite_by_username)
 end
        -----------------------------------------------------------------------------------------------
    if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee] (%d+)$") and is_sudo(msg) then
      local apee = {string.match(text, "^([Ii][Nn][Vv][Ii][Tt][Ee]) (%d+)$")}
      add_user(msg.chat_id_, apee[2], 5)
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apee[2]..'* _Add it._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..apee[2]..'* `تم اضافته للمجموعه` ☑️', 1, 'md')
  	end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('رفع مدير','setowner')
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function setowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Owner._', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `بالفعل تم رفعه مدير` ☑️', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Promoted as Group Owner._', 1, 'md')
       else 
   send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `تم رفعه مدير` ☑️', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,setowner_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) @(.*)$")} 
	function setowner_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:owners:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Promoted as Group Owner.!</b>'
          else 
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم رفعه مدير</code> ☑️'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apow[2],setowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) (%d+)$")} 	
	        database:sadd('bot:owners:'..msg.chat_id_, apow[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apow[2]..'* _Promoted as Group Owner._', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..apow[2]..'* `تم رفعه مدير` ☑️', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('تنزيل مدير','remowner')
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function deowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Owner._', 1, 'md')
    else 
send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `بالفعل تم تنزيله من المدراء` ⚠️', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Removed from ownerlist._', 1, 'md')
       else 
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `تم تنزيله من المدراء` ⚠️', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deowner_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]) @(.*)$")} 
	local hash = 'bot:owners:'..msg.chat_id_
	function remowner_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Removed from ownerlist</b>'
     else 
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم تنزيله من المدراء</code> ⚠️'
end
          else 
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apow[2],remowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:owners:'..msg.chat_id_
	local apow = {string.match(text, "^([Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]) (%d+)$")} 	
         database:srem(hash, apow[2])
	     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apow[2]..'* _Removed from ownerlist._', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..apow[2]..'* `تم تنزيله من المدراء` ⚠️', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
	          local text = msg.content_.text_:gsub('رفع ادمن للبوت','setadmin')
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]$") and is_sudo(msg) and msg.reply_to_message_id_ then
	function addadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:' 
	if database:sismember(hash, result.sender_user_id_) then
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Admin._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `بالفعل تم رفعه ادمن للبوت` ☑️', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Added to admins._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `تم رفعه ادمن للبوت` ☑️', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,addadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] @(.*)$") and is_sudo(msg) then
	local ap = {string.match(text, "^([Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]) @(.*)$")} 
	function addadmin_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:admins:', result.id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Added to admins.!</b>'
          else 
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم رفعه ادمن للبوت</code> ☑️'
end
          else 
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],addadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] (%d+)$") and is_sudo(msg) then
	local ap = {string.match(text, "^([Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]) (%d+)$")} 	
	        database:sadd('bot:admins:', ap[2])
		     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..ap[2]..'* _Added to admins._', 1, 'md')
else 
  	send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..ap[2]..'* `تم رفعه ادمن للبوت` ☑️', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('تنزيل ادمن للبوت','remadmin')
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]$") and is_sudo(msg) and msg.reply_to_message_id_ then
	function deadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:'
	if not database:sismember(hash, result.sender_user_id_) then
		     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Admin._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `بالفعل تم تنزيله من ادمنيه البوت` ⚠️', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Removed from Admins!._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..result.sender_user_id_..'* `تم تنزيله من ادمنيه البوت` ⚠️', 1, 'md')

end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] @(.*)$") and is_sudo(msg) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^([Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]) @(.*)$")} 
	function remadmin_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Removed from Admins!</b>'
          else 
                        texts = '● - <code>العضو </code>'..result.id_..'<code> تم تنزيله من ادمنيه البوت</code> ⚠️'
end
          else 
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],remadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] (%d+)$") and is_sudo(msg) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^([Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]) (%d+)$")} 	
         database:srem(hash, ap[2])
		     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..ap[2]..'* Removed from Admins!_', 1, 'md')
else 
  	send(msg.chat_id_, msg.id_, 1, '● - `العضو` *'..ap[2]..'* `تم تنزيله من ادمنيه البوت` ⚠️', 1, 'md')
end
    end 
	-----------------------------------------------------------------------------------------------
	if text:match("^[Mm][Oo][Dd][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^الادمنيه$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:mods:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Mod List:</b>\n\n"
else 
  text = "● - <code>قائمه الادمنيه </code>⬇️ :\n\n"
  end
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Mod List is empty !</b>"
              else 
                text = "● - <code>لا يوجد ادمنيه</code> ⚠️"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
  end

	if text:match("^[Bb][Aa][Dd][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^قائمه المنع$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:filters:'..msg.chat_id_
      if hash then
         local names = database:hkeys(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>bad List:</b>\n\n"
else 
  text = "● - <code>قائمه الكلمات الممنوعه </code>⬇️ :\n\n"
  end    for i=1, #names do
      text = text..'> `'..names[i]..'`\n'
    end
	if #names == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>bad List is empty !</b>"
              else 
                text = "● - <code>لا يوجد كلمات ممنوعه</code> ⚠️"
end
    end
		  send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
       end 
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^المكتومين$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:muted:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Silent List:</b>\n\n"
else 
  text = "● - <code>قائمه المكتومين </code>⬇️ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Mod List is empty !</b>"
              else 
                text = "● - <code>لا يوجد مكتومين</code> ⚠️"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Oo][Ww][Nn][Ee][Rr][Ss]$") and is_sudo(msg) or text:match("^[Oo][Ww][Nn][Ee][Rr][Ll][Ii][Ss][Tt]$") and is_sudo(msg) or text:match("^المدراء$") and is_sudo(msg) then
    local hash =  'bot:owners:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>owner List:</b>\n\n"
else 
  text = "● - <code>قائمه المدراء </code>⬇️ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>owner List is empty !</b>"
              else 
                text = "● - <code>لا يوجد مدراء</code> ⚠️"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^المحظورين$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:banned:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>ban List:</b>\n\n"
else 
  text = "● - <code>قائمه المحظورين </code>⬇️ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>ban List is empty !</b>"
              else 
                text = "● - <code>لا يوجد محظورين</code> ⚠️"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

  if msg.content_.text_:match("^[Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and is_sudo(msg) or msg.content_.text_:match("^قائمه العام$") and is_sudo(msg) then
    local hash =  'bot:gbanned:'
    local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Gban List:</b>\n\n"
else 
  text = "● - <code>قائمه الحظر العام </code>⬇️ :\n\n"
end	
for k,v in pairs(list) do
    local user_info = database:hgetall('user:'..v)
    if user_info and user_info.username then
    local username = user_info.username
      text = text..k.." - @"..username.." ["..v.."]\n"
      else
      text = text..k.." - "..v.."\n"
          end
end
            if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Gban List is empty !</b>"
              else 
                text = "● - <code>لا يوجد محظورين عام</code> ⚠️"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Aa][Dd][Mm][Ii][Nn][Ll][Ii][Ss][Tt]$") and is_sudo(msg) or text:match("^ادمنيه البوت$") and is_sudo(msg) then
    local hash =  'bot:admins:'
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Admin List:</b>\n\n"
else 
  text = "● - <code>قائمه ادمنيه البوت </code>⬇️ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Admin List is empty !</b>"
              else 
                text = "● - <code>لا يوجد ادمنيه للبوت</code> ⚠️"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
    if text:match("^[Ii][Dd]$") or text:match("^ايدي$") and msg.reply_to_message_id_ ~= 0 then
      function id_by_reply(extra, result, success)
	  local user_msgs = database:get('user:msgs'..result.chat_id_..':'..result.sender_user_id_)
        send(msg.chat_id_, msg.id_, 1, "`"..result.sender_user_id_.."`", 1, 'md')
        end
   getMessage(msg.chat_id_, msg.reply_to_message_id_,id_by_reply)
  end
  -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ايدي','id')
    if text:match("^[Ii][Dd] @(.*)$") then
	local ap = {string.match(text, "^([Ii][Dd]) @(.*)$")} 
	function id_by_username(extra, result, success)
	if result.id_ then
            texts = '<code>'..result.id_..'</code>'
          else 
           if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
            texts = '<code>خطا </code> ⚠️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],id_by_username)
    end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('جلب صوره','getpro')
    if text:match("^getpro (%d+)$") and msg.reply_to_message_id_ == 0  then
		local pronumb = {string.match(text, "^(getpro) (%d+)$")} 
local function gpro(extra, result, success)
--vardump(result)
   if pronumb[2] == '1' then
   if result.photos_[0] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "● - `لا تملك صوره في حسابك` ⚠️", 1, 'md')
end
   end
   elseif pronumb[2] == '2' then
   if result.photos_[1] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[1].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 2 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "● - `لا تملك صوره 2 في حسابك` ⚠️", 1, 'md')
end
   end
   elseif pronumb[2] == '3' then
   if result.photos_[2] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[2].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 3 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "● - `لا تملك صوره 3 في حسابك` ⚠️", 1, 'md')
end
   end
   elseif pronumb[2] == '4' then
      if result.photos_[3] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[3].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 4 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "● - `لا تملك صوره 4 في حسابك` ⚠️", 1, 'md')
end
   end
   elseif pronumb[2] == '5' then
   if result.photos_[4] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[4].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 5 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "● - `لا تملك صوره 5 في حسابك` ⚠️", 1, 'md')
end
   end
   elseif pronumb[2] == '6' then
   if result.photos_[5] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[5].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 6 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "● - `لا تملك صوره 6 في حسابك` ⚠️", 1, 'md')
end
   end
   elseif pronumb[2] == '7' then
   if result.photos_[6] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[6].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 7 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "● - `لا تملك صوره 7 في حسابك` ⚠️", 1, 'md')
end
   end
   elseif pronumb[2] == '8' then
   if result.photos_[7] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[7].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 8 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "● - `لا تملك صوره 8 في حسابك` ⚠️", 1, 'md')
end
   end
   elseif pronumb[2] == '9' then
   if result.photos_[8] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[8].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 9 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "● - `لا تملك صوره 9 في حسابك` ⚠️", 1, 'md')
end
   end
   elseif pronumb[2] == '10' then
   if result.photos_[9] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[9].sizes_[1].photo_.persistent_id_)
   else
                     if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "_You Have'nt 10 Profile Photo!!_", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "● - `لا تملك صوره 10 في حسابك` ⚠️", 1, 'md')
end
   end
 else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "*I just can get last 10 profile photos!:(*", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "● - `لا استطيع جلب اكثر من 10 صور` ⚠️", 1, 'md')
end
   end
   end
   tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = pronumb[2]
  }, gpro, nil)
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('وضع تكرار بالطرد','flood ban')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Bb][Aa][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Bb][Aa][Nn]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
else
           send(msg.chat_id_, msg.id_, 1, '● - `ضع عدد من  *[2]* الى [_99999_]` ⚠️', 1, 'md')
end
	else
    database:set('flood:max:'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood has been set to_ *'..floodmax[2]..'*', 1, 'md')
        else
send(msg.chat_id_, msg.id_, 1, '● - `تم وضع التكرار بالطرد للعدد` ✓⬅️ : *'..floodmax[2]..'*', 1, 'md')
end
	end
end

          local text = msg.content_.text_:gsub('وضع تكرار بالكتم','flood mute')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Mm][Uu][Tt][Ee] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Mm][Uu][Tt][Ee]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, '● - `ضع عدد من  *[2]* الى [_99999_]` ⚠️', 1, 'md')
end
	else
    database:set('flood:max:warn'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood Warn has been set to_ *'..floodmax[2]..'*', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '● - `تم وضع التكرار بالكتم للعدد` ✓⬅️ : *'..floodmax[2]..'*', 1, 'md')
end
	end
end
          local text = msg.content_.text_:gsub('وضع تكرار بالمسح','flood del')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Dd][Ee][Ll] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Dd][Ee][Ll]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, '● - `ضع عدد من  *[2]* الى [_99999_]` ⚠️', 1, 'md')
end
	else
    database:set('flood:max:del'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood delete has been set to_ *'..floodmax[2]..'*', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '● - `تم وضع التكرار بالمسح للعدد` ✓⬅️ : *'..floodmax[2]..'*', 1, 'md')
end
	end
end
          local text = msg.content_.text_:gsub('وضع كلايش بالمسح','spam del')
if text:match("^[Ss][Pp][Aa][Mm] [Dd][Ee][Ll] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
local sensspam = {string.match(text, "^([Ss][Pp][Aa][Mm] [Dd][Ee][Ll]) (%d+)$")}
if tonumber(sensspam[2]) < 40 then
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [40-99999]_', 1, 'md')
else 
           send(msg.chat_id_, msg.id_, 1, '● - `ضع عدد من  *[40]* الى [_99999_]` ⚠️', 1, 'md')
end
 else
database:set('bot:sens:spam'..msg.chat_id_,sensspam[2])
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Spam has been set to_ *'..sensspam[2]..'*', 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, '● - `تم وضع الكليشه بالمسح للعدد` ✓⬅️ : *'..sensspam[2]..'*', 1, 'md')
end
end
end
          local text = msg.content_.text_:gsub('وضع كلايش بالتحذير','spam warn')
if text:match("^[Ss][Pp][Aa][Mm] [Ww][Aa][Rr][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
local sensspam = {string.match(text, "^([Ss][Pp][Aa][Mm] [Ww][Aa][Rr][Nn]) (%d+)$")}
if tonumber(sensspam[2]) < 40 then
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [40-99999]_', 1, 'md')
else 
           send(msg.chat_id_, msg.id_, 1, '● - `ضع عدد من  *[40]* الى [_99999_]` ⚠️', 1, 'md')
end
 else
database:set('bot:sens:spam:warn'..msg.chat_id_,sensspam[2])
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Spam Warn has been set to_ *'..sensspam[2]..'*', 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, '● - `تم وضع الكليشه بالتحذير للعدد` ✓⬅️ : *'..sensspam[2]..'*', 1, 'md')
end
end
end

	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('وضع زمن التكرار','flood time')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Tt][Ii][Mm][Ee] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local floodt = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Tt][Ii][Mm][Ee]) (%d+)$")} 
	if tonumber(floodt[2]) < 1 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, '● - `ضع عدد من  *[1]* الى [_99999_]` ⚠️', 1, 'md')
end
	else
    database:set('flood:time:'..msg.chat_id_,floodt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood has been set to_ *'..floodt[2]..'*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '● - `تم وضع زمن التكرار للعدد ` ✓⬅️ : *'..floodt[2]..'*', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Ll][Ii][Nn][Kk]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^وضع رابط$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         database:set("bot:group:link"..msg.chat_id_, 'Waiting For Link!\nPls Send Group Link')
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Please Send Group Link Now!*', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '● - `قم بارسال الرابط ليتم حفظه` 📤', 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ll][Ii][Nn][Kk]$") or text:match("^الرابط$") then
	local link = database:get("bot:group:link"..msg.chat_id_)
	  if link then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '<b>Group link:</b>\n'..link, 1, 'html')
       else 
                  send(msg.chat_id_, msg.id_, 1, '● - <code>رابط المجموعه ⬇️ :</code>\n'..link, 1, 'html')
end
	  else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*There is not link set yet. Please add one by #setlink .*', 1, 'md')
       else 
                  send(msg.chat_id_, msg.id_, 1, '● - `لم يتم حفظ رابط ارسل [ وضع رابط ] لحفظ رابط جديد` ⚠️', 1, 'md')
end
	  end
 	end
	
	if text:match("^[Ww][Ll][Cc] [Oo][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '#Done\nWelcome *Enabled* In This Supergroup.', 1, 'md')
		 database:set("bot:welcome"..msg.chat_id_,true)
	end
	if text:match("^[Ww][Ll][Cc] [Oo][Ff][Ff]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '#Done\nWelcome *Disabled* In This Supergroup.', 1, 'md')
		 database:del("bot:welcome"..msg.chat_id_)
	end
	
	if text:match("^تفعيل الترحيب$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '● - `تم تفعيل الترحيب ` ✔️', 1, 'md')
		 database:set("bot:welcome"..msg.chat_id_,true)
	end
	if text:match("^تعطيل الترحيب$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '● - `تم تعطيل الترحيب ` ⚠️', 1, 'md')
		 database:del("bot:welcome"..msg.chat_id_)
	end

	if text:match("^[Ss][Ee][Tt] [Ww][Ll][Cc] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local welcome = {string.match(text, "^([Ss][Ee][Tt] [Ww][Ll][Cc]) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, '*Welcome Msg Has Been Saved!*\nWlc Text:\n\n`'..welcome[2]..'`', 1, 'md')
		 database:set('welcome:'..msg.chat_id_,welcome[2])
	end
	
	if text:match("^وضع ترحيب (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local welcome = {string.match(text, "^(وضع ترحيب) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, '● - `تم وضع الترحيب` ✓⬇️ :\n\n`'..welcome[2]..'`', 1, 'md')
		 database:set('welcome:'..msg.chat_id_,welcome[2])
	end

          local text = msg.content_.text_:gsub('حذف الترحيب','del wlc')
	if text:match("^[Dd][Ee][Ll] [Ww][Ll][Cc]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Welcome Msg Has Been Deleted!*', 1, 'md')
       else 
                  send(msg.chat_id_, msg.id_, 1, '● - `تم حذف الترحيب` ⚠️❌', 1, 'md')
end
		 database:del('welcome:'..msg.chat_id_)
	end
	
          local text = msg.content_.text_:gsub('جلب الترحيب','get wlc')
	if text:match("^[Gg][Ee][Tt] [Ww][Ll][Cc]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local wel = database:get('welcome:'..msg.chat_id_)
	if wel then
         send(msg.chat_id_, msg.id_, 1, '● - `الترحيب ` ⬇️ :'..wel, 1, 'md')
    else 
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, 'Welcome msg not saved!', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '● - `لم يتم وضع ترحيب للمجموعه` ⚠️', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('منع','bad')
	if text:match("^[Bb][Aa][Dd] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local filters = {string.match(text, "^([Bb][Aa][Dd]) (.*)$")} 
    local name = string.sub(filters[2], 1, 50)
          database:hset('bot:filters:'..msg.chat_id_, name, 'filtered')
                if database:get('lang:gp:'..msg.chat_id_) then
		  send(msg.chat_id_, msg.id_, 1, "*New Word baded!*\n--> `"..name.."`", 1, 'md')
else 
  		  send(msg.chat_id_, msg.id_, 1, "● - `"..name.."` `تم اضافتها لقائمه المنع` ✔️", 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('الغاء منع','unbad')
	if text:match("^[Uu][Nn][Bb][Aa][Dd] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local rws = {string.match(text, "^([Uu][Nn][Bb][Aa][Dd]) (.*)$")} 
    local name = string.sub(rws[2], 1, 50)
          database:hdel('bot:filters:'..msg.chat_id_, rws[2])
                if database:get('lang:gp:'..msg.chat_id_) then
		  send(msg.chat_id_, msg.id_, 1, "`"..rws[2].."` *Removed From baded List!*", 1, 'md')
else 
  		  send(msg.chat_id_, msg.id_, 1, " ● - "..rws[2].."` تم حذفها من قائمه المنع` ❌⚠️", 1, 'md')
end
	end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('اذاعه','bc')
	if text:match("^bc (.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups") or 0
    local gpss = database:smembers("bot:groups") or 0
	local rws = {string.match(text, "^(bc) (.*)$")} 
	for i=1, #gpss do
		  send(gpss[i], 0, 1, rws[2], 1, 'md')
  end
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '*Done*\n_Your Msg Send to_ `'..gps..'` _Groups_', 1, 'md')
                   else
                     send(msg.chat_id_, msg.id_, 1, '● - `تم نشر الرساله في` `'..gps..'` `مجموعه` ✔️', 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Gg][Rr][Oo][Uu][Pp][Ss]$") and is_admin(msg.sender_user_id_, msg.chat_id_) or text:match("^الكروبات$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups")
	local users = database:scard("bot:userss")
    local allmgs = database:get("bot:allmsgs")
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '*Groups :* `'..gps..'`', 1, 'md')
                 else
                   send(msg.chat_id_, msg.id_, 1, '● - `عدد الكروبات هي ⬅️ :` *'..gps..'*', 1, 'md')
end
	end
	
if  text:match("^[Mm][Ss][Gg]$") or text:match("^رسائلي$") and msg.reply_to_message_id_ == 0  then
local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "*Msgs : * `"..user_msgs.."`", 1, 'md')
    else 
      send(msg.chat_id_, msg.id_, 1, "● - `عدد رسائلك هي ⬅️ :` *"..user_msgs.."*", 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^قفل (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local lockpt = {string.match(text, "^([Ll][Oo][Cc][Kk]) (.*)$")} 
	local TSHAKEPT = {string.match(text, "^(قفل) (.*)$")} 
    if lockpt[2] == "edit" or TSHAKEPT[2] == "التعديل" then
              if not database:get('editmsg'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "_> Edit Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل التعديل `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
                end
                database:set('editmsg'..msg.chat_id_,'delmsg')
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Lock edit is already_ *locked*', 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التعديل` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
                end
              end
            end
   if lockpt[2] == "bots" or TSHAKEPT[2] == "البوتات" then
              if not database:get('bot:bots:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "_> Bots Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل البوتات `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
                end
                database:set('bot:bots:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Bots is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل البوتات` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
                end
              end
            end
            	  if lockpt[2] == "flood ban" or TSHAKEPT[2] == "التكرار بالطرد" then
                if database:get('anti-flood:'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood ban* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `قفل التكرار `🔐\n\n● - `خاصية : الطرد `☑️', 1, 'md')
                  end
                database:del('anti-flood:'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood ban* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التكرار` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
                end
              end
            end
            	  if lockpt[2] == "flood mute" or TSHAKEPT[2] == "التكرار بالكتم" then
                if database:get('anti-flood:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood mute* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `قفل التكرار `🔐\n\n● - `خاصية : الكتم `☑️', 1, 'md')
                  end
                database:del('anti-flood:warn'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood mute* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التكرار` 🔐\n\n● - `خاصية : الكتم` ☑️', 1, 'md')
                end
              end
          end
            	  if lockpt[2] == "flood del" or TSHAKEPT[2] == "التكرار بالمسح" then
                if database:get('anti-flood:del'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood del* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `قفل التكرار `🔐\n\n● - `خاصية : المسح `☑️', 1, 'md')
                  end
                database:del('anti-flood:del'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood del* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التكرار` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
                end
              end
            end
        if lockpt[2] == "pin" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "التثبيت" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if not database:get('bot:pin:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Pin Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل التثبيت `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
                end
                database:set('bot:pin:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                            send(msg.chat_id_, msg.id_, 1, "_> Pin is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التثبيت` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
                end
              end
            end
        if lockpt[2] == "pin warn" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "التثبيت بالتحذير" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if not database:get('bot:pin:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Pin warn Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل التثبيت `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
                end
                database:set('bot:pin:warn'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                            send(msg.chat_id_, msg.id_, 1, "_> Pin warn is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التثبيت` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
                end
              end
            end
          end
          
	-----------------------------------------------------------------------------------------------
	
  	if text:match("^[Uu][Nn][Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^فتح (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unlockpt = {string.match(text, "^([Uu][Nn][Ll][Oo][Cc][Kk]) (.*)$")} 
	local TSHAKEUN = {string.match(text, "^(فتح) (.*)$")} 
                if unlockpt[2] == "edit" or TSHAKEUN[2] == "التعديل" then
              if database:get('editmsg'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Edit Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التعديل `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
                end
                database:del('editmsg'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Lock edit is already_ *Unlocked*', 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التعديل` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "bots" or TSHAKEUN[2] == "البوتات" then
              if database:get('bot:bots:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Bots Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح البوتات `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
                end
                database:del('bot:bots:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Bots is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح البوتات` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
                end
              end
            end
            	  if unlockpt[2] == "flood ban" or TSHAKEUN[2] == "التكرار بالطرد" then
                if not database:get('anti-flood:'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood ban* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التكرار `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
                  end
                   database:set('anti-flood:'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood ban* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التكرار` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
                end
              end
            end
            	  if unlockpt[2] == "flood mute" or TSHAKEUN[2] == "التكرار بالكتم" then
                if not database:get('anti-flood:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood mute* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التكرار `🔓\n\n● - `خاصية : الكتم `⚠️', 1, 'md')
                  end
                   database:set('anti-flood:warn'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood mute* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التكرار` 🔓\n\n● - `خاصية : الكتم` ⚠️', 1, 'md')
                end
              end
          end
            	  if unlockpt[2] == "flood del" or TSHAKEUN[2] == "التكرار بالمسح" then
                if not database:get('anti-flood:del'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood del* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التكرار `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
                  end
                   database:set('anti-flood:del'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood del* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التكرار` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "pin" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "التثبيت" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if database:get('bot:pin:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التثبيت `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
                end
                database:del('bot:pin:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التثبيت` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "pin warn" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "التثبيت بالتحذير" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if database:get('bot:pin:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin warn Has been_ *Unlocked*", 1, 'md')
                else
                send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التثبيت `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
                end
                database:del('bot:pin:warn'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin warn is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التثبيت` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
                end
              end
            end
              end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('قفل الكل بالثواني','lock all s')
  	if text:match("^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Ss] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Ss] (%d+)$")}
	    		database:setex('bot:muteall'..msg.chat_id_, tonumber(mutept[1]), true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Group muted for_ *'..mutept[1]..'* _seconds!_', 1, 'md')
       else 
              send(msg.chat_id_, msg.id_, 1, "`● - تم قفل كل الوسائط لمدة` "..mutept[1].." `ثانيه` 🔐❌", 'md')
end
	end

          local text = msg.content_.text_:gsub('قفل الكل بالساعه','lock all h')
    if text:match("^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Hh]  (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local mutept = {string.match(text, "^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Hh] (%d+)$")}
        local hour = string.gsub(mutept[1], 'h', '')
        local num1 = tonumber(hour) * 3600
        local num = tonumber(num1)
            database:setex('bot:muteall'..msg.chat_id_, num, true)
                if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, "> Lock all has been enable for "..mutept[1].." hours !", 'md')
       else 
              send(msg.chat_id_, msg.id_, 1, "`● - تم قفل كل الوسائط لمدة` "..mutept[1].." `ساعه` 🔐❌", 'md')
end
     end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^قفل (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^([Ll][Oo][Cc][Kk]) (.*)$")} 
	local TSHAKE = {string.match(text, "^(قفل) (.*)$")} 
      if mutept[2] == "all" or TSHAKE[2] == "الكل" then
	  if not database:get('bot:muteall'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل كل الوسائط `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:muteall'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> mute all is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل كل الوسائط` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "all warn" or TSHAKE[2] == "الكل بالتحذير" then
	  if not database:get('bot:muteallwarn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all warn has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل كل الوسائط `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:muteallwarn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل كل الوسائط` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "all ban" or TSHAKE[2] == "الكل بالطرد" then
	  if not database:get('bot:muteallban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل كل الوسائط `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:muteallban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل كل الوسائط` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "text" or TSHAKE[2] == "الدردشه" then
	  if not database:get('bot:text:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الدردشه `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:text:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الدردشه` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "text ban" or TSHAKE[2] == "الدردشه بالطرد" then
	  if not database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الدردشه `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:text:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الدردشه` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "text warn" or TSHAKE[2] == "الدردشه بالتحذير" then
	  if not database:get('bot:text:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الدردشه `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:text:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الدردشه` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline" or TSHAKE[2] == "الانلاين" then
	  if not database:get('bot:inline:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الانلاين `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:inline:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الانلاين` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline ban" or TSHAKE[2] == "الانلاين بالطرد" then
	  if not database:get('bot:inline:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الانلاين `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:inline:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الانلاين` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline warn" or TSHAKE[2] == "الانلاين بالتحذير" then
	  if not database:get('bot:inline:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الانلاين `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:inline:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الانلاين` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo" or TSHAKE[2] == "الصور" then
	  if not database:get('bot:photo:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الصور `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:photo:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الصور` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo ban" or TSHAKE[2] == "الصور بالطرد" then
	  if not database:get('bot:photo:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الصور `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:photo:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الصور` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo warn" or TSHAKE[2] == "الصور بالتحذير" then
	  if not database:get('bot:photo:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الصور `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:photo:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الصور` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "video" or TSHAKE[2] == "الفيديو" then
	  if not database:get('bot:video:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الفيديوهات `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:video:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الفيديوهات` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "video ban" or TSHAKE[2] == "الفيديو بالطرد" then
	  if not database:get('bot:video:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الفيديوهات `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:video:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الفيديوهات` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "video warn" or TSHAKE[2] == "الفيديو بالتحذير" then
	  if not database:get('bot:video:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الفيديوهات `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:video:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الفيديوهات` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif" or TSHAKE[2] == "المتحركه" then
	  if not database:get('bot:gifs:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل المتحركه `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:gifs:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل المتحركه` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif ban" or TSHAKE[2] == "المتحركه بالطرد" then
	  if not database:get('bot:gifs:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل المتحركه `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:gifs:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل المتحركه` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif warn" or TSHAKE[2] == "المتحركه بالتحذير" then
	  if not database:get('bot:gifs:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل المتحركه `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:gifs:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل المتحركه` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "music" or TSHAKE[2] == "الاغاني" then
	  if not database:get('bot:music:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الاغاني `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:music:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الاغاني` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "music ban" or TSHAKE[2] == "الاغاني بالطرد" then
	  if not database:get('bot:music:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الاغاني `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:music:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الاغاني` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "music warn" or TSHAKE[2] == "الاغاني بالتحذير" then
	  if not database:get('bot:music:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الاغاني `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:music:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الاغاني` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice" or TSHAKE[2] == "الصوت" then
	  if not database:get('bot:voice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الصوتيات `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:voice:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الصوتيات` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice ban" or TSHAKE[2] == "الصوت بالطرد" then
	  if not database:get('bot:voice:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الصوتيات `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:voice:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الصوتيات` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice warn" or TSHAKE[2] == "الصوت بالتحذير" then
	  if not database:get('bot:voice:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الصوتيات `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:voice:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الصوتيات` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "links" or TSHAKE[2] == "الروابط" then
	  if not database:get('bot:links:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الروابط `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:links:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الروابط` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "links ban" or TSHAKE[2] == "الروابط بالطرد" then
	  if not database:get('bot:links:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الروابط `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:links:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الروابط` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "links warn" or TSHAKE[2] == "الروابط بالتحذير" then
	  if not database:get('bot:links:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الروابط `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:links:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الروابط` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "location" or TSHAKE[2] == "الشبكات" then
	  if not database:get('bot:location:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الشبكات `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:location:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الشبكات` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "location ban" or TSHAKE[2] == "الشبكات بالطرد" then
	  if not database:get('bot:location:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الشبكات `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:location:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الشبكات` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "location warn" or TSHAKE[2] == "الشبكات بالتحذير" then
	  if not database:get('bot:location:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الشبكات `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:location:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الشبكات` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag" or TSHAKE[2] == "المعرف" then
	  if not database:get('bot:tag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل المعرفات <@> `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:tag:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل المعرفات <@>` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag ban" or TSHAKE[2] == "المعرف بالطرد" then
	  if not database:get('bot:tag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل المعرفات <@> `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:tag:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل المعرفات <@>` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag warn" or TSHAKE[2] == "المعرف بالتحذير" then
	  if not database:get('bot:tag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل المعرفات <@> `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:tag:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل المعرفات <@>` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag" or TSHAKE[2] == "التاك" then
	  if not database:get('bot:hashtag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل التاكات <#> `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:hashtag:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التاكات <#>` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag ban" or TSHAKE[2] == "التاك بالطرد" then
	  if not database:get('bot:hashtag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل التاكات <#> `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:hashtag:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التاكات <#>` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag warn" or TSHAKE[2] == "التاك بالتحذير" then
	  if not database:get('bot:hashtag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل التاكات <#> `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:hashtag:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التاكات <#>` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact" or TSHAKE[2] == "الجهات" then
	  if not database:get('bot:contact:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل جهات الاتصال `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:contact:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل جهات الاتصال` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact ban" or TSHAKE[2] == "الجهات بالطرد" then
	  if not database:get('bot:contact:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل جهات الاتصال `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:contact:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل جهات الاتصال` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact warn" or TSHAKE[2] == "الجهات بالتحذير" then
	  if not database:get('bot:contact:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل جهات الاتصال `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:contact:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل جهات الاتصال` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage" or TSHAKE[2] == "المواقع" then
	  if not database:get('bot:webpage:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل المواقع `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:webpage:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل المواقع` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage ban" or TSHAKE[2] == "المواقع بالطرد" then
	  if not database:get('bot:webpage:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل المواقع `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:webpage:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل المواقع` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage warn" or TSHAKE[2] == "المواقع بالتحذير" then
	  if not database:get('bot:webpage:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل المواقع `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:webpage:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل المواقع` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
    end
      if mutept[2] == "arabic" or TSHAKE[2] == "العربيه" then
	  if not database:get('bot:arabic:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل العربيه `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:arabic:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل العربيه` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "arabic ban" or TSHAKE[2] == "العربيه بالطرد" then
	  if not database:get('bot:arabic:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل العربيه `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:arabic:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل العربيه` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "arabic warn" or TSHAKE[2] == "العربيه بالتحذير" then
	  if not database:get('bot:arabic:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل العربيه `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:arabic:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل العربيه` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "english" or TSHAKE[2] == "الانكليزيه" then
	  if not database:get('bot:english:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الانكليزيه `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:english:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الانكليزيه` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "english ban" or TSHAKE[2] == "الانكليزيه بالطرد" then
	  if not database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الانكليزيه `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:english:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الانكليزيه` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "english warn" or TSHAKE[2] == "الانكليزيه بالتحذير" then
	  if not database:get('bot:english:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الانكليزيه `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:english:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الانكليزيه` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "spam del" or TSHAKE[2] == "الكلايش" then
	  if not database:get('bot:spam:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الكلايش `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:spam:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الكلايش` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "spam warn" or TSHAKE[2] == "الكلايش بالتحذير" then
	  if not database:get('bot:spam:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الكلايش `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:spam:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الكلايش` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker" or TSHAKE[2] == "الملصقات" then
	  if not database:get('bot:sticker:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الملصقات `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:sticker:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الملصقات` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker ban" or TSHAKE[2] == "الملصقات بالطرد" then
	  if not database:get('bot:sticker:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الملصقات `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:sticker:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الملصقات` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker warn" or TSHAKE[2] == "الملصقات بالتحذير" then
	  if not database:get('bot:sticker:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الملصقات `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:sticker:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الملصقات` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
    end
      if mutept[2] == "file" or TSHAKE[2] == "الملفات" then
	  if not database:get('bot:document:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الملفات `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:document:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الملفات` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "file ban" or TSHAKE[2] == "الملفات بالطرد" then
	  if not database:get('bot:document:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الملفات `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:document:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الملفات` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "file warn" or TSHAKE[2] == "الملفات بالتحذير" then
	  if not database:get('bot:document:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الملفات `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:document:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الملفات` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
  end
  
      if mutept[2] == "markdown" or TSHAKE[2] == "الماركدون" then
	  if not database:get('bot:markdown:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الماركدون `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:markdown:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الماركدون` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "markdown ban" or TSHAKE[2] == "الماركدون بالطرد" then
	  if not database:get('bot:markdown:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الماركدون `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:markdown:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الماركدون` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "markdown warn" or TSHAKE[2] == "الماركدون بالتحذير" then
	  if not database:get('bot:markdown:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الماركدون `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:markdown:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الماركدون` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
    end
    
	  if mutept[2] == "service" or TSHAKE[2] == "الاشعارات" then
	  if not database:get('bot:tgservice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tgservice has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الاشعارات `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:tgservice:mute'..msg.chat_id_,true)
       else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tgservice is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الاشعارات` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd" or TSHAKE[2] == "التوجيه" then
	  if not database:get('bot:forward:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل التوجيه `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:forward:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التوجيه` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd ban" or TSHAKE[2] == "التوجيه بالطرد" then
	  if not database:get('bot:forward:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل التوجيه `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:forward:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التوجيه` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd warn" or TSHAKE[2] == "التوجيه بالتحذير" then
	  if not database:get('bot:forward:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل التوجيه `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:forward:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل التوجيه` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd" or TSHAKE[2] == "الشارحه" then
	  if not database:get('bot:cmd:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الشارحه `🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
         database:set('bot:cmd:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الشارحه` 🔐\n\n● - `خاصية : المسح` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd ban" or TSHAKE[2] == "الشارحه بالطرد" then
	  if not database:get('bot:cmd:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الشارحه `🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
         database:set('bot:cmd:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الشارحه` 🔐\n\n● - `خاصية : الطرد` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd warn" or TSHAKE[2] == "الشارحه بالتحذير" then
	  if not database:get('bot:cmd:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم` ✔️ `قفل الشارحه `🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
         database:set('bot:cmd:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `قفل الشارحه` 🔐\n\n● - `خاصية : التحذير` ☑️', 1, 'md')
      end
      end
      end
	end 
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Uu][Nn][Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^فتح (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unmutept = {string.match(text, "^([Uu][Nn][Ll][Oo][Cc][Kk]) (.*)$")} 
	local UNTSHAKE = {string.match(text, "^(فتح) (.*)$")} 
      if unmutept[2] == "all" or UNTSHAKE[2] == "الكل" then
	  if database:get('bot:muteall'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح كل الوسائط `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:muteall'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> mute all is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح كــل الوسائط` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "all warn" or UNTSHAKE[2] == "الكل بالتحذير" then
	  if database:get('bot:muteallwarn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all warn has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح كل الوسائط `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:muteallwarn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح كل الوسائط` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "all ban" or UNTSHAKE[2] == "الكل بالطرد" then
	  if database:get('bot:muteallban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح كل الوسائط `🔓\n\n● - `خاصية : بالطرد `⚠️', 1, 'md')
      end
         database:del('bot:muteallban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح كل الوسائط` 🔓\n\n● - `خاصية : بالطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text" or UNTSHAKE[2] == "الدردشه" then
	  if database:get('bot:text:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الدردشه `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:text:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الدردشه` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text ban" or UNTSHAKE[2] == "الدردشه بالطرد" then
	  if database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الدردشه `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:text:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الدردشه` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text warn" or UNTSHAKE[2] == "الدردشه بالتحذير" then
	  if database:get('bot:text:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الدردشه `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:text:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الدردشه` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline" or UNTSHAKE[2] == "الانلاين" then
	  if database:get('bot:inline:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الانلاين `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:inline:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الانلاين` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline ban" or UNTSHAKE[2] == "الانلاين بالطرد" then
	  if database:get('bot:inline:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الانلاين `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:inline:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الانلاين` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline warn" or UNTSHAKE[2] == "الانلاين بالتحذير" then
	  if database:get('bot:inline:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الانلاين `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:inline:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الانلاين` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo" or UNTSHAKE[2] == "الصور" then
	  if database:get('bot:photo:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الصور `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:photo:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الصور` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo ban" or UNTSHAKE[2] == "الصور بالطرد" then
	  if database:get('bot:photo:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الصور `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:photo:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الصور` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo warn" or UNTSHAKE[2] == "الصور بالتحذير" then
	  if database:get('bot:photo:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الصور `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:photo:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الصور` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video" or UNTSHAKE[2] == "الفيديو" then
	  if database:get('bot:video:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الفيديوهات `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:video:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الفيديوهات` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video ban" or UNTSHAKE[2] == "الفيديو بالطرد" then
	  if database:get('bot:video:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الفيديوهات `🔓\n\n● - `خاصية : بالطرد `⚠️', 1, 'md')
      end
         database:del('bot:video:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الفيديوهات` 🔓\n\n● - `خاصية : بالطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video warn" or UNTSHAKE[2] == "الفيديو بالتحذير" then
	  if database:get('bot:video:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الفيديوهات `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:video:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الفيديوهات` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif" or UNTSHAKE[2] == "المتحركه" then
	  if database:get('bot:gifs:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح المتحركه `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:gifs:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح المتحركه` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif ban" or UNTSHAKE[2] == "المتحركه بالطرد" then
	  if database:get('bot:gifs:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح المتحركه `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:gifs:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح المتحركه` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif warn" or UNTSHAKE[2] == "المتحركه بالتحذير" then
	  if database:get('bot:gifs:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح المتحركه `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:gifs:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح المتحركه` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music" or UNTSHAKE[2] == "الاغاني" then
	  if database:get('bot:music:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الاغاني `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:music:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الاغاني` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music ban" or UNTSHAKE[2] == "الاغاني بالطرد" then
	  if database:get('bot:music:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الاغاني `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:music:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الاغاني` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music warn" or UNTSHAKE[2] == "الاغاني بالتحذير" then
	  if database:get('bot:music:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الاغاني `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:music:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الاغاني` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice" or UNTSHAKE[2] == "الصوت" then
	  if database:get('bot:voice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الصوتيات `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:voice:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الصوتيات` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice ban" or UNTSHAKE[2] == "الصوت بالطرد" then
	  if database:get('bot:voice:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الصوتيات `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:voice:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الصوتيات` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice warn" or UNTSHAKE[2] == "الصوت بالتحذير" then
	  if database:get('bot:voice:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الصوتيات `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:voice:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الصوتيات` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links" or UNTSHAKE[2] == "الروابط" then
	  if database:get('bot:links:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الروابط `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:links:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الروابط` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links ban" or UNTSHAKE[2] == "الروابط بالطرد" then
	  if database:get('bot:links:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الروابط `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:links:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الروابط` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links warn" or UNTSHAKE[2] == "الروابط بالتحذير" then
	  if database:get('bot:links:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الروابط `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:links:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الروابط` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location" or UNTSHAKE[2] == "الشبكات" then
	  if database:get('bot:location:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الشبكات `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:location:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الشبكات` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location ban" or UNTSHAKE[2] == "الشبكات بالطرد" then
	  if database:get('bot:location:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الشبكات `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:location:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الشبكات` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location warn" or UNTSHAKE[2] == "الشبكات بالتحذير" then
	  if database:get('bot:location:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الشبكات `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:location:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الشبكات` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end 
      end
      if unmutept[2] == "tag" or UNTSHAKE[2] == "المعرف" then
	  if database:get('bot:tag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح المعرفات <@> `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:tag:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح المعرفات <@>` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "tag ban" or UNTSHAKE[2] == "المعرف بالطرد" then
	  if database:get('bot:tag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح المعرفات <@> `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:tag:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح المعرفات <@>` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "tag warn" or UNTSHAKE[2] == "المعرف بالتحذير" then
	  if database:get('bot:tag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح المعرفات <@> `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:tag:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح المعرفات <@>` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag" or UNTSHAKE[2] == "التاك" then
	  if database:get('bot:hashtag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التاكات <#> `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:hashtag:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التاكات <#>` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag ban" or UNTSHAKE[2] == "التاك بالطرد" then
	  if database:get('bot:hashtag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التاكات <#> `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:hashtag:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التاكات <#>` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag warn" or UNTSHAKE[2] == "التاك بالتحذير" then
	  if database:get('bot:hashtag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التاكات <#> `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:hashtag:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التاكات <#>` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact" or UNTSHAKE[2] == "الجهات" then
	  if database:get('bot:contact:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح جهات الاتصال `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:contact:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح جهات الاتصال` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact ban" or UNTSHAKE[2] == "الجهات بالطرد" then
	  if database:get('bot:contact:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح جهات الاتصال `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:contact:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح جهات الاتصال` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact warn" or UNTSHAKE[2] == "الجهات بالتحذير" then
	  if database:get('bot:contact:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح جهات الاتصال `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:contact:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح جهات الاتصال` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage" or UNTSHAKE[2] == "المواقع" then
	  if database:get('bot:webpage:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح المواقع `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:webpage:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح المواقع` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage ban" or UNTSHAKE[2] == "المواقع بالطرد" then
	  if database:get('bot:webpage:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح المواقع `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:webpage:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح المواقع` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage warn" or UNTSHAKE[2] == "المواقع بالتحذير" then
	  if database:get('bot:webpage:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح المواقع `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:webpage:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح المواقع` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
    end
      if unmutept[2] == "arabic" or UNTSHAKE[2] == "العربيه" then
	  if database:get('bot:arabic:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح العربيه `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:arabic:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح العربيه` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "arabic ban" or UNTSHAKE[2] == "العربيه بالطرد" then
	  if database:get('bot:arabic:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح العربيه `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:arabic:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح العربيه` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "arabic warn" or UNTSHAKE[2] == "العربيه بالتحذير" then
	  if database:get('bot:arabic:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح العربيه `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:arabic:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح العربيه` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english" or UNTSHAKE[2] == "الانكليزيه" then
	  if database:get('bot:english:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الانكليزيه `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:english:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الانكليزيه` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english ban" or UNTSHAKE[2] == "الانكليزيه بالطرد" then
	  if database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الانكليزيه `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:english:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الانكليزيه` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english warn" or UNTSHAKE[2] == "الانكليزيه بالتحذير" then
	  if database:get('bot:english:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الانكليزيه `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:english:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الانكليزيه` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "spam del" or UNTSHAKE[2] == "الكلايش" then
	  if database:get('bot:spam:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الكلايش `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:spam:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الكلايش` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "spam warn" or UNTSHAKE[2] == "الكلايش بالتحذير" then
	  if database:get('bot:spam:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الكلايش `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:spam:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الكلايش` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker" or UNTSHAKE[2] == "الملصقات" then
	  if database:get('bot:sticker:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الملصقات `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:sticker:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الملصقات` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker ban" or UNTSHAKE[2] == "الملصقات بالطرد" then
	  if database:get('bot:sticker:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الملصقات `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:sticker:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الملصقات` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker warn" or UNTSHAKE[2] == "الملصقات بالتحذير" then
	  if database:get('bot:sticker:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الملصقات `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:sticker:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الملصقات` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
    end

      if unmutept[2] == "file" or UNTSHAKE[2] == "الملفات" then
	  if database:get('bot:document:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الملفات `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:document:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الملفات` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "file ban" or UNTSHAKE[2] == "الملفات بالطرد" then
	  if database:get('bot:document:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الملفات `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:document:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الملفات` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "file warn" or UNTSHAKE[2] == "الملفات بالتحذير" then
	  if database:get('bot:document:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الملفات `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:document:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الملفات` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end    

      if unmutept[2] == "markdown" or UNTSHAKE[2] == "الماركدون" then
	  if database:get('bot:markdown:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الماركدون `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:markdown:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الماركدون` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "markdown ban" or UNTSHAKE[2] == "الماركدون بالطرد" then
	  if database:get('bot:markdown:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الماركدون `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:markdown:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الماركدون` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "markdown warn" or UNTSHAKE[2] == "الماركدون بالتحذير" then
	  if database:get('bot:markdown:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الماركدون `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:markdown:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الماركدون` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end    


	  if unmutept[2] == "service" or UNTSHAKE[2] == "الاشعارات" then
	  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tgservice has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الاشعارات `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:tgservice:mute'..msg.chat_id_)
       else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tgservice is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الاشعارات` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd" or UNTSHAKE[2] == "التوجيه" then
	  if database:get('bot:forward:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التوجيه `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:forward:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التوجيه` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd ban" or UNTSHAKE[2] == "التوجيه بالطرد" then
	  if database:get('bot:forward:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التوجيه `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:forward:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التوجيه` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd warn" or UNTSHAKE[2] == "التوجيه بالتحذير" then
	  if database:get('bot:forward:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح التوجيه `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:forward:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح التوجيه` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd" or UNTSHAKE[2] == "الشارحه" then
	  if database:get('bot:cmd:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الشارحه `🔓\n\n● - `خاصية : المسح `⚠️', 1, 'md')
      end
         database:del('bot:cmd:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الشارحه` 🔓\n\n● - `خاصية : المسح` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd ban" or UNTSHAKE[2] == "الشارحه بالطرد" then
	  if database:get('bot:cmd:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الشارحه `🔓\n\n● - `خاصية : الطرد `⚠️', 1, 'md')
      end
         database:del('bot:cmd:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الشارحه` 🔓\n\n● - `خاصية : الطرد` ⚠️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd warn" or UNTSHAKE[2] == "الشارحه بالتحذير" then
	  if database:get('bot:cmd:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `تم `✔️ `فتح الشارحه `🔓\n\n● - `خاصية : التحذير `⚠️', 1, 'md')
      end
         database:del('bot:cmd:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم` ✔️ `فتح الشارحه` 🔓\n\n● - `خاصية : التحذير` ⚠️', 1, 'md')
      end
      end
      end
	end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('تعديل','edit')
  	if text:match("^[Ee][Dd][Ii][Tt] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local editmsg = {string.match(text, "^([Ee][Dd][Ii][Tt]) (.*)$")} 
		 edit(msg.chat_id_, msg.reply_to_message_id_, nil, editmsg[2], 1, 'html')
    if database:get('lang:gp:'..msg.chat_id_) then
		 	          send(msg.chat_id_, msg.id_, 1, '*Done* _Edit My Msg_', 1, 'md')
else 
		 	          send(msg.chat_id_, msg.id_, 1, '● - `تم تعديل الرساله` ✔️📌', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
    if text:match("^[Cc][Ll][Ee][Aa][Nn] [Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and is_sudo(msg) or text:match("^مسح قائمه العام$") and is_sudo(msg) then
    if database:get('lang:gp:'..msg.chat_id_) then
      text = '_> Banall has been_ *Cleaned*'
    else 
      text = '● - `تم مسح قائمه العام` ❌⚠️'
end
      database:del('bot:gbanned:')
	    send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
  end

    if text:match("^[Cc][Ll][Ee][Aa][Nn] [Aa][Dd][Mm][Ii][Nn][Ss]$") and is_sudo(msg) or text:match("^مسح ادمنيه البوت$") and is_sudo(msg) then
    if database:get('lang:gp:'..msg.chat_id_) then
      text = '_> adminlist has been_ *Cleaned*'
    else 
      text = '● - `تم مسح قائمه ادمنيه البوت` ❌⚠️'
end
      database:del('bot:admins:')
	    send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
  end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('مسح','clean')
  	if text:match("^[Cc][Ll][Ee][Aa][Nn] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Cc][Ll][Ee][Aa][Nn]) (.*)$")} 
       if txt[2] == 'banlist' or txt[2] == 'Banlist' or txt[2] == 'المحظورين' then
	      database:del('bot:banned:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Banlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '● - `تم مسح قائمه المحظورين` ❌⚠️', 1, 'md')
end
       end
	   if txt[2] == 'bots' or txt[2] == 'Bots' or txt[2] == 'البوتات' then
	  local function g_bots(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          chat_kick(msg.chat_id_,bots[i].msg.sender_user_id_)
          end 
      end
    channel_get_bots(msg.chat_id_,g_bots) 
    if database:get('lang:gp:'..msg.chat_id_) then
	          send(msg.chat_id_, msg.id_, 1, '_> All bots_ *kicked!*', 1, 'md')
          else 
          send(msg.chat_id_, msg.id_, 1, '● - `تم طرد جميع البوتات` ❌⚠️', 1, 'md')
end
	end
	   if txt[2] == 'modlist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'Modlist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'الادمنيه' and is_owner(msg.sender_user_id_, msg.chat_id_) then
	      database:del('bot:mods:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Modlist has been_ *Cleaned*', 1, 'md')
      else 
          send(msg.chat_id_, msg.id_, 1, '● - `تم مسح قائمه الادمنيه` ❌⚠️', 1, 'md')
end
       end 
	   if txt[2] == 'owners' and is_sudo(msg) or txt[2] == 'Owners' and is_sudo(msg) or txt[2] == 'المدراء' and is_sudo(msg) then
	      database:del('bot:owners:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> ownerlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '● - `تم مسح قائمه المدراء` ❌⚠️', 1, 'md')
end
       end
	   if txt[2] == 'rules' or txt[2] == 'Rules' or txt[2] == 'القوانين' then
	      database:del('bot:rules'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> rules has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '● - `تم مسح القوانين المحفوظه` ❌⚠️', 1, 'md')
end
       end
	   if txt[2] == 'link' or  txt[2] == 'Link' or  txt[2] == 'الرابط' then
	      database:del('bot:group:link'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> link has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '● - `تم مسح الرابط المحفوظ` ❌⚠️', 1, 'md')
end
       end
	   if txt[2] == 'badlist' or txt[2] == 'Badlist' or txt[2] == 'قائمه المنع' then
	      database:del('bot:filters:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> badlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '● - `تم مسح قائمه المنع` ❌⚠️', 1, 'md')
end
       end
	   if txt[2] == 'silentlist' or txt[2] == 'Silentlist' or txt[2] == 'المكتومين' then
	      database:del('bot:muted:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> silentlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '● - `تم مسح قائمه المكتومين` ❌⚠️', 1, 'md')
end
       end
       
    end 
	-----------------------------------------------------------------------------------------------
  	 if text:match("^[Ss] [Dd][Ee][Ll]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteall'..msg.chat_id_) then
	mute_all = '`lock | 🔐`'
	else
	mute_all = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:text:mute'..msg.chat_id_) then
	mute_text = '`lock | 🔐`'
	else
	mute_text = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:photo:mute'..msg.chat_id_) then
	mute_photo = '`lock | 🔐`'
	else
	mute_photo = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:video:mute'..msg.chat_id_) then
	mute_video = '`lock | 🔐`'
	else
	mute_video = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:gifs:mute'..msg.chat_id_) then
	mute_gifs = '`lock | 🔐`'
	else
	mute_gifs = '`unlock | 🔓`'
	end
	------------
	if database:get('anti-flood:'..msg.chat_id_) then
	mute_flood = '`unlock | 🔓`'
	else  
	mute_flood = '`lock | 🔐`'
	end
	------------
	if not database:get('flood:max:'..msg.chat_id_) then
	flood_m = 10
	else
	flood_m = database:get('flood:max:'..msg.chat_id_)
end
	------------
	if not database:get('flood:time:'..msg.chat_id_) then
	flood_t = 1
	else
	flood_t = database:get('flood:time:'..msg.chat_id_)
	end
	------------
	if database:get('bot:music:mute'..msg.chat_id_) then
	mute_music = '`lock | 🔐`'
	else
	mute_music = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:bots:mute'..msg.chat_id_) then
	mute_bots = '`lock | 🔐`'
	else
	mute_bots = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:inline:mute'..msg.chat_id_) then
	mute_in = '`lock | 🔐`'
	else
	mute_in = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:voice:mute'..msg.chat_id_) then
	mute_voice = '`lock | 🔐`'
	else
	mute_voice = '`unlock | 🔓`'
end

	if database:get('bot:document:mute'..msg.chat_id_) then
	mute_doc = '`lock | 🔐`'
	else
	mute_doc = '`unlock | 🔓`'
end

	if database:get('bot:markdown:mute'..msg.chat_id_) then
	mute_mdd = '`lock | 🔐`'
	else
	mute_mdd = '`unlock | 🔓`'
	end
	------------
	if database:get('editmsg'..msg.chat_id_) then
	mute_edit = '`lock | 🔐`'
	else
	mute_edit = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:links:mute'..msg.chat_id_) then
	mute_links = '`lock | 🔐`'
	else
	mute_links = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:pin:mute'..msg.chat_id_) then
	lock_pin = '`lock | 🔐`'
	else
	lock_pin = '`unlock | 🔓`'
	end 
    ------------
	if database:get('bot:sticker:mute'..msg.chat_id_) then
	lock_sticker = '`lock | 🔐`'
	else
	lock_sticker = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:tgservice:mute'..msg.chat_id_) then
	lock_tgservice = '`lock | 🔐`'
	else
	lock_tgservice = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:webpage:mute'..msg.chat_id_) then
	lock_wp = '`lock | 🔐`'
	else
	lock_wp = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:hashtag:mute'..msg.chat_id_) then
	lock_htag = '`lock | 🔐`'
	else
	lock_htag = '`unlock | 🔓`'
end

   if database:get('bot:cmd:mute'..msg.chat_id_) then
	lock_cmd = '`lock | 🔐`'
	else
	lock_cmd = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:tag:mute'..msg.chat_id_) then
	lock_tag = '`lock | 🔐`'
	else
	lock_tag = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:location:mute'..msg.chat_id_) then
	lock_location = '`lock | 🔐`'
	else
	lock_location = '`unlock | 🔓`'
end
  ------------
if not database:get('bot:sens:spam'..msg.chat_id_) then
spam_c = 300
else
spam_c = database:get('bot:sens:spam'..msg.chat_id_)
end

if not database:get('bot:sens:spam:warn'..msg.chat_id_) then
spam_d = 300
else
spam_d = database:get('bot:sens:spam:warn'..msg.chat_id_)
end

	------------
  if database:get('bot:contact:mute'..msg.chat_id_) then
	lock_contact = '`lock | 🔐`'
	else
	lock_contact = '`unlock | 🔓`'
	end
	------------
  if database:get('bot:spam:mute'..msg.chat_id_) then
	mute_spam = '`lock | 🔐`'
	else
	mute_spam = '`unlock | 🔓`'
end

	if database:get('anti-flood:warn'..msg.chat_id_) then
	lock_flood = '`unlock | 🔓`'
	else 
	lock_flood = '`lock | 🔐`'
end

	if database:get('anti-flood:del'..msg.chat_id_) then
	del_flood = '`unlock | 🔓`'
	else 
	del_flood = '`lock | 🔐`'
	end
	------------
    if database:get('bot:english:mute'..msg.chat_id_) then
	lock_english = '`lock | 🔐`'
	else
	lock_english = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:arabic:mute'..msg.chat_id_) then
	lock_arabic = '`lock | 🔐`'
	else
	lock_arabic = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:forward:mute'..msg.chat_id_) then
	lock_forward = '`lock | 🔐`'
	else
	lock_forward = '`unlock | 🔓`'
end

    if database:get('bot:rep:mute'..msg.chat_id_) then
	lock_rep = '`lock | 🔐`'
	else
	lock_rep = '`unlock | 🔓`'
	end
	------------
	if database:get("bot:welcome"..msg.chat_id_) then
	send_welcome = '`active | ✔`'
	else
	send_welcome = '`inactive | ⭕`'
end
		if not database:get('flood:max:warn'..msg.chat_id_) then
	flood_warn = 10
	else
	flood_warn = database:get('flood:max:warn'..msg.chat_id_)
end
		if not database:get('flood:max:del'..msg.chat_id_) then
	flood_del = 10
	else
	flood_del = database:get('flood:max:del'..msg.chat_id_)
end
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Del*\n======================\n*Del all* : "..mute_all.."\n" .."*Del Links* : "..mute_links.."\n" .."*Del Edit* : "..mute_edit.."\n" .."*Del Bots* : "..mute_bots.."\n" .."*Del Inline* : "..mute_in.."\n" .."*Del English* : "..lock_english.."\n" .."*Del Forward* : "..lock_forward.."\n" .."*Del Pin* : "..lock_pin.."\n" .."*Del Arabic* : "..lock_arabic.."\n" .."*Del Hashtag* : "..lock_htag.."\n".."*Del tag* : "..lock_tag.."\n" .."*Del Webpage* : "..lock_wp.."\n" .."*Del Location* : "..lock_location.."\n" .."*Del Tgservice* : "..lock_tgservice.."\n"
.."*Del Spam* : "..mute_spam.."\n" .."*Del Photo* : "..mute_photo.."\n" .."*Del Text* : "..mute_text.."\n" .."*Del Gifs* : "..mute_gifs.."\n" .."*Del Voice* : "..mute_voice.."\n" .."*Del Music* : "..mute_music.."\n" .."*Del Video* : "..mute_video.."\n*Del Cmd* : "..lock_cmd.."\n" .."*Del Markdown* : "..mute_mdd.."\n*Del Document* : "..mute_doc.."\n" .."*Flood Ban* : "..mute_flood.."\n" .."*Flood Mute* : "..lock_flood.."\n" .."*Flood del* : "..del_flood.."\n" .."*Setting reply* : "..lock_rep.."\n"
.."======================\n*Welcome* : "..send_welcome.."\n*Flood Time*  "..flood_t.."\n" .."*Flood Max* : "..flood_m.."\n" .."*Flood Mute* : "..flood_warn.."\n" .."*Flood del* : "..flood_del.."\n" .."*Number Spam* : "..spam_c.."\n" .."*Warn Spam* : "..spam_d.."\n"
 .."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end

          local text = msg.content_.text_:gsub('اعدادات المسح','sdd1')
  	 if text:match("^[Ss][Dd][Dd]1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteall'..msg.chat_id_) then
	mute_all = '`مفعل | 🔐`'
	else
	mute_all = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:text:mute'..msg.chat_id_) then
	mute_text = '`مفعل | 🔐`'
	else
	mute_text = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:photo:mute'..msg.chat_id_) then
	mute_photo = '`مفعل | 🔐`'
	else
	mute_photo = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:video:mute'..msg.chat_id_) then
	mute_video = '`مفعل | 🔐`'
	else
	mute_video = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:gifs:mute'..msg.chat_id_) then
	mute_gifs = '`مفعل | 🔐`'
	else
	mute_gifs = '`معطل | 🔓`'
	end
	------------
	if database:get('anti-flood:'..msg.chat_id_) then
	mute_flood = '`معطل | 🔓`'
	else  
	mute_flood = '`مفعل | 🔐`'
end
	------------
	if not database:get('flood:max:'..msg.chat_id_) then
	flood_m = 10
	else
	flood_m = database:get('flood:max:'..msg.chat_id_)
end
	------------
	if not database:get('flood:time:'..msg.chat_id_) then
	flood_t = 1
	else
	flood_t = database:get('flood:time:'..msg.chat_id_)
	end
	------------
	if database:get('bot:music:mute'..msg.chat_id_) then
	mute_music = '`مفعل | 🔐`'
	else
	mute_music = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:bots:mute'..msg.chat_id_) then
	mute_bots = '`مفعل | 🔐`'
	else
	mute_bots = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:inline:mute'..msg.chat_id_) then
	mute_in = '`مفعل | 🔐`'
	else
	mute_in = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:voice:mute'..msg.chat_id_) then
	mute_voice = '`مفعل | 🔐`'
	else
	mute_voice = '`معطل | 🔓`'
	end
	------------
	if database:get('editmsg'..msg.chat_id_) then
	mute_edit = '`مفعل | 🔐`'
	else
	mute_edit = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:links:mute'..msg.chat_id_) then
	mute_links = '`مفعل | 🔐`'
	else
	mute_links = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:pin:mute'..msg.chat_id_) then
	lock_pin = '`مفعل | 🔐`'
	else
	lock_pin = '`معطل | 🔓`'
end 

	if database:get('bot:document:mute'..msg.chat_id_) then
	mute_doc = '`مفعل | 🔐`'
	else
	mute_doc = '`معطل | 🔓`'
end

	if database:get('bot:markdown:mute'..msg.chat_id_) then
	mute_mdd = '`مفعل | 🔐`'
	else
	mute_mdd = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:sticker:mute'..msg.chat_id_) then
	lock_sticker = '`مفعل | 🔐`'
	else
	lock_sticker = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:tgservice:mute'..msg.chat_id_) then
	lock_tgservice = '`مفعل | 🔐`'
	else
	lock_tgservice = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:webpage:mute'..msg.chat_id_) then
	lock_wp = '`مفعل | 🔐`'
	else
	lock_wp = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:hashtag:mute'..msg.chat_id_) then
	lock_htag = '`مفعل | 🔐`'
	else
	lock_htag = '`معطل | 🔓`'
end

   if database:get('bot:cmd:mute'..msg.chat_id_) then
	lock_cmd = '`مفعل | 🔐`'
	else
	lock_cmd = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:tag:mute'..msg.chat_id_) then
	lock_tag = '`مفعل | 🔐`'
	else
	lock_tag = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:location:mute'..msg.chat_id_) then
	lock_location = '`مفعل | 🔐`'
	else
	lock_location = '`معطل | 🔓`'
end
  ------------
if not database:get('bot:sens:spam'..msg.chat_id_) then
spam_c = 300
else
spam_c = database:get('bot:sens:spam'..msg.chat_id_)
end

if not database:get('bot:sens:spam:warn'..msg.chat_id_) then
spam_d = 300
else
spam_d = database:get('bot:sens:spam:warn'..msg.chat_id_)
end
	------------
  if database:get('bot:contact:mute'..msg.chat_id_) then
	lock_contact = '`مفعل | 🔐`'
	else
	lock_contact = '`معطل | 🔓`'
	end
	------------
  if database:get('bot:spam:mute'..msg.chat_id_) then
	mute_spam = '`مفعل | 🔐`'
	else
	mute_spam = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:english:mute'..msg.chat_id_) then
	lock_english = '`مفعل | 🔐`'
	else
	lock_english = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:arabic:mute'..msg.chat_id_) then
	lock_arabic = '`مفعل | 🔐`'
	else
	lock_arabic = '`معطل | 🔓`'
end

	if database:get('anti-flood:warn'..msg.chat_id_) then
	lock_flood = '`معطل | 🔓`'
	else 
	lock_flood = '`مفعل | 🔐`'
end

	if database:get('anti-flood:del'..msg.chat_id_) then
	del_flood = '`معطل | 🔓`'
	else 
	del_flood = '`مفعل | 🔐`'
	end
	------------
    if database:get('bot:forward:mute'..msg.chat_id_) then
	lock_forward = '`مفعل | 🔐`'
	else
	lock_forward = '`معطل | 🔓`'
end

    if database:get('bot:rep:mute'..msg.chat_id_) then
	lock_rep = '`معطله | 🔐`'
	else
	lock_rep = '`مفعله | 🔓`'
	end
	------------
	if database:get("bot:welcome"..msg.chat_id_) then
	send_welcome = '`مفعل | ✔`'
	else
	send_welcome = '`معطل | ⭕`'
end
		if not database:get('flood:max:warn'..msg.chat_id_) then
	flood_warn = 10
	else
	flood_warn = database:get('flood:max:warn'..msg.chat_id_)
end
	if not database:get('flood:max:del'..msg.chat_id_) then
	flood_del = 10
	else
	flood_del = database:get('flood:max:del'..msg.chat_id_)
end
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`لا نهائي`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "● - `اعدادات المجموعه بالمسح`\nֆ • • • • • • • • • • • • • ֆ\n● - `كل الوسائط` : "..mute_all.."\n"
	 .."● - `الروابط` : "..mute_links.."\n"
	 .."● - `التعديل` : "..mute_edit.."\n" 
	 .."● - `البوتات` : "..mute_bots.."\n"
	 .."● - `الانلاين` : "..mute_in.."\n" 
	 .."● - `اللغه الانكليزيه` : "..lock_english.."\n"
	 .."● - `اعاده التوجيه` : "..lock_forward.."\n" 
	 .."● - `التثبيت` : "..lock_pin.."\n" 
	 .."● - `اللغه العربيه` : "..lock_arabic.."\n\n"
	 .."● - `التاكات` : "..lock_htag.."\n"
	 .."● - `المعرفات` : "..lock_tag.."\n" 
	 .."● - `المواقع` : "..lock_wp.."\n" 
	 .."● - `الشبكات` : "..lock_location.."\n" 
	 .."● - `الاشعارات` : "..lock_tgservice.."\n"
   .."● - `الكلايش` : "..mute_spam.."\n"
   .."● - `الصور` : "..mute_photo.."\n"
   .."● - `الدردشه` : "..mute_text.."\n"
   .."● - `الصور المتحركه` : "..mute_gifs.."\n\n"
   .."● - `الصوتيات` : "..mute_voice.."\n" 
   .."● - `الاغاني` : "..mute_music.."\n"
   .."● - `الفيديوهات` : "..mute_video.."\n● - `الشارحه` : "..lock_cmd.."\n"
   .."● - `الماركدون` : "..mute_mdd.."\n● - `الملفات` : "..mute_doc.."\n" 
   .."● - `التكرار بالطرد` : "..mute_flood.."\n" 
   .."● - `التكرار بالكتم` : "..lock_flood.."\n" 
   .."● - `التكرار بالمسح` : "..del_flood.."\n" 
   .."● - `الردود` : "..lock_rep.."\n\n"
   .."ֆ • • • • • • • • • • • • • ֆ\n● - `الترحيب` : "..send_welcome.."\n● - `زمن التكرار` : "..flood_t.."\n"
   .."● - `عدد التكرار بالطرد` : "..flood_m.."\n"
   .."● - `عدد التكرار بالكتم` : "..flood_warn.."\n\n"
   .."● - `عدد التكرار بالمسح` : "..flood_del.."\n"
   .."● - `عدد الكلايش بالمسح` : "..spam_c.."\n"
   .."● - `عدد الكلايش بالتحذير` : "..spam_d.."\n"
   .."● - `انقضاء البوت` : "..exp_dat.." `يوم`\nֆ • • • • • • • • • • • • • ֆ"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
  	 if text:match("^[Ss] [Ww][Aa][Rr][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallwarn'..msg.chat_id_) then
	mute_all = '`lock | 🔐`'
	else
	mute_all = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:text:warn'..msg.chat_id_) then
	mute_text = '`lock | 🔐`'
	else
	mute_text = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:photo:warn'..msg.chat_id_) then
	mute_photo = '`lock | 🔐`'
	else
	mute_photo = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:video:warn'..msg.chat_id_) then
	mute_video = '`lock | 🔐`'
	else
	mute_video = '`unlock | 🔓`'
end

	if database:get('bot:spam:warn'..msg.chat_id_) then
	mute_spam = '`lock | 🔐`'
	else
	mute_spam = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:gifs:warn'..msg.chat_id_) then
	mute_gifs = '`lock | 🔐`'
	else
	mute_gifs = '`unlock | 🔓`'
end

	------------
	if database:get('bot:music:warn'..msg.chat_id_) then
	mute_music = '`lock | 🔐`'
	else
	mute_music = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:inline:warn'..msg.chat_id_) then
	mute_in = '`lock | 🔐`'
	else
	mute_in = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:voice:warn'..msg.chat_id_) then
	mute_voice = '`lock | 🔐`'
	else
	mute_voice = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:links:warn'..msg.chat_id_) then
	mute_links = '`lock | 🔐`'
	else
	mute_links = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:sticker:warn'..msg.chat_id_) then
	lock_sticker = '`lock | 🔐`'
	else
	lock_sticker = '`unlock | 🔓`'
	end
	------------
   if database:get('bot:cmd:warn'..msg.chat_id_) then
	lock_cmd = '`lock | 🔐`'
	else
	lock_cmd = '`unlock | 🔓`'
end

    if database:get('bot:webpage:warn'..msg.chat_id_) then
	lock_wp = '`lock | 🔐`'
	else
	lock_wp = '`unlock | 🔓`'
end

	if database:get('bot:document:warn'..msg.chat_id_) then
	mute_doc = '`lock | 🔐`'
	else
	mute_doc = '`unlock | 🔓`'
end

	if database:get('bot:markdown:warn'..msg.chat_id_) then
	mute_mdd = '`lock | 🔐`'
	else
	mute_mdd = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:hashtag:warn'..msg.chat_id_) then
	lock_htag = '`lock | 🔐`'
	else
	lock_htag = '`unlock | 🔓`'
end
	if database:get('bot:pin:warn'..msg.chat_id_) then
	lock_pin = '`lock | 🔐`'
	else
	lock_pin = '`unlock | 🔓`'
	end 
	------------
    if database:get('bot:tag:warn'..msg.chat_id_) then
	lock_tag = '`lock | 🔐`'
	else
	lock_tag = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:location:warn'..msg.chat_id_) then
	lock_location = '`lock | 🔐`'
	else
	lock_location = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:contact:warn'..msg.chat_id_) then
	lock_contact = '`lock | 🔐`'
	else
	lock_contact = '`unlock | 🔓`'
	end
	------------
	
    if database:get('bot:english:warn'..msg.chat_id_) then
	lock_english = '`lock | 🔐`'
	else
	lock_english = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:arabic:warn'..msg.chat_id_) then
	lock_arabic = '`lock | 🔐`'
	else
	lock_arabic = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:forward:warn'..msg.chat_id_) then
	lock_forward = '`lock | 🔐`'
	else
	lock_forward = '`unlock | 🔓`'
end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Warn*\n======================\n*Warn all* : "..mute_all.."\n" .."*Warn Links* : "..mute_links.."\n" .."*Warn Inline* : "..mute_in.."\n" .."*Warn Pin* : "..lock_pin.."\n" .."*Warn English* : "..lock_english.."\n" .."*Warn Forward* : "..lock_forward.."\n" .."*Warn Arabic* : "..lock_arabic.."\n" .."*Warn Hashtag* : "..lock_htag.."\n".."*Warn tag* : "..lock_tag.."\n" .."*Warn Webpag* : "..lock_wp.."\n" .."*Warn Location* : "..lock_location.."\n"
.."*Warn Spam* : "..mute_spam.."\n" .."*Warn Photo* : "..mute_photo.."\n" .."*Warn Text* : "..mute_text.."\n" .."*Warn Gifs* : "..mute_gifs.."\n" .."*Warn Voice* : "..mute_voice.."\n" .."*Warn Music* : "..mute_music.."\n" .."*Warn Video* : "..mute_video.."\n*Warn Cmd* : "..lock_cmd.."\n"  .."*Warn Markdown* : "..mute_mdd.."\n*Warn Document* : "..mute_doc.."\n" 
.."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end


          local text = msg.content_.text_:gsub('اعدادات التحذير','sdd2')
  	 if text:match("^[Ss][Dd][Dd]2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallwarn'..msg.chat_id_) then
	mute_all = '`مفعل | 🔐`'
	else
	mute_all = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:text:warn'..msg.chat_id_) then
	mute_text = '`مفعل | 🔐`'
	else
	mute_text = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:photo:warn'..msg.chat_id_) then
	mute_photo = '`مفعل | 🔐`'
	else
	mute_photo = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:video:warn'..msg.chat_id_) then
	mute_video = '`مفعل | 🔐`'
	else
	mute_video = '`معطل | 🔓`'
end

	if database:get('bot:spam:warn'..msg.chat_id_) then
	mute_spam = '`مفعل | 🔐`'
	else
	mute_spam = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:gifs:warn'..msg.chat_id_) then
	mute_gifs = '`مفعل | 🔐`'
	else
	mute_gifs = '`معطل | 🔓`'
end
	------------
	if database:get('bot:music:warn'..msg.chat_id_) then
	mute_music = '`مفعل | 🔐`'
	else
	mute_music = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:inline:warn'..msg.chat_id_) then
	mute_in = '`مفعل | 🔐`'
	else
	mute_in = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:voice:warn'..msg.chat_id_) then
	mute_voice = '`مفعل | 🔐`'
	else
	mute_voice = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:links:warn'..msg.chat_id_) then
	mute_links = '`مفعل | 🔐`'
	else
	mute_links = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:sticker:warn'..msg.chat_id_) then
	lock_sticker = '`مفعل | 🔐`'
	else
	lock_sticker = '`معطل | 🔓`'
	end
	------------
   if database:get('bot:cmd:warn'..msg.chat_id_) then
	lock_cmd = '`مفعل | 🔐`'
	else
	lock_cmd = '`معطل | 🔓`'
end

    if database:get('bot:webpage:warn'..msg.chat_id_) then
	lock_wp = '`مفعل | 🔐`'
	else
	lock_wp = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:hashtag:warn'..msg.chat_id_) then
	lock_htag = '`مفعل | 🔐`'
	else
	lock_htag = '`معطل | 🔓`'
end
	if database:get('bot:pin:warn'..msg.chat_id_) then
	lock_pin = '`مفعل | 🔐`'
	else
	lock_pin = '`معطل | 🔓`'
	end 
	------------
    if database:get('bot:tag:warn'..msg.chat_id_) then
	lock_tag = '`مفعل | 🔐`'
	else
	lock_tag = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:location:warn'..msg.chat_id_) then
	lock_location = '`مفعل | 🔐`'
	else
	lock_location = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:contact:warn'..msg.chat_id_) then
	lock_contact = '`مفعل | 🔐`'
	else
	lock_contact = '`معطل | 🔓`'
	end

    if database:get('bot:english:warn'..msg.chat_id_) then
	lock_english = '`مفعل | 🔐`'
	else
	lock_english = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:arabic:warn'..msg.chat_id_) then
	lock_arabic = '`مفعل | 🔐`'
	else
	lock_arabic = '`معطل | 🔓`'
end

	if database:get('bot:document:warn'..msg.chat_id_) then
	mute_doc = '`مفعل | 🔐`'
	else
	mute_doc = '`معطل | 🔓`'
end

	if database:get('bot:markdown:warn'..msg.chat_id_) then
	mute_mdd = '`مفعل | 🔐`'
	else
	mute_mdd = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:forward:warn'..msg.chat_id_) then
	lock_forward = '`مفعل | 🔐`'
	else
	lock_forward = '`معطل | 🔓`'
end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`لا نهائي`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "● - `اعدادات المجموعه بالتحذير`\nֆ • • • • • • • • • • • • • ֆ\n● - `كل الوسائط` : "..mute_all.."\n"
	 .."● - `الروابط` : "..mute_links.."\n"
	 .."● - `الانلاين` : "..mute_in.."\n"
	 .."● - `التثبيت` : "..lock_pin.."\n"
	 .."● - `اللغه الانكليزيه` : "..lock_english.."\n"
	 .."● - `اعاده التوجيه` : "..lock_forward.."\n"
	 .."● - `اللغه العربيه` : "..lock_arabic.."\n"
	 .."● - `التاكات` : "..lock_htag.."\n"
	 .."● - `المعرفات` : "..lock_tag.."\n" 
	 .."● - `المواقع` : "..lock_wp.."\n\n"
	 .."● - `الشبكات` : "..lock_location.."\n" 
   .."● - `الكلايش` : "..mute_spam.."\n" 
   .."● - `الصور` : "..mute_photo.."\n" 
   .."● - `الدردشه` : "..mute_text.."\n"
   .."● - `الصور المتحركه` : "..mute_gifs.."\n"
   .."● - `الصوتيات` : "..mute_voice.."\n" 
   .."● - `الاغاني` : "..mute_music.."\n" 
   .."● - `الفيديوهات` : "..mute_video.."\n● - `الشارحه` : "..lock_cmd.."\n"
   .."● - `الماركدون` : "..mute_mdd.."\n● - `الملفات` : "..mute_doc.."\n" 
   .."\n● - `انقضاء البوت` : "..exp_dat.." `يوم`\n" .."ֆ • • • • • • • • • • • • • ֆ"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
  	 if text:match("^[Ss] [Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallban'..msg.chat_id_) then
	mute_all = '`lock | 🔐`'
	else
	mute_all = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:text:ban'..msg.chat_id_) then
	mute_text = '`lock | 🔐`'
	else
	mute_text = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:photo:ban'..msg.chat_id_) then
	mute_photo = '`lock | 🔐`'
	else
	mute_photo = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:video:ban'..msg.chat_id_) then
	mute_video = '`lock | 🔐`'
	else
	mute_video = '`unlock | 🔓`'
end

	------------
	if database:get('bot:gifs:ban'..msg.chat_id_) then
	mute_gifs = '`lock | 🔐`'
	else
	mute_gifs = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:music:ban'..msg.chat_id_) then
	mute_music = '`lock | 🔐`'
	else
	mute_music = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:inline:ban'..msg.chat_id_) then
	mute_in = '`lock | 🔐`'
	else
	mute_in = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:voice:ban'..msg.chat_id_) then
	mute_voice = '`lock | 🔐`'
	else
	mute_voice = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:links:ban'..msg.chat_id_) then
	mute_links = '`lock | 🔐`'
	else
	mute_links = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:sticker:ban'..msg.chat_id_) then
	lock_sticker = '`lock | 🔐`'
	else
	lock_sticker = '`unlock | 🔓`'
	end
	------------
   if database:get('bot:cmd:ban'..msg.chat_id_) then
	lock_cmd = '`lock | 🔐`'
	else
	lock_cmd = '`unlock | 🔓`'
end

    if database:get('bot:webpage:ban'..msg.chat_id_) then
	lock_wp = '`lock | 🔐`'
	else
	lock_wp = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:hashtag:ban'..msg.chat_id_) then
	lock_htag = '`lock | 🔐`'
	else
	lock_htag = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:tag:ban'..msg.chat_id_) then
	lock_tag = '`lock | 🔐`'
	else
	lock_tag = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:location:ban'..msg.chat_id_) then
	lock_location = '`lock | 🔐`'
	else
	lock_location = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:contact:ban'..msg.chat_id_) then
	lock_contact = '`lock | 🔐`'
	else
	lock_contact = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:english:ban'..msg.chat_id_) then
	lock_english = '`lock | 🔐`'
	else
	lock_english = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:arabic:ban'..msg.chat_id_) then
	lock_arabic = '`lock | 🔐`'
	else
	lock_arabic = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:forward:ban'..msg.chat_id_) then
	lock_forward = '`lock | 🔐`'
	else
	lock_forward = '`unlock | 🔓`'
end

	if database:get('bot:document:ban'..msg.chat_id_) then
	mute_doc = '`lock | 🔐`'
	else
	mute_doc = '`unlock | 🔓`'
end

	if database:get('bot:markdown:ban'..msg.chat_id_) then
	mute_mdd = '`lock | 🔐`'
	else
	mute_mdd = '`unlock | 🔓`'
	end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Ban*\n======================\n*Ban all* : "..mute_all.."\n" .."*Ban Links* : "..mute_links.."\n" .."*Ban Inline* : "..mute_in.."\n" .."*Ban English* : "..lock_english.."\n" .."*Ban Forward* : "..lock_forward.."\n" .."*Ban Arabic* : "..lock_arabic.."\n" .."*Ban Hashtag* : "..lock_htag.."\n".."*Ban tag* : "..lock_tag.."\n" .."*Ban Webpage* : "..lock_wp.."\n" .."*Ban Location* : "..lock_location.."\n"
.."*Ban Photo* : "..mute_photo.."\n" .."*Ban Text* : "..mute_text.."\n" .."*Ban Gifs* : "..mute_gifs.."\n" .."*Ban Voice* : "..mute_voice.."\n" .."*Ban Music* : "..mute_music.."\n" .."*Ban Video* : "..mute_video.."\n*Ban Cmd* : "..lock_cmd.."\n"  .."*Ban Markdown* : "..mute_mdd.."\n*Ban Document* : "..mute_doc.."\n" 
.."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
          local text = msg.content_.text_:gsub('اعدادات الطرد','sdd3')
  	 if text:match("^[Ss][Dd][Dd]3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallban'..msg.chat_id_) then
	mute_all = '`مفعل | 🔐`'
	else
	mute_all = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:text:ban'..msg.chat_id_) then
	mute_text = '`مفعل | 🔐`'
	else
	mute_text = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:photo:ban'..msg.chat_id_) then
	mute_photo = '`مفعل | 🔐`'
	else
	mute_photo = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:video:ban'..msg.chat_id_) then
	mute_video = '`مفعل | 🔐`'
	else
	mute_video = '`معطل | 🔓`'
end
	------------
	if database:get('bot:gifs:ban'..msg.chat_id_) then
	mute_gifs = '`مفعل | 🔐`'
	else
	mute_gifs = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:music:ban'..msg.chat_id_) then
	mute_music = '`مفعل | 🔐`'
	else
	mute_music = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:inline:ban'..msg.chat_id_) then
	mute_in = '`مفعل | 🔐`'
	else
	mute_in = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:voice:ban'..msg.chat_id_) then
	mute_voice = '`مفعل | 🔐`'
	else
	mute_voice = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:links:ban'..msg.chat_id_) then
	mute_links = '`مفعل | 🔐`'
	else
	mute_links = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:sticker:ban'..msg.chat_id_) then
	lock_sticker = '`مفعل | 🔐`'
	else
	lock_sticker = '`معطل | 🔓`'
	end
	------------
   if database:get('bot:cmd:ban'..msg.chat_id_) then
	lock_cmd = '`مفعل | 🔐`'
	else
	lock_cmd = '`معطل | 🔓`'
end

    if database:get('bot:webpage:ban'..msg.chat_id_) then
	lock_wp = '`مفعل | 🔐`'
	else
	lock_wp = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:hashtag:ban'..msg.chat_id_) then
	lock_htag = '`مفعل | 🔐`'
	else
	lock_htag = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:tag:ban'..msg.chat_id_) then
	lock_tag = '`مفعل | 🔐`'
	else
	lock_tag = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:location:ban'..msg.chat_id_) then
	lock_location = '`مفعل | 🔐`'
	else
	lock_location = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:contact:ban'..msg.chat_id_) then
	lock_contact = '`مفعل | 🔐`'
	else
	lock_contact = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:english:ban'..msg.chat_id_) then
	lock_english = '`مفعل | 🔐`'
	else
	lock_english = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:arabic:ban'..msg.chat_id_) then
	lock_arabic = '`مفعل | 🔐`'
	else
	lock_arabic = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:forward:ban'..msg.chat_id_) then
	lock_forward = '`مفعل | 🔐`'
	else
	lock_forward = '`معطل | 🔓`'
end

	if database:get('bot:document:ban'..msg.chat_id_) then
	mute_doc = '`مفعل | 🔐`'
	else
	mute_doc = '`معطل | 🔓`'
end

	if database:get('bot:markdown:ban'..msg.chat_id_) then
	mute_mdd = '`مفعل | 🔐`'
	else
	mute_mdd = '`معطل | 🔓`'
	end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`لا نهائي`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "● - `اعدادات المجموعه بالطرد`\nֆ • • • • • • • • • • • • • ֆ\n● - `كل الوسائط` : "..mute_all.."\n"
	 .."● - `الروابط` : "..mute_links.."\n" 
	 .."● - `الانلاين` : "..mute_in.."\n"
	 .."● - `اللغه الانكليزيه` : "..lock_english.."\n"
	 .."● - `اعاده التوجيه` : "..lock_forward.."\n" 
	 .."● - `اللغه العربيه` : "..lock_arabic.."\n"
	 .."● - `التاكات` : "..lock_htag.."\n"
	 .."● - `المعرفات` : "..lock_tag.."\n" 
	 .."● - `المواقع` : "..lock_wp.."\n\n" 
	 .."● - `الشبكات` : "..lock_location.."\n"
   .."● - `الصور` : "..mute_photo.."\n" 
   .."● - `الدردشه` : "..mute_text.."\n" 
   .."● - `الصور المتحركه` : "..mute_gifs.."\n" 
   .."● - `الصوتيات` : "..mute_voice.."\n"
   .."● - `الاغاني` : "..mute_music.."\n"  
   .."● - `الفيديوهات` : "..mute_video.."\n● - `الشارحه` : "..lock_cmd.."\n"
   .."● - `الماركدون` : "..mute_mdd.."\n● - `الملفات` : "..mute_doc.."\n" 
   .."● - `انقضاء البوت` : "..exp_dat.." `يوم`\n" .."ֆ • • • • • • • • • • • • • ֆ"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
     
    
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('كرر','echo')
  	if text:match("^echo (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^(echo) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, txt[2], 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('وضع قوانين','setrules')
  	if text:match("^[Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss]) (.*)$")}
	database:set('bot:rules'..msg.chat_id_, txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, "*> Group rules upadted..._", 1, 'md')
   else 
         send(msg.chat_id_, msg.id_, 1, "● - `تم وضع القوانين للمجموعه` 📍☑️", 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Rr][Uu][Ll][Ee][Ss]$")or text:match("^القوانين$") then
	local rules = database:get('bot:rules'..msg.chat_id_)
	if rules then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Group Rules :*\n'..rules, 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '● - `قوانين المجموعه هي  :` ⬇️\n'..rules, 1, 'md')
end
    else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*rules msg not saved!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '● - `لم يتم حفظ قوانين للمجموعه` ⚠️❌', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
if text:match("^[Dd][Ee][Vv]$")or text:match("^مطور بوت$") or text:match("^مطورين$") or text:match("^مطور البوت$") or text:match("^المطورين$") or text:match("^مطور$") or text:match("^المطور$") and msg.reply_to_message_id_ == 0 then
       sendContact(msg.chat_id_, msg.id_, 0, 1, nil, 9647707641864, "TshAke TEAM" , "", bot_id)
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('وضع اسم','setname')
		if text:match("^[Ss][Ee][Tt][Nn][Aa][Mm][Ee] (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Ee][Tt][Nn][Aa][Mm][Ee]) (.*)$")}
	     changetitle(msg.chat_id_, txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Group name updated!_\n'..txt[2], 1, 'md')
       else
         send(msg.chat_id_, msg.id_, 1, '● - `تم تحديث اسم المجموعه الى ✔️⬇️`\n'..txt[2], 1, 'md')
         end
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Pp][Hh][Oo][Tt][Oo]$") or text:match("^وضع صوره") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          database:set('bot:setphoto'..msg.chat_id_..':'..msg.sender_user_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Please send a photo noew!_', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '● - `قم بارسال صوره الان` ✔️📌', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('وضع وقت','setexpire')
	if text:match("^[Ss][Ee][Tt][Ee][Xx][Pp][Ii][Rr][Ee] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
		local a = {string.match(text, "^([Ss][Ee][Tt][Ee][Xx][Pp][Ii][Rr][Ee]) (%d+)$")} 
		 local time = a[2] * day
         database:setex("bot:charge:"..msg.chat_id_,time,true)
		 database:set("bot:enable:"..msg.chat_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Group Charged for_ *'..a[2]..'* _Days_', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '● - `تم وضع وقت انتهاء البوت` *'..a[2]..'* `يوم` ⚠️❌', 1, 'md')
end
  end
  
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Tt][Aa][Tt][Ss]$") or text:match("^الوقت$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local ex = database:ttl("bot:charge:"..msg.chat_id_)
       if ex == -1 then
                if database:get('lang:gp:'..msg.chat_id_) then
		send(msg.chat_id_, msg.id_, 1, '_No fanil_', 1, 'md')
else 
		send(msg.chat_id_, msg.id_, 1, '● - `وقت المجموعه لا نهائي` ☑️', 1, 'md')
end
       else
        local d = math.floor(ex / day ) + 1
                if database:get('lang:gp:'..msg.chat_id_) then
	   		send(msg.chat_id_, msg.id_, 1, d.." *Group Days*", 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, "● - `عدد ايام وقت المجموعه` ⬇️\n"..d.." `يوم` 📍", 1, 'md')
end
       end
    end
	-----------------------------------------------------------------------------------------------
    
	if text:match("^وقت المجموعه (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^(وقت المجموعه) (-%d+)$")} 
    local ex = database:ttl("bot:charge:"..txt[2])
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, '● - `وقت المجموعه لا نهائي` ☑️', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
send(msg.chat_id_, msg.id_, 1, "● - `عدد ايام وقت المجموعه` ⬇️\n"..d.." `يوم` 📍", 1, 'md')
       end
    end
    
	if text:match("^[Ss][Tt][Aa][Tt][Ss] [Gg][Pp] (-%d+)") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Tt][Aa][Tt][Ss] [Gg][Pp]) (-%d+)$")} 
    local ex = database:ttl("bot:charge:"..txt[2])
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, '_No fanil_', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
	   		send(msg.chat_id_, msg.id_, 1, d.." *Group is Days*", 1, 'md')
       end
    end
	-----------------------------------------------------------------------------------------------
	 if is_sudo(msg) then
  -----------------------------------------------------------------------------------------------
  if text:match("^[Ll][Ee][Aa][Vv][Ee] (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
  	local txt = {string.match(text, "^([Ll][Ee][Aa][Vv][Ee]) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '*Group* '..txt[2]..' *remov*', 1, 'md')
	   send(txt[2], 0, 1, '*Error*\n_Group is not my_', 1, 'md')
	   chat_leave(txt[2], bot_id)
  end
  
  if text:match("^مغادره (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
  	local txt = {string.match(text, "^(مغادره) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '● - `المجموعه` '..txt[2]..' `تم الخروج منها` ☑️📍', 1, 'md')
	   send(txt[2], 0, 1, '● - `هذه ليست ضمن المجموعات الخاصة بي` ⚠️❌', 1, 'md')
	   chat_leave(txt[2], bot_id)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^المده1 (-%d+)$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^(المده1) (-%d+)$")} 
       local timeplan1 = 2592000
       database:setex("bot:charge:"..txt[2],timeplan1,true)
	   send(msg.chat_id_, msg.id_, 1, '● - `المجموعه` '..txt[2]..' `تم اعادة تفعيلها المدة 30 يوم ☑️📍`', 1, 'md')
	   send(txt[2], 0, 1, '● - `تم تفعيل مدة المجموعه 30 يوم` ✔️📌', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "● - `قام بتفعيل مجموعه المده كانت 30 يوم ☑️` : \n● - `ايدي المطور 📍` : "..msg.sender_user_id_.."\n● - `معرف المطور 🚹` : "..get_info(msg.sender_user_id_).."\n\n● - `معلومات المجموعه 👥` :\n\n● - `ايدي المجموعه 🚀` : "..msg.chat_id_.."\n● - `اسم المجموعه 📌` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]1 (-%d+)$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]1) (-%d+)$")} 
       local timeplan1 = 2592000
       database:setex("bot:charge:"..txt[2],timeplan1,true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done 30 Days Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done 30 Days Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^المده2 (-%d+)$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^(المده2) (-%d+)$")} 
       local timeplan2 = 7776000
       database:setex("bot:charge:"..txt[2],timeplan2,true)
	   send(msg.chat_id_, msg.id_, 1, '● - `المجموعه` '..txt[2]..' `تم اعادة تفعيلها المدة 90 يوم ☑️📍`', 1, 'md')
	   send(txt[2], 0, 1, '● - `تم تفعيل مدة المجموعه 90 يوم` ✔️📌', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "● - `قام بتفعيل مجموعه المده كانت 90 يوم ☑️` : \n● - `ايدي المطور 📍` : "..msg.sender_user_id_.."\n● - `معرف المطور 🚹` : "..get_info(msg.sender_user_id_).."\n\n● - `معلومات المجموعه 👥` :\n\n● - `ايدي المجموعه 🚀` : "..msg.chat_id_.."\n● - `اسم المجموعه 📌` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
-------------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]2 (-%d+)$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]2) (-%d+)$")} 
       local timeplan2 = 7776000
       database:setex("bot:charge:"..txt[2],timeplan2,true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done 90 Days Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done 90 Days Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^المده3 (-%d+)$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^(المده3) (-%d+)$")} 
       database:set("bot:charge:"..txt[2],true)
	   send(msg.chat_id_, msg.id_, 1, '● - `المجموعه` '..txt[2]..' `تم اعادة تفعيلها المدة لا نهائية ☑️📍`', 1, 'md')
	   send(txt[2], 0, 1, '● - `تم تفعيل مدة المجموعه لا نهائية` ✔️📌', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "● - `قام بتفعيل مجموعه المده كانت لا نهائية ☑️` : \n● - `ايدي المطور 📍` : "..msg.sender_user_id_.."\n● - `معرف المطور 🚹` : "..get_info(msg.sender_user_id_).."\n\n● - `معلومات المجموعه 👥` :\n\n● - `ايدي المجموعه 🚀` : "..msg.chat_id_.."\n● - `اسم المجموعه 📌` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]3 (-%d+)$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]3) (-%d+)$")} 
       database:set("bot:charge:"..txt[2],true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done Days No Fanil Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done Days No Fanil Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('تفعيل','add')
  if text:match('^[Aa][Dd][Dd]$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^([Aa][Dd][Dd])$")} 
    if database:get("bot:charge:"..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Bot is already Added Group*', 1, 'md')
    else
        send(msg.chat_id_, msg.id_, 1, "● - `المجموعه [ "..chat.title_.." ] مفعله سابقا` ☑️", 1, 'md')
end
                  end
       if not database:get("bot:charge:"..msg.chat_id_) then
       database:set("bot:charge:"..msg.chat_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
	   send(msg.chat_id_, msg.id_, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Bot Added To Group*", 1, 'md')
   else 
        send(msg.chat_id_, msg.id_, 1, "● - `ايديك 📍 :` _"..msg.sender_user_id_.."_\n● - `تم` ✔️ `تفعيل المجموعه [ "..chat.title_.." ]` ☑️", 1, 'md')
end
	   for k,v in pairs(sudo_users) do
                if database:get('lang:gp:'..msg.chat_id_) then
	      send(v, 0, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> added bot to new group*" , 1, 'md')
      else  
            send(v, 0, 1, "● - `قام بتفعيل مجموعه جديده ☑️` : \n● - `ايدي المطور 📍` : "..msg.sender_user_id_.."\n● - `معرف المطور 🚹` : "..get_info(msg.sender_user_id_).."\n\n● - `معلومات المجموعه 👥` :\n\n● - `ايدي المجموعه 🚀` : "..msg.chat_id_.."\n● - `اسم المجموعه 📌` : "..chat.title_ , 1, 'md')
end
       end
	   database:set("bot:enable:"..msg.chat_id_,true)
  end
end
  -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('تعطيل','rem')
  if text:match('^[Rr][Ee][Mm]$') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^([Rr][Ee][Mm])$")} 
      if not database:get("bot:charge:"..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Bot is already remove Group*', 1, 'md')
    else 
        send(msg.chat_id_, msg.id_, 1, "● - `المجموعه [ "..chat.title_.." ] معطله سابقا` ⚠️", 1, 'md')
end
                  end
      if database:get("bot:charge:"..msg.chat_id_) then
       database:del("bot:charge:"..msg.chat_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
	   send(msg.chat_id_, msg.id_, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Bot Removed To Group!*", 1, 'md')
   else 
        send(msg.chat_id_, msg.id_, 1, "● - `ايديك 📍 :` _"..msg.sender_user_id_.."_\n● - `تم` ✔️ `تعطيل المجموعه [ "..chat.title_.." ]` ⚠️", 1, 'md')
end
	   for k,v in pairs(sudo_users) do
                if database:get('lang:gp:'..msg.chat_id_) then
	      send(v, 0, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Removed bot from new group*" , 1, 'md')
      else 
            send(v, 0, 1, "● - `قام بتعطيل مجموعه ⚠️` : \n● - `ايدي المطور 📍` : "..msg.sender_user_id_.."\n● - `معرف المطور 🚹` : "..get_info(msg.sender_user_id_).."\n\n● - `معلومات المجموعه 👥` :\n\n● - `ايدي المجموعه 🚀` : "..msg.chat_id_.."\n● - `اسم المجموعه 📌` : "..chat.title_ , 1, 'md')
end
       end
  end
  end
              
  -----------------------------------------------------------------------------------------------
   if text:match('^[Jj][Oo][Ii][Nn] (-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^([Jj][Oo][Ii][Nn]) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *is join*', 1, 'md')
	   send(txt[2], 0, 1, '*Sudo Joined To Grpup*', 1, 'md')
	   add_user(txt[2], msg.sender_user_id_, 10)
  end
  -----------------------------------------------------------------------------------------------
   if text:match('^اضافه (-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^(اضافه) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '● - `المجموعه` '..txt[2]..' `تم اضافتك لها ` ☑️', 1, 'md')
	   send(txt[2], 0, 1, '● - `تم اضافه المطور للمجموعه` ✔️📍', 1, 'md')
	   add_user(txt[2], msg.sender_user_id_, 10)
  end
   -----------------------------------------------------------------------------------------------
  end
	-----------------------------------------------------------------------------------------------
     if text:match("^[Dd][Ee][Ll]$")  and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^مسح$") and msg.reply_to_message_id_ ~= 0 and is_mod(msg.sender_user_id_, msg.chat_id_) then
     delete_msg(msg.chat_id_, {[0] = msg.reply_to_message_id_})
     delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
	----------------------------------------------------------------------------------------------
   if text:match('^تنظيف (%d+)$') and is_sudo(msg) then
  local matches = {string.match(text, "^(تنظيف) (%d+)$")}
   if msg.chat_id_:match("^-100") then
    if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 1 then
      pm = '● - <code> لا تستطيع حذف اكثر من 100 رساله ❗️⚠️</code>'
    send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                  else
      tdcli_function ({
     ID = "GetChatHistory",
       chat_id_ = msg.chat_id_,
          from_message_id_ = 0,
   offset_ = 0,
          limit_ = tonumber(matches[2])
    }, delmsg, nil)
      pm ='● - <i>[ '..matches[2]..' ]</i> <code>من الرسائل تم حذفها ☑️❌</code>'
           send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
       end
        else pm ='● - <code> هناك خطا<code> ⚠️'
      send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
              end
            end


   if text:match('^[Dd]el (%d+)$') and is_sudo(msg) then
  local matches = {string.match(text, "^([Dd]el) (%d+)$")}
   if msg.chat_id_:match("^-100") then
    if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 1 then
      pm = '<b>> Error</b>\n<b>use /del [1-1000] !<bb>'
    send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                  else
      tdcli_function ({
     ID = "GetChatHistory",
       chat_id_ = msg.chat_id_,
          from_message_id_ = 0,
   offset_ = 0,
          limit_ = tonumber(matches[2])
    }, delmsg, nil)
      pm ='> <i>'..matches[2]..'</i> <b>Last Msgs Has Been Removed.</b>'
           send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
       end
        else pm ='<b>> found!<b>'
      send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                end
              end

          local text = msg.content_.text_:gsub('حفظ','note')
    if text:match("^[Nn][Oo][Tt][Ee] (.*)$") and is_sudo(msg) then
    local txt = {string.match(text, "^([Nn][Oo][Tt][Ee]) (.*)$")}
      database:set('owner:note1', txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*save!*', 1, 'md')
    else 
         send(msg.chat_id_, msg.id_, 1, '● - `تم حفظ الكليشه ☑️`', 1, 'md')
end
    end

    if text:match("^[Dd][Nn][Oo][Tt][Ee]$") or text:match("^حذف الكليشه$") and is_sudo(msg) then
      database:del('owner:note1',msg.chat_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Deleted!*', 1, 'md')
    else 
         send(msg.chat_id_, msg.id_, 1, '● - `تم حذف الكليشه ⚠️`', 1, 'md')
end
      end
  -----------------------------------------------------------------------------------------------
    if text:match("^[Gg][Ee][Tt][Nn][Oo][Tt][Ee]$") and is_sudo(msg) or text:match("^جلب الكليشه$") and is_sudo(msg) then
    local note = database:get('owner:note1')
	if note then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Note is :-*\n'..note, 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '● - `الكليشه المحفوظه ⬇️ :`\n'..note, 1, 'md')
end
    else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Note msg not saved!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '● - `لا يوجد كليشه محفوظه ⚠️`', 1, 'md')
end
	end
end

  if text:match("^[Ss][Ee][Tt][Ll][Aa][Nn][Gg] (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^تحويل (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
    local langs = {string.match(text, "^(.*) (.*)$")}
  if langs[2] == "ar" or langs[2] == "عربيه" then
  if not database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '● - `بالفعل تم وضع اللغه العربيه للبوت ⚠️`', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '● - `تم وضع اللغه العربيه للبوت في المجموعه ☑️`', 1, 'md')
       database:del('lang:gp:'..msg.chat_id_)
    end
    end
  if langs[2] == "en" or langs[2] == "انكليزيه" then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '_> Language Bot is already_ *English*', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '> _Language Bot has been changed to_ *English* !', 1, 'md')
        database:set('lang:gp:'..msg.chat_id_,true)
    end
    end
end
----------------------------------------------------------------------------------------------

  if text == "unlock reply" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock Reply" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تفعيل الردود" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:rep:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies is already enabled*️', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, '● - `الردود بالفعل تم تفعيلها` ☑️', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies has been enable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '● - `تم تفعيل الردود` ☑️', 1, 'md')
       database:del('bot:rep:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock reply" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock Reply" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تعطيل الردود" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:rep:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies is already disabled*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '● - `الردود بالفعل تم تعطيلها` ⚠️', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies has been disable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '● - `تم تعطيل الردود` ⚠️', 1, 'md')
        database:set('bot:rep:mute'..msg.chat_id_,true)
      end
    end
  end
	-----------------------------------------------------------------------------------------------
   if text:match("^[Ii][Dd][Gg][Pp]$") or text:match("^ايدي المجموعه$") then
    send(msg.chat_id_, msg.id_, 1, "*"..msg.chat_id_.."*", 1, 'md')
  end
	-----------------------------------------------------------------------------------------------
  if text == "unlock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تفعيل الايدي" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:id:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID is already enabled*️', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, '● - `الايدي بالفعل تم تفعيله` ☑️', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID has been enable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '● - `تم تفعيل الايدي` ☑️', 1, 'md')
       database:del('bot:id:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تعطيل الايدي" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:id:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID is already disabled*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '● - `الايدي بالفعل تم تعطيله` ⚠️', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID has been disable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '● - `تم تعطيل الايدي` ⚠️', 1, 'md')
        database:set('bot:id:mute'..msg.chat_id_,true)
      end
    end
  end
	-----------------------------------------------------------------------------------------------
if  text:match("^[Ii][Dd]$") and msg.reply_to_message_id_ == 0 or text:match("^ايدي$") and msg.reply_to_message_id_ == 0 then
local function getpro(extra, result, success)
local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
   if result.photos_[0] then
      if is_sudo(msg) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Sudo'
      else
      t = 'مطور البوت ☑️'
      end
      elseif is_admin(msg.sender_user_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Global Admin'
      else
      t = 'ادمن في البوت ✔️'
      end
      elseif is_owner(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Owner'
      else
      t = 'مدير الكروب ❗️'
      end
      elseif is_mod(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Moderator'
      else
      t = 'ادمن للكروب 🎐'
      end
      else
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Member'
      else
      t = 'عضو فقط ⚠️'
      end
    end
         if not database:get('bot:id:mute'..msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,"> Group ID : "..msg.chat_id_.."\n> Your ID : "..msg.sender_user_id_.."\n> UserName : "..get_info(msg.sender_user_id_).."\n> Your Rank : "..t.."\n> Msgs : "..user_msgs,msg.id_,msg.id_.."")
  else 
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,"● - ايدي المجموعه 📍 : "..msg.chat_id_.."\n● - ايديك 📌 : "..msg.sender_user_id_.."\n● - معرفك 🚹 : "..get_info(msg.sender_user_id_).."\n● - موقعك *️⃣ : "..t.."\n● - رسائلك 📝 : "..user_msgs,msg.id_,msg.id_.."")
end
else 
      end
   else
         if not database:get('bot:id:mute'..msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt Profile Photo!!\n\n> *> Group ID :* "..msg.chat_id_.."\n*> Your ID :* "..msg.sender_user_id_.."\n*> UserName :* "..get_info(msg.sender_user_id_).."\n*> Msgs : *_"..user_msgs.."_", 1, 'md')
   else 
      send(msg.chat_id_, msg.id_, 1, "● -`انت لا تملك صوره لحسابك ` ❗️\n\n● -` ايدي المجموعه ` 📍 : "..msg.chat_id_.."\n● -` ايديك ` 📌 : "..msg.sender_user_id_.."\n● -` معرفك ` 🚹 : "..get_info(msg.sender_user_id_).."\n● -` رسائلك `📝 : _"..user_msgs.."_", 1, 'md')
end
else 
      end
   end
   end
   tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = 1
  }, getpro, nil)
end

   if text:match('^الحساب (%d+)$') and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = text:match('^الحساب (%d+)$')
        local text = 'اضغط لمشاهده الحساب'
      tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=19, user_id_=id}}}}, dl_cb, nil)
   end 

   if text:match('^[Ww][Hh][Oo][Ii][Ss] (%d+)$') and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = text:match('^[Ww][Hh][Oo][Ii][Ss] (%d+)$')
        local text = 'Click to view user!'
      tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=19, user_id_=id}}}}, dl_cb, nil)
   end
          local text = msg.content_.text_:gsub('معلومات','res')
          if text:match("^[Rr][Ee][Ss] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
            local memb = {string.match(text, "^([Rr][Ee][Ss]) (.*)$")}
            function whois(extra,result,success)
                if result.username_ then
             result.username_ = '@'..result.username_
               else
             result.username_ = 'لا يوجد معرف'
               end
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> *Name* :'..result.first_name_..'\n> *Username* : '..result.username_..'\n> *ID* : '..msg.sender_user_id_, 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '● - `الاسم` 📌 : '..result.first_name_..'\n● - `المعرف` 🚹 : '..result.username_..'\n● - `الايدي` 📍 : '..msg.sender_user_id_, 1, 'md')
              end
            end
            getUser(memb[2],whois)
          end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Pp][Ii][Nn]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^تثبيت$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
	   database:set('pinnedmsg'..msg.chat_id_,msg.reply_to_message_id_)
          if database:get('lang:gp:'..msg.chat_id_) then
	            send(msg.chat_id_, msg.id_, 1, '_Msg han been_ *pinned!*', 1, 'md')
	           else 
         send(msg.chat_id_, msg.id_, 1, '● - `تم تثبيت الرساله` ☑️', 1, 'md')
end
 end

   if text:match("^[Vv][Ii][Ee][Ww]$") or text:match("^مشاهده منشور$") then
        database:set('bot:viewget'..msg.sender_user_id_,true)
    if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*Please send a post now!*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, '● - `قم بارسال المنشور الان` ❗️', 1, 'md')
end
   end
  end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Uu][Nn][Pp][Ii][Nn]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^الغاء تثبيت$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^الغاء التثبيت") and is_owner(msg.sender_user_id_, msg.chat_id_) then
         unpinmsg(msg.chat_id_)
          if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Pinned Msg han been_ *unpinned!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '● - `تم الغاء تثبيت الرساله` ⚠️', 1, 'md')
end
   end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Hh][Ee][Ll][Pp]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
`هناك`  *6* `اوامر لعرضها`
*======================*
*h1* `لعرض اوامر الحمايه`
*======================*
*h2* `لعرض اوامر الحمايه بالتحذير`
*======================*
*h3* `لعرض اوامر الحمايه بالطرد`
*======================*
*h4* `لعرض اوامر الادمنيه`
*======================*
*h5* `لعرض اوامر المجموعه`
*======================*
*h6* `لعرض اوامر المطورين`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `للقفل`
*unlock* `للفتح`
*======================*
*| links |* `الروابط`
*| tag |* `المعرف`
*| hashtag |* `التاك`
*| cmd |* `السلاش`
*| edit |* `التعديل`
*| webpage |* `الروابط الخارجيه`
*======================*
*| flood ban |* `التكرار بالطرد`
*| flood mute |* `التكرار بالكتم`
*| flood del |* `التكرار بالمسح`
*| gif |* `الصور المتحركه`
*| photo |* `الصور`
*| sticker |* `الملصقات`
*| video |* `الفيديو`
*| inline |* `لستات شفافه`
*======================*
*| text |* `الدردشه`
*| fwd |* `التوجيه`
*| music |* `الاغاني`
*| voice |* `الصوت`
*| contact |* `جهات الاتصال`
*| service |* `اشعارات الدخول`
*| markdown |* `الماركدون`
*| file |* `الملفات`
*======================*
*| location |* `المواقع`
*| bots |* `البوتات`
*| spam |* `الكلايش`
*| arabic |* `العربيه`
*| english |* `الانكليزيه`
*| reply |* `الردود`
*| id |* `الايدي`
*| all |* `كل الميديا`
*| all |* `مع العدد قفل الميديا بالثواني`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `للقفل`
*unlock* `للفتح`
*======================*
*| links warn |* `الروابط`
*| tag warn |* `المعرف`
*| hashtag warn |* `التاك`
*| cmd warn |* `السلاش`
*| webpage warn |* `الروابط الخارجيه`
*======================*
*| gif warn |* `الصور المتحركه`
*| photo warn |* `الصور`
*| sticker warn |* `الملصقات`
*| video warn |* `الفيديو`
*| inline warn |* `لستات شفافه`
*======================*
*| text warn |* `الدردشه`
*| fwd warn |* `التوجيه`
*| music warn |* `الاغاني`
*| voice warn |* `الصوت`
*| contact warn |* `جهات الاتصال`
*| markdown warn |* `الماركدون`
*| file warn |* `الملفات`
*======================*
*| location warn |* `المواقع`
*| spam |* `الكلايش`
*| arabic warn |* `العربيه`
*| english warn |* `الانكليزيه`
*| all warn |* `كل الميديا`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `للقفل`
*unlock* `للفتح`
*======================*
*| links ban |* `الروابط`
*| tag ban |* `المعرف`
*| hashtag ban |* `التاك`
*| cmd ban |* `السلاش`
*| webpage ban |* `الروابط الخارجيه`
*======================*
*| gif ban |* `الصور المتحركه`
*| photo ban |* `الصور`
*| sticker ban |* `الملصقات`
*| video ban |* `الفيديو`
*| inline ban |* `لستات شفافه`
*| markdown ban |* `الماركدون`
*| file ban |* `الملفات`
*======================*
*| text ban |* `الدردشه`
*| fwd ban |* `التوجيه`
*| music ban |* `الاغاني`
*| voice ban |* `الصوت`
*| contact ban |* `جهات الاتصال`
*| location ban |* `المواقع`
*======================*
*| arabic ban |* `العربيه`
*| english ban |* `الانكليزيه`
*| all ban |* `كل الميديا`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]4$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*======================*
*| setmote |* `رفع ادمن` 
*| remmote |* `ازاله ادمن` 
*| setlang en |* `تغير اللغه للانكليزيه` 
*| setlang ar |* `تغير اللغه للعربيه` 
*| unsilent |* `لالغاء كتم العضو` 
*| silent |* `لكتم عضو` 
*| ban |* `حظر عضو` 
*| unban |* `الغاء حظر العضو` 
*| kick |* `طرد عضو` 
*| id |* `لاظهار الايدي [بالرد] `
*| pin |* `تثبيت رساله!`
*| unpin |* `الغاء تثبيت الرساله!`
*| res |* `معلومات حساب بالايدي` 
*| whois |* `مع الايدي لعرض صاحب الايدي`
*======================*
*| s del |* `اظهار اعدادات المسح`
*| s warn |* `اظهار اعدادات التحذير`
*| s ban |* `اظهار اعدادات الطرد`
*| silentlist |* `اظهار المكتومين`
*| banlist |* `اظهار المحظورين`
*| modlist |* `اظهار الادمنيه`
*| del |* `حذف رساله بالرد`
*| link |* `اظهار الرابط`
*| rules |* `اظهار القوانين`
*======================*
*| bad |* `منع كلمه` 
*| unbad |* `الغاء منع كلمه` 
*| badlist |* `اظهار الكلمات الممنوعه` 
*| stats |* `لمعرفه ايام البوت`
*| del wlc |* `حذف الترحيب` 
*| set wlc |* `وضع الترحيب` 
*| wlc on |* `تفعيل الترحيب` 
*| wlc off |* `تعطيل الترحيب` 
*| get wlc |* `معرفه الترحيب الحالي` 
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end

   if text:match("^[Hh]5$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*======================*
*clean* `مع الاوامر ادناه بوضع فراغ`

*| banlist |* `المحظورين`
*| badlist |* `كلمات المحظوره`
*| modlist |* `الادمنيه`
*| link |* `الرابط المحفوظ`
*| silentlist |* `المكتومين`
*| bots |* `بوتات تفليش وغيرها`
*| rules |* `القوانين`
*======================*
*set* `مع الاوامر ادناه بدون فراغ`

*| link |* `لوضع رابط`
*| rules |* `لوضع قوانين`
*| name |* `مع الاسم لوضع اسم`
*| photo |* `لوضع صوره`

*======================*

*| flood ban |* `وضع تكرار بالطرد`
*| flood mute |* `وضع تكرار بالكتم`
*| flood del |* `وضع تكرار بالكتم`
*| flood time |* `لوضع زمن تكرار بالطرد او الكتم`
*| spam del |* `وضع عدد السبام بالمسح`
*| spam warn |* `وضع عدد السبام بالتحذير`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]6$") and is_sudo(msg) then
   
   local text =  [[
*======================*
*| add |* `تفعيل البوت`
*| rem |* `تعطيل البوت`
*| setexpire |* `وضع ايام للبوت`
*| stats gp |* `لمعرفه ايام البوت`
*| plan1 + id |* `تفعيل البوت 30 يوم`
*| plan2 + id |* `تفعيل البوت 90 يوم`
*| plan3 + id |* `تفعيل البوت لا نهائي`
*| join + id |* `لاضافتك للكروب`
*| leave + id |* `لخروج البوت`
*| leave |* `لخروج البوت`
*| stats gp + id |* `لمعرفه  ايام البوت`
*| view |* `لاظهار مشاهدات منشور`
*| note |* `لحفظ كليشه`
*| dnote |* `لحذف الكليشه`
*| getnote |* `لاظهار الكليشه`
*| reload |* `لتنشيط البوت`
*| clean gbanlist |* `لحذف الحظر العام`
*| clean owners |* `لحذف قائمه المدراء`
*| adminlist |* `لاظهار ادمنيه البوت`
*| gbanlist |* `لاظهار المحظورين عام `
*| ownerlist |* `لاظهار مدراء البوت`
*| setadmin |* `لاضافه ادمن`
*| remadmin |* `لحذف ادمن`
*| setowner |* `لاضافه مدير`
*| remowner |* `لحذف مدير`
*| banall |* `لحظر العام`
*| unbanall |* `لالغاء العام`
*| invite |* `لاضافه عضو`
*| groups |* `عدد كروبات البوت`
*| bc |* `لنشر شئ`
*| del |* `ويه العدد حذف رسائل`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   
   
   if text:match("^الاوامر$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
● - هناك  6 اوامر لعرضها 🛠🦁
ֆ • • • • • • • • • • • • • ֆ
• `م1 : لعرض اوامر الحمايه` 🛡

• `م2 : لعرض اوامر الحمايه بالتحذير` ⚠️

• `م3 : لعرض اوامر الحمايه بالطرد` 🚷

• `م4 : لعرض اوامر الادمنيه` 🔰

• `م5 : لعرض اوامر المجموعه `💬

• `م6 : لعرض اوامر المطورين `🤖
ֆ • • • • • • • • • • • • • ֆ
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^م1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
● - اوامر حمايه بالمسح  🔰
ֆ • • • • • • • • • • • • • ֆ
• قفل : لقفل امر 🔒
• فتح : لفتح امر🔓
ֆ • • • • • • • • • • • • • ֆ
• الروابط  | 🔰
• المعرف |🌀
• التاك |📥
• الشارحه |〰
• التعديل | 🛃
• التثبيت | 📌
• المواقع | ♨️
ֆ • • • • • • • • • • • • • ֆ
• التكرار بالطرد |🔆
• التكرار بالكتـم |❇️
• التكرار بالمسح |📍
• المتحركه |🎌
• الملفات |📔
• الصور |🌠
• الملصقات |🔐
• الفيديو |🎥
• الانلاين |📡
ֆ • • • • • • • • • • • • • ֆ
• الدردشه |📇
• التوجيه |♻️
• الاغاني |✳️
• الصوت |🔊
• الجهات |📥
• الماركدون | ⛎
• الاشعارات |💤
ֆ • • • • • • • • • • • • • ֆ
• الشبكات |👥
• البوتات |🤖
• الكلايش |🚸
• العربيه|🆎
• الانكليزيه |♍️
• الكل |📛
• الكل بالثواني + العدد |🚯
• الكل بالساعه + العدد |🚷
ֆ • • • • • • • • • • • • • ֆ
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
    
   if text:match("^م2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
● - اوامر حمايه المجموعه بالتحذير ⚠️
ֆ • • • • • • • • • • • • • ֆ
قفل : لقفل امر 🔒
فتح : لفتح امر 🔓
ֆ • • • • • • • • • • • • • ֆ
• الروابط بالتحذير  | 🔰
• المعرف بالتحذير |🌀
• التاك بالتحذير |📥
• الماركدون بالتحذير| ⛎
• الشارحه بالتحذير |〰
• المواقع بالتحذير | ♨️
• التثبيت بالتحذير | 📌
ֆ • • • • • • • • • • • • • ֆ
• المتحركه بالتحذير |🎌
• الصور بالتحذير |🌠
• الملصقات بالتحذير |🔐
• الفيديو بالتحذير |🎥
• الانلاين بالتحذير |📡
ֆ • • • • • • • • • • • • • ֆ
• الدردشه بالتحذير |📇
• الملفات بالتحذير |📔
• التوجيه بالتحذير |♻️
• الاغاني بالتحذير |✳️
• الصوت بالتحذير |🔊
• الجهات بالتحذير |📥
ֆ • • • • • • • • • • • • • ֆ
• الشبكات بالتحذير |👥
• الكلايش بالتحذير |🚸
• العربيه بالتحذير |🆎
• الانكليزيه بالتحذير |♍️
• الكل بالتحذير |📛
ֆ • • • • • • • • • • • • • ֆ
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^م3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
● - اوامر الحمايه بالطرد 🚸
ֆ • • • • • • • • • • • • • ֆ
قفل  : لقفل امر 🔒
فتح : لفتح امر🔓
ֆ • • • • • • • • • • • • • ֆ
• الروابط بالطرد | 🔰
• المعرف بالطرد |🌀
• التاك بالطرد |📥
• الشارحه بالطرد |〰
• المواقع بالطرد | ♨️
• الماركدون بالطرد | ⛎
ֆ • • • • • • • • • • • • • ֆ
• المتحركه بالطرد |🎌
• الملفات بالطرد |📔
• الصور بالطرد |🌠
• الملصقات بالطرد |🔐
• الفيديو بالطرد |🎥
• الانلاين بالطرد  |📡
ֆ • • • • • • • • • • • • • ֆ
• الدردشه بالطرد |📇
• التوجيه بالطرد |♻️
• الاغاني بالطرد |✳️
• الصوت بالطرد |🔊
• الجهات بالطرد|📥
• الشبكات بالطرد|👥
ֆ • • • • • • • • • • • • • ֆ
• الكلايش بالطرد |🚸
• العربيه بالطرد  |🆎
• الانكليزيه بالطرد |♍️
• الكل بالطرد |📛
ֆ • • • • • • • • • • • • • ֆ
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^م4$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
● - اوامر الادمنيه 👤
ֆ • • • • • • • • • • • • • ֆ
• رفع ادمن | 🔼
• تنزيل ادمن | 🔽
• تحويل انكليزيه | ♏️
• تحويل عربيه | 🆎
• الغاء كتم | 🔆
• كتم | 🔅
• حظر | ✳️
• طرد | ♦️
• الغاء حظر | ❇️
• ايدي + رد | 🆔
• تثبيت | ❗️
• الغاء تثبيت | ❕
ֆ • • • • • • • • • • • • • ֆ
• اعدادات المسح | 💠
• اعدادات التحذير | 🌀
• اعدادات الطرد | 🛂
• المكتومين | 🚷
• المحظورين | 🚯
• قائمه المنع | 📃
• الادمنيه | 🛃
• مسح + رد | 🚮
• الرابط | 📮
• القوانين | 📝
ֆ • • • • • • • • • • • • • ֆ
• منع + الكلمه | 📈
• الغاء منع + الكلمه| 📉
• الوقت |🔗
• حذف الترحيب | ✋️
• وضع ترحيب | 🖐
• تفعيل الترحيب | ⭕️
• تعطيل الترحيب | ❌
• جلب الترحيب | 💢

• تفعيل الردود  | 🔔
• تعطيل الردود |🔕
• تفعيل الايدي  | 🔔
• تعطيل الايدي |🔕
• معلومات + ايدي|💯
• الحساب + ايدي| ❇️
ֆ • • • • • • • • • • • • • ֆ
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end

   if text:match("^م5$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
● - اوامر المجموعه 👥
ֆ • • • • • • • • • • • • • ֆ
مسح : مع الاوامر ادناه بوضع فراغ
ֆ • • • • • • • • • • • • • ֆ
• المحظورين | 🚷
• قائمه المنع | 📃
• الادمنيه | 📊
• الرابط | 🔰
• المكتومين | 🤐
• البوتات | 🤖
• القوانين | 📝
ֆ • • • • • • • • • • • • • ֆ
وضع : مع الاوامر ادناه
ֆ • • • • • • • • • • • • • ֆ
• رابط | 🔰
• قوانين | 📝
• اسم | 📌
• صوره | 🌌
ֆ • • • • • • • • • • • • • ֆ
• وضع تكرار بالطرد + العدد| 🔅
• وضع تكرار بالكتم + العدد| ❇️
• وضع تكرار بالمسح + العدد| 📍
• وضع زمن التكرار + العدد| 💹
• وضع كلايش بالمسح + العدد| 📑
• وضع كلايش بالتحذير + العدد| 📈
ֆ • • • • • • • • • • • • • ֆ
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^م6$") and is_sudo(msg) then
   
   local text =  [[
● -اوامر المطور 👨‍🔧
ֆ • • • • • • • • • • • • • ֆ
• تفعيل | ⭕️
• تعطيل | ❌
• وضع وقت + عدد | 🕤
• المده1 + id | ⌛️
• المده2 + id |⏳
• المده3 + id | 🔋
• اضافه + id | 📨
• مغادره + id | 📯
• مغادره | 📤
ֆ • • • • • • • • • • • • • ֆ
• وقت المجموعه + id | 📮
• مشاهده منشور | 📅
• حفظ | 🔖
• حذف الكليشه | ✂️
• جلب الكليشه | 📌
• تحديث | 📈
• مسح قائمه العام | 📄
• مسح المدراء | 📃
• ادمنيه البوت | 📜
• قائمه العام | 🗒
• المدراء | 📋
• رفع ادمن للبوت | 🔺
ֆ • • • • • • • • • • • • • ֆ
• تنزيل ادمن للبوت | 🔻
• رفع مدير | 🔶
• تنزيل مدير | 🔸
• حظر عام | 🔴
• الغاء العام | 🔵
• الكروبات | 🚻
• اضافه | ⏺
• اذاعه + كليشه | 🛃
• تنظيف + عدد | 🚮
ֆ • • • • • • • • • • • • • ֆ
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
if text:match("^source$") or text:match("^اصدار$") or text:match("^الاصدار$") or text:match("^السورس$") or text:match("^سورس$") then
   
   local text =  [[
<code>اهلا بك في سورس تشاكي</code>

<code>المطورين : </code>

<b> TshAkE TEAM </b>

<code>قناه السورس : </code>

<b>Channel | </b>@lTSHAKEl_CH

<code>رابط Github cli :</code>

https://github.com/moodlIMyIl/TshAkE

<code>رابط Github api :</code>

https://github.com/moodlIMyIl/TshAkEapi
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end

if text:match("^اريد رابط حذف$") or text:match("^رابط حذف$") or text:match("^رابط الحذف$") or text:match("^الرابط حذف$") or text:match("^اريد رابط الحذف$") then
   
   local text =  [[
● - رابط حذف التلي ⬇️ :
● - احذف ولا ترجع عيش حياتك 😪💔
● - https://telegram.org/deactivate
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
  -----------------------------------------------------------------------------------------------
 end
  -----------------------------------------------------------------------------------------------
                                       -- end code --
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateChat") then
    chat = data.chat_
    chats[chat.id_] = chat
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateMessageEdited") then
   local msg = data
  -- vardump(msg)
  	function get_msg_contact(extra, result, success)
	local text = (result.content_.text_ or result.content_.caption_)
    --vardump(result)
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
	end
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or
text:match("[Tt].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end

   if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or
text:match("[Tt].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") then
   if database:get('bot:links:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "● - <code>ممنوع عمل تعديل للروابط</code> ⚠️", 1, 'html')
	end
end
end

   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	
   if database:get('bot:webpage:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "● - <code>ممنوع عمل تعديل للمواقع</code> ⚠️", 1, 'html')
	end
end
end
   if text:match("@") then
   if database:get('bot:tag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:tag:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "● - <code>ممنوع عمل تعديل للمعرفات</code> ⚠️", 1, 'html')
	end
   	if text:match("#") then
   if database:get('bot:hashtag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:hashtag:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "● - <code>ممنوع عمل تعديل للتاكات</code> ⚠️", 1, 'html')

	end
   	if text:match("/") then
   if database:get('bot:cmd:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:cmd:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "● - <code>ممنوع عمل تعديل للشارحه</code> ⚠️", 1, 'html')
	end
end
   	if text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	end
	   if database:get('bot:arabic:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "● - <code>ممنوع عمل تعديل  للغه العربيه</code> ⚠️", 1, 'html')
	end
   end
   if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:english:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "● - <code>ممنوع عمل تعديل  للغه الانكليزيه</code> ⚠️", 1, 'html')
end
end
    end
	end
	if database:get('editmsg'..msg.chat_id_) == 'delmsg' then
        local id = msg.message_id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
              delete_msg(chat,msgs)
              send(msg.chat_id_, 0, 1, "● - <code>ممنوع التعديل هنا</code> ⚠️", 1, 'html')
	elseif database:get('editmsg'..msg.chat_id_) == 'didam' then
	if database:get('bot:editid'..msg.message_id_) then
		local old_text = database:get('bot:editid'..msg.message_id_)
     send(msg.chat_id_, msg.message_id_, 1, '● - `لقد قمت بالتعديل` ❌\n\n● -`رسالتك السابقه ` ⬇️  : \n\n● - [ '..old_text..' ]', 1, 'md')
	end
end 

    getMessage(msg.chat_id_, msg.message_id_,get_msg_contact)
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({ID="GetChats", offset_order_="9223372036854775807", offset_chat_id_=0, limit_=20}, dl_cb, nil)    
  end
  -----------------------------------------------------------------------------------------------
end

--[[                                    Dev @lIMyIl         
   _____    _        _    _    _____    Dev @EMADOFFICAL 
  |_   _|__| |__    / \  | | _| ____|   Dev @h_k_a  
    | |/ __| '_ \  / _ \ | |/ /  _|     Dev @IX00XI
    | |\__ \ | | |/ ___ \|   <| |___    Dev @H_173
    |_||___/_| |_/_/   \_\_|\_\_____|   Dev @lIESIl
              CH > @TshAkETEAM
--]]
