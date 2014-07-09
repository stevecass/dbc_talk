module ActiveRecord
  module Timestamp      
    private
    def timestamp_attributes_for_update #:nodoc:
      [:posttime, :updated_at, :updated_on, :modified_at]
    end
    def timestamp_attributes_for_create #:nodoc:
      [:created, :posttime, :created_at, :created_on]
    end      
  end
end

class Topic < ActiveRecord::Base
	has_many :threads, -> { order(lastpost: :desc) }, class_name: 'MsgThread', :foreign_key => 'topicid'
end

class MsgThread < ActiveRecord::Base
	self.table_name = "threads"
	belongs_to :topic,  foreign_key: 'topicid'
	has_many :messages, -> { order(id: :asc) }, foreign_key: 'threadid'

  def topic_id
    topic.id
  end

  def topic_name
    topic.name
  end

end

class Message < ActiveRecord::Base
	belongs_to :msg_thread, foreign_key: 'threadid', touch: 'lastpost', counter_cache: 'numposts'

	def thread_name
		msg_thread.name
	end

  def topic_name
    msg_thread.topic_name
	end

  def topic_id
    msg_thread.topic_id
  end

  def save_edits(params)
    m.raw_message = params[:raw_message]
    m.message = m.raw_message
    m.save ?  m : nil
  end

end
