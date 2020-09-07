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

  def cursor_top_left
    escape("1;1H")
  end

  def red(s)
    escape("40;31m") + s + escape("0m")
  end

  def black_on_red(s)
    escape("41;30m") + s + escape("0m")
  end

  def green(s)
    escape("40;32m") + s + escape("0m")
  end

  def black_on_green(s)
    escape("42;30m") + s + escape("0m")
  end

  def hide_cursor
    escape("?25l")
  end

  def unhide_cursor
    escape("?25h")
  end

  def ctrl_c
    3.chr
  end

  def escape(s)
    "#{27.chr}[#{s}"
  end
end
