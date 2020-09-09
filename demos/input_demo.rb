require "io/console"

input_buffer = []
output_buffer = []

IO.console.raw do |io|
  # Clear and save the screen
  io.write("\e[?47h")

  io.write("io/console demo - the last 10 characters you typed:\r\n")

  loop do
    input_buffer << io.getch
    break if input_buffer.last == ?\C-c

    output_buffer = []

    input_buffer.reverse.take(10).each_with_index do |char, i|
      output_buffer << "#{i}:  #{char} | #{char.ord}                      \r\n"
    end

    io.write(output_buffer.join)
    io.write("\e[" + output_buffer.length.to_s + "A")
  end

  # Restore the saved terminal state
  io.write("\e[?47l")

  # Put the cursor back where it started
  io.write("\n" * output_buffer.length)
end
