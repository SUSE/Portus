# frozen_string_literal: true

# Outputs the evaluated object from the first argument.

# rubocop:disable Security/Eval
puts eval(ARGV.first)
# rubocop:enable Security/Eval
