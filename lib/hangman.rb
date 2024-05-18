require 'set'
require 'yaml'

class Hangman
  DICTIONARY_PATH = 'google-10000-english-no-swears.txt'

  attr_reader :secret_word, :guesses_left, :correct_guesses, :incorrect_guesses

  def initialize(secret_word: nil, guesses_left: 6, correct_guesses: [], incorrect_guesses: [])
    @secret_word = secret_word || select_random_word
    @guesses_left = guesses_left
    @correct_guesses = correct_guesses
    @incorrect_guesses = incorrect_guesses
  end

  def self.load_from_file(filename)
    data = YAML.load_file(filename)
    new(
      secret_word: data[:secret_word],
      guesses_left: data[:guesses_left],
      correct_guesses: data[:correct_guesses],
      incorrect_guesses: data[:incorrect_guesses]
    )
  end

  def save_to_file(filename)
    data = {
      secret_word: @secret_word,
      guesses_left: @guesses_left,
      correct_guesses: @correct_guesses,
      incorrect_guesses: @incorrect_guesses
    }
    File.write(filename, data.to_yaml)
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

  def valid_guess?(input)
    input.length == 1 && input =~ /[a-zA-Z]/
  end
end

def play_game
  puts "Welcome to Hangman!"

  # Ask the player if they want to load a saved game
  print "Do you want to load a saved game? (yes/no): "
  load_game = gets.chomp.downcase == 'yes'

  if load_game
    print "Enter the filename: "
    filename = gets.chomp
    game = Hangman.load_from_file(filename)
  else
    game = Hangman.new
  end

  until game.game_over?
    puts "\nWord: #{game.display_progress}"
    puts "Guesses left: #{game.guesses_left}"
    puts "Incorrect guesses: #{game.incorrect_guesses.join(', ')}"
    print "Enter your guess (or type 'save' to save the game): "
    input = gets.chomp

    if input == 'save'
      print "Enter the filename to save the game: "
      filename = gets.chomp
      game.save_to_file(filename)
      puts "Game saved to #{filename}."
      break
    end

    unless game.valid_guess?(input)
      puts "Invalid input. Please enter a single letter."
      next
    end

    game.guess(input)
  end

  if game.guesses_left > 0 && !game.game_over?
    puts "Game saved. Exiting..."
  elsif game.guesses_left > 0
    puts "Congratulations! You've guessed the word: #{game.secret_word}"
  else
    puts "Game over! The word was: #{game.secret_word}"
  end
end

play_game
