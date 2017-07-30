redis = (loadfile "redis.lua")()
redis = redis.connect('127.0.0.1', 6379)

function dl_cb(arg, data)
end
function get_admin ()
	if redis:get('botBOT-IDadminset') then
		return true
	else
   		print("\n\27[32m  áÇÒãå ˜ÇÑ˜ÑÏ ÕÍíÍ ¡ ÝÑÇãíä æ ÇãæÑÇÊ ãÏíÑíÊí ÑÈÇÊ ÊÈáíÛ Ñ <<\n                    ÊÚÑíÝ ˜ÇÑÈÑí Èå ÚäæÇä ãÏíÑ ÇÓÊ\n\27[34m                   ÇíÏí ÎæÏ ÑÇ Èå ÚäæÇä ãÏíÑ æÇÑÏ ˜äíÏ\n\27[32m    ÔãÇ ãí ÊæÇäíÏ ÇÒ ÑÈÇÊ ÒíÑ ÔäÇÓå ÚÏÏí ÎæÏ ÑÇ ÈÏÓÊ ÇæÑíÏ\n\27[34m        ÑÈÇÊ:       @id_ProBot")
    		print("\n\27[32m >> Tabchi Bot need a fullaccess user (ADMIN)\n\27[34m Imput Your ID as the ADMIN\n\27[32m You can get your ID of this bot\n\27[34m                 @id_ProBot")
    		print("\n\27[36m                      : ÔäÇÓå ÚÏÏí ÇÏãíä ÑÇ æÇÑÏ ˜äíÏ << \n >> Imput the Admin ID :\n\27[31m                 ")
    		admin=io.read()
		redis:del("botBOT-IDadmin")
    		redis:sadd("botBOT-IDadmin", admin)
		redis:set('botBOT-IDadminset',true)
  	end
  	return print("\n\27[36m     ADMIN ID |\27[32m ".. admin .." \27[36m| ÔäÇÓå ÇÏãíä")
end
function get_bot (i, naji)
	function bot_info (i, naji)
		redis:set("botBOT-IDid",naji.id_)
		if naji.first_name_ then
			redis:set("botBOT-IDfname",naji.first_name_)
		end
		if naji.last_name_ then
			redis:set("botBOT-IDlanme",naji.last_name_)
		end
		redis:set("botBOT-IDnum",naji.phone_number_)
		return naji.id_
	end
	tdcli_function ({ID = "GetMe",}, bot_info, nil)
end
function reload(chat_id,msg_id)
	loadfile("./bot-BOT-ID.lua")()
	send(chat_id, msg_id, "<i>ÈÇ ãæÝÞíÊ ÇäÌÇã ÔÏ.</i>")
end
function is_naji(msg)
    local var = false
	local hash = 'botBOT-IDadmin'
	local user = msg.sender_user_id_
    local Naji = redis:sismember(hash, user)
	if Naji then
		var = true
	end
	return var
end
function writefile(filename, input)
	local file = io.open(filename, "w")
	file:write(input)
	file:flush()
	file:close()
	return true
end
function process_join(i, naji)
	if naji.code_ == 429 then
		local message = tostring(naji.message_)
		local Time = message:match('%d+')
		redis:setex("botBOT-IDmaxjoin", tonumber(Time), true)
	else
		redis:srem("botBOT-IDgoodlinks", i.link)
		redis:sadd("botBOT-IDsavedlinks", i.link)
	end
end
function process_link(i, naji)
	if (naji.is_group_ or naji.is_supergroup_channel_) then
		redis:srem("botBOT-IDwaitelinks", i.link)
		redis:sadd("botBOT-IDgoodlinks", i.link)
	elseif naji.code_ == 429 then
		local message = tostring(naji.message_)
		local Time = message:match('%d+')
		redis:setex("botBOT-IDmaxlink", tonumber(Time), true)
	else
		redis:srem("botBOT-IDwaitelinks", i.link)
	end
end
function find_link(text)
	if text:match("https://telegram.me/joinchat/%S+") or text:match("https://t.me/joinchat/%S+") or text:match("https://telegram.dog/joinchat/%S+") then
		local text = text:gsub("t.me", "telegram.me")
		local text = text:gsub("telegram.dog", "telegram.me")
		for link in text:gmatch("(https://telegram.me/joinchat/%S+)") do
			if not redis:sismember("botBOT-IDalllinks", link) then
				redis:sadd("botBOT-IDwaitelinks", link)
				redis:sadd("botBOT-IDalllinks", link)
			end
		end
	end
