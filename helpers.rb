helpers do
  def board_time(a_time)
    a_time.nil? ? '' : a_time.strftime('%d-%b-%y %H:%M:%S')
  end

  def trunc_nick(nickname)
    max_len = 12
    if nickname.nil? || nickname.empty? || nickname.length <= max_len
      nickname 
    else 
      nickname[0..max_len] + "..."
    end
  end

  def cycle
    @_cycle ||= reset_cycle
    @_cycle = [@_cycle.pop] + @_cycle
    @_cycle.first
  end

  def reset_cycle
    @_cycle = %w(even odd)
  end
end
