require 'sinatra' 
require 'sinatra/activerecord'
require './mods'
require './helpers'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     '127.0.0.1',
  port:     '1112',
  database: 'mumsnet',
  encoding: 'latin1'
)
ActiveRecord::Base.include_root_in_json = false

def send_json(a_status, json) 
  content_type 'application/json'
  status a_status
  body json
  json
end

get '/topics' do
  topics =  Topic.all.order('name')
  request.accept.each do |type|
    type=type.downcase.strip
    case type
      when 'text/html'
        halt haml :topics, locals: {topics: topics}
      else
        halt send_json(200, topics.to_json)
    end
  end
end
  
get '/topics/:id' do
  Topic.find(params[:id]).to_json
end

get '/topics/:topicid/threads' do
  topic = Topic.find(params[:topicid])
  
  request.accept.each do |type|
    type=type.downcase.strip
    case type
      when 'text/html'
        halt haml :threads, locals: {topic: topic}
      else
        halt send_json(200, topic.to_json(include: :threads))
    end
  end

end

get '/topics/:topicid/threads/:id' do
  MsgThread.where(id: params[:id]).to_json
end

get '/topics/:topicid/threads/:id/messages' do
  msg_thread = MsgThread.find(params[:id])
  request.accept.each do |type|
    type=type.downcase.strip
    case type
      when 'text/html'
        halt haml :messages, locals: {thread: msg_thread}
      else
        halt send_json(200, msg_thread.to_json(include: :messages))
    end
  end

end

post '/topics/:topicid/threads' do
  thr = MsgThread.create(name: params[:name], 
                    topicid: params[:topicid], 
                    creationuser: params[:creationuser], 
                    firstpost_nick: params[:nickname],
                    lastpost_nick: params[:nickname])
  if(thr.save)
    thr.lastpost = thr.created
    thr.save
    send_json(201, thr.to_json)
  else
    status 500
  end
end

post '/topics/:topicid/threads/:threadid/messages' do
  m = Message.create(userid: params[:userid], nickname: params[:nickname], 
                     threadid: params[:threadid], raw_message: params[:raw_message])
  m.message = m.raw_message
  m.ip = request.ip

  if (m.save)
    send_json(201, m.to_json)
  else
    status 500
  end
end

patch '/topics/:topicid/threads/:threadid/messages/:id' do
  m = Message.find(params[:id])
  if m.nil?
    status 404
  else
    m.save_edits(params)
    send_json((m.nil ? 200 : 500), m.to_json)
  end
end

delete '/topics/:topicid/threads/:threadid/messages/:id' do
  status (Message.destroy params[:id]) ? 204 : 404
end

get '/messages/latest' do
  Message.limit(10).includes(:msg_thread => :topic).order('id desc').to_json(methods: [:thread_name, :topic_id, :topic_name])
end

get '/messages/newer/:id' do
  Message.where('id > ?', params[:id]).limit(10).includes(:msg_thread => :topic).order('id desc').to_json(methods: [:thread_name, :topic_id, :topic_name])
end