end
function add(id)
	local Id = tostring(id)
	if not redis:sismember("botBOT-IDall", id) then
		if Id:match("^(%d+)$") then
			redis:sadd("botBOT-IDusers", id)
			redis:sadd("botBOT-IDall", id)
		elseif Id:match("^-100") then
			redis:sadd("botBOT-IDsupergroups", id)
			redis:sadd("botBOT-IDall", id)
		else
			redis:sadd("botBOT-IDgroups", id)
			redis:sadd("botBOT-IDall", id)
		end
	end
	return true
end
function rem(id)
	local Id = tostring(id)
	if redis:sismember("botBOT-IDall", id) then
		if Id:match("^(%d+)$") then
			redis:srem("botBOT-IDusers", id)
			redis:srem("botBOT-IDall", id)
		elseif Id:match("^-100") then
			redis:srem("botBOT-IDsupergroups", id)
			redis:srem("botBOT-IDall", id)
		else
			redis:srem("botBOT-IDgroups", id)
			redis:srem("botBOT-IDall", id)
		end
	end
	return true
end
function send(chat_id, msg_id, text)
	tdcli_function ({
		ID = "SendMessage",
		chat_id_ = chat_id,
		reply_to_message_id_ = msg_id,
		disable_notification_ = 1,
		from_background_ = 1,
		reply_markup_ = nil,
		input_message_content_ = {
			ID = "InputMessageText",
			text_ = text,
			disable_web_page_preview_ = 1,
			clear_draft_ = 0,
			entities_ = {},
			parse_mode_ = {ID = "TextParseModeHTML"},
		},
	}, dl_cb, nil)
