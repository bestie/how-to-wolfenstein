module ANSI
  module_function

  def left_arrow
    escape("D")
  end

  def right_arrow
    escape("C")
  end

  def save_terminal_state
    escape("?47h")
  end

  def restore_terminal_state
    escape("?47l")
  end

  def cursor_up(n)
    escape("#{n}A")
  end

  def ctrl_c
    3.chr
  end

  def escape(s)
    "#{27.chr}[#{s}"
  end
end
