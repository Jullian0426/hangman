require 'set'

class Hangman
  DICTIONARY_PATH = 'google-10000-english-no-swears.txt'

  attr_reader :secret_word, :guesses_left, :correct_guesses, :incorrect_guesses

  def initialize
    @secret_word = select_random_word
    @guesses_left = 6
    @correct_guesses = []
    @incorrect_guesses = []
  end

  def select_random_word
    words = File.readlines(DICTIONARY_PATH).map(&:chomp)
    words.select { |word| word.length.between?(5, 12) }.sample
  end

  def guess(letter)
    letter = letter.downcase
    return if @correct_guesses.include?(letter) || @incorrect_guesses.include?(letter)

    if @secret_word.include?(letter)
      @correct_guesses << letter
    else
      @incorrect_guesses << letter
      @guesses_left -= 1
    end
  end

  def display_progress
    @secret_word.chars.map { |char| @correct_guesses.include?(char) ? char : '_' }.join(' ')
  end

  def game_over?
    @guesses_left <= 0 || !display_progress.include?('_')
  end
end

# Start a new game
game = Hangman.new
puts "Welcome to Hangman!"

# Main game loop
until game.game_over?
  puts "\nWord: #{game.display_progress}"
  puts "Guesses left: #{game.guesses_left}"
  puts "Incorrect guesses: #{game.incorrect_guesses.join(', ')}"
  print "Enter your guess: "
  guess = gets.chomp
  game.guess(guess)
end

if game.guesses_left > 0
  puts "Congratulations! You've guessed the word: #{game.secret_word}"
else
  puts "Game over! The word was: #{game.secret_word}"
end