end
get_admin()
function tdcli_update_callback(data)
	if data.ID == "UpdateNewMessage" then
		if not redis:get("botBOT-IDmaxlink") then
			if redis:scard("botBOT-IDwaitelinks") ~= 0 then
				local links = redis:smembers("botBOT-IDwaitelinks")
				for x,y in pairs(links) do
					if x == 11 then redis:setex("botBOT-IDmaxlink", 60, true) return end
					tdcli_function({ID = "CheckChatInviteLink",invite_link_ = y},process_link, {link=y})
				end
			end
		end
		if not redis:get("botBOT-IDmaxjoin") then
			if redis:scard("botBOT-IDgoodlinks") ~= 0 then 
				local links = redis:smembers("botBOT-IDgoodlinks")
				for x,y in pairs(links) do
					tdcli_function({ID = "ImportChatInviteLink",invite_link_ = y},process_join, {link=y})
					if x == 5 then redis:setex("botBOT-IDmaxjoin", 60, true) return end
				end
			end
		end
		local msg = data.message_
		local bot_id = redis:get("botBOT-IDid") or get_bot()
		if (msg.sender_user_id_ == 777000 or msg.sender_user_id_ == 178220800) then
			for k,v in pairs(redis:smembers('botBOT-IDadmin')) do
				tdcli_function({
					ID = "ForwardMessages",
					chat_id_ = v,
					from_chat_id_ = msg.chat_id_,
					message_ids_ = {[0] = msg.id_},
					disable_notification_ = 0,
					from_background_ = 1
				}, dl_cb, nil)
			end
		end
		if tostring(msg.chat_id_):match("^(%d+)") then
			if not redis:sismember("botBOT-IDall", msg.chat_id_) then
				redis:sadd("botBOT-IDusers", msg.chat_id_)
				redis:sadd("botBOT-IDall", msg.chat_id_)
			end
		end
		add(msg.chat_id_)
		if msg.date_ < os.time() - 150 then
			return false
		end
		if msg.content_.ID == "MessageText" then
			local text = msg.content_.text_
			local matches
			find_link(text)
			if is_naji(msg) then
				if text:match("^(ÇÝÒæÏä ãÏíÑ) (%d+)$") then
					local matches = text:match("%d+")
					if redis:sismember('botBOT-IDadmin', matches) then
						return send(msg.chat_id_, msg.id_, "<i>˜ÇÑÈÑ ãæÑÏ äÙÑ ÏÑ ÍÇá ÍÇÖÑ ãÏíÑ ÇÓÊ.</i>")
					elseif redis:sismember('botBOT-IDmod', msg.sender_user_id_) then
						return send(msg.chat_id_, msg.id_, "ÔãÇ ÏÓÊÑÓí äÏÇÑíÏ.")
					else
						redis:sadd('botBOT-IDadmin', matches)
						redis:sadd('botBOT-IDmod', matches)
						return send(msg.chat_id_, msg.id_, "<i>ãÞÇã ˜ÇÑÈÑ Èå ãÏíÑ ÇÑÊÞÇ íÇÝÊ</i>")
					end
				elseif text:match("^(ÇÝÒæÏä ãÏíÑ˜á) (%d+)$") then
					local matches = text:match("%d+")
					if redis:sismember('botBOT-IDmod',msg.sender_user_id_) then
						return send(msg.chat_id_, msg.id_, "ÔãÇ ÏÓÊÑÓí äÏÇÑíÏ.")
					end
					if redis:sismember('botBOT-IDmod', matches) then
						redis:srem("botBOT-IDmod",matches)
						redis:sadd('botBOT-IDadmin'..tostring(matches),msg.sender_user_id_)
						return send(msg.chat_id_, msg.id_, "ãÞÇã ˜ÇÑÈÑ Èå ãÏíÑíÊ ˜á ÇÑÊÞÇ íÇÝÊ .")
					elseif redis:sismember('botBOT-IDadmin',matches) then
						return send(msg.chat_id_, msg.id_, 'ÏÑÍÇá ÍÇÖÑ ãÏíÑ åÓÊäÏ.')
					else
						redis:sadd('botBOT-IDadmin', matches)
						redis:sadd('botBOT-IDadmin'..tostring(matches),msg.sender_user_id_)
						return send(msg.chat_id_, msg.id_, "˜ÇÑÈÑ Èå ãÞÇã ãÏíÑ˜á ãäÕæÈ ÔÏ.")
					end
				elseif text:match("^(ÍÐÝ ãÏíÑ) (%d+)$") then
					local matches = text:match("%d+")
					if redis:sismember('botBOT-IDmod', msg.sender_user_id_) then
						if tonumber(matches) == msg.sender_user_id_ then
								redis:srem('botBOT-IDadmin', msg.sender_user_id_)
								redis:srem('botBOT-IDmod', msg.sender_user_id_)
							return send(msg.chat_id_, msg.id_, "ÔãÇ ÏíÑ ãÏíÑ äíÓÊíÏ.")
						end
						return send(msg.chat_id_, msg.id_, "ÔãÇ ÏÓÊÑÓí äÏÇÑíÏ.")
					end
					if redis:sismember('botBOT-IDadmin', matches) then
						if  redis:sismember('botBOT-IDadmin'..msg.sender_user_id_ ,matches) then
							return send(msg.chat_id_, msg.id_, "ÔãÇ äãí ÊæÇäíÏ ãÏíÑí ˜å Èå ÔãÇ ãÞÇã ÏÇÏå ÑÇ ÚÒá ˜äíÏ.")
						end
						redis:srem('botBOT-IDadmin', matches)
						redis:srem('botBOT-IDmod', matches)
						return send(msg.chat_id_, msg.id_, "˜ÇÑÈÑ ÇÒ ãÞÇã ãÏíÑíÊ ÎáÚ ÔÏ.")
					end
					return send(msg.chat_id_, msg.id_, "˜ÇÑÈÑ ãæÑÏ äÙÑ ãÏíÑ äãí ÈÇÔÏ.")
					return send(msg.chat_id_, 0, text)
				elseif (text:match("^(ÇÑÓÇá Èå) (.*)$") and msg.reply_to_message_id_ ~= 0) then
					local matches = text:match("^ÇÑÓÇá Èå (.*)$")
					local naji
					if matches:match("^(åãå)$") then
						naji = "botBOT-IDall"
					elseif matches:match("^(ÎÕæÕí)") then
						naji = "botBOT-IDusers"
					elseif matches:match("^(Ñæå)$") then
						naji = "botBOT-IDgroups"
					elseif matches:match("^(ÓæÑÑæå)$") then
						naji = "botBOT-IDsupergroups"
					else
						return true
					end
					local list = redis:smembers(naji)
					local id = msg.reply_to_message_id_
					for i, v in pairs(list) do
						tdcli_function({
							ID = "ForwardMessages",
							chat_id_ = v,
							from_chat_id_ = msg.chat_id_,
							message_ids_ = {[0] = id},
							disable_notification_ = 1,
							from_background_ = 1
						}, dl_cb, nil)
					end
					return send(msg.chat_id_, msg.id_, "<i>ÈÇ ãæÝÞíÊ ÝÑÓÊÇÏå ÔÏ</i>")
	end
end
