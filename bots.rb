# Encoding: UTF-8
require 'twitter_ebooks'
require 'json'

# Information about a particular Twitter user we know
class UserInfo
  attr_reader :username

  # @return [Integer] how many times we can pester this user unprompted
  attr_accessor :pesters_left

  # @param username [String]
  def initialize(username)
    @username = username
    @pesters_left = 1
  end
end

class CloneBot < Ebooks::Bot
  attr_accessor :original, :model, :model_path

  def configure
    # Configuration for all CloneBots
    self.blacklist = [
        'kylelehk', 'friedrichsays', 'Sudieofna', 'tnietzschequote', 'NerdsOnPeriod', 'FSR', 'BafflingQuotes', 'Obey_Nxme', 'raphisblackbot'
    ]

    self.delay_range = 1..6
    @userinfo = {}

    @word_blacklist = [
        'rape', 'rapes', 'raped', 'raping', 'rapist', 'rapists',
        'pedo', 'pedos', 'pedophile', 'pedophiles', 'paedo', 'paedos', 'paedophile', 'paedophiles',
        'child porn', 'child pornography', 'molest', 'molests'
    ]

    @reply_blacklist = [
        'gamergate', 'stopgamergate', '8chan', 'terf', 'tfyc', 'the fine young capitalists',
        'yiannopoulos', 'zoe quinn', 'brianna wu', 'ethan ralph', 'ralphretort', 'sam hyde',
        'dramatica'
    ]
  end

  def top100;
    @top100 ||= model.keywords.take(100);
  end

  def top20;
    @top20 ||= model.keywords.take(20);
  end

  def on_startup
    load_model!

    scheduler.cron '*/20 * * * *' do
      # Every 20 minutes, post a single tweet
      tweet_text = model.make_statement

      count = 0
      while @word_blacklist.any? { |word| tweet_text.downcase.include?(word) } && count < 5
        log "Blacklisted word on attempt #{count}. Generating new tweet."
        tweet_text = model.make_statement
        count = count + 1
      end

      if count == 5
        tweet_text = self_censored
      end

      tweet(tweet_text)
    end
  end

  def on_message(dm)

    delay do
      load_model!
      tweet_text = model.make_response(dm.text)

      count = 0
      while @word_blacklist.any? { |word| tweet_text.downcase.include?(word) } && count < 5
        log "Blacklisted word on attempt #{count}. Generating new tweet."
        tweet_text = model.make_response(dm.text)
        count = count + 1
      end

      if count == 5
        tweet_text = self_censored
      end

      reply(dm, tweet_text)
    end

  end

  def self_censored
    log 'Could not generate tweet without blacklisted words. Self-censoring...'
    '😶' # face without mouth emoji
  end

  def on_mention(tweet)

    # Force bot to not reply to blacklisted accounts
    if blacklisted?(tweet.user.screen_name)
      log "Ignoring blacklisted user @#{tweet.user.screen_name}"
    else
      # Become more inclined to pester a user when they talk to us
      userinfo(tweet.user.screen_name).pesters_left += 1

      delay do
        load_model!
        tweet_text = model.make_response(meta(tweet).mentionless, meta(tweet).limit)

        combined_blacklist = @word_blacklist + @reply_blacklist

        count = 0
        while combined_blacklist.any? { |word| tweet_text.downcase.include?(word) } && count < 5
          log "Blacklisted word on attempt #{count}. Generating new tweet."
          tweet_text = model.make_response(meta(tweet).mentionless, meta(tweet).limit)
          count = count + 1
        end

        if count == 5
          tweet_text = self_censored
        end

        reply(tweet, tweet_text)
      end
    end

  end

  def on_timeline(tweet)
    return if tweet.retweeted_status?
    return unless can_pester?(tweet.user.screen_name)

    tokens = Ebooks::NLP.tokenize(tweet.text)

    interesting = tokens.find { |t| top100.include?(t.downcase) }
    very_interesting = tokens.find_all { |t| top20.include?(t.downcase) }.length > 2

    delay do
      if very_interesting
        favorite(tweet) if rand < 0.5
        retweet(tweet) if rand < 0.1
        if rand < 0.01
          userinfo(tweet.user.screen_name).pesters_left -= 1
          load_model!
          reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
        end
      elsif interesting
        favorite(tweet) if rand < 0.05
        if rand < 0.001
          userinfo(tweet.user.screen_name).pesters_left -= 1
          load_model!
          reply(tweet, model.make_response(meta(tweet).mentionless, meta(tweet).limit))
        end
      end
    end
  end

  # Find information we've collected about a user
  # @param username [String]
  # @return [Ebooks::UserInfo]
  def userinfo(username)
    @userinfo[username] ||= UserInfo.new(username)
  end

  # Check if we're allowed to send unprompted tweets to a user
  # @param username [String]
  # @return [Boolean]
  def can_pester?(username)
    userinfo(username).pesters_left > 0
  end

  # Only follow our original user or people who are following our original user
  # @param username [Twitter::User]
  def can_follow?(username)
    @original.nil? || username == @original || twitter.friendship?(username, @original)
  end

  def favorite(tweet)
    if can_follow?(tweet.user.screen_name)
      super(tweet)
    else
      log "Unfollowing @#{tweet.user.screen_name}"
      twitter.unfollow(tweet.user.screen_name)
    end
  end

  def on_follow(user)
    if can_follow?(user.screen_name)
      follow(user.screen_name)
    else
      log "Not following @#{user.screen_name}"
    end
  end

  private
  def load_model!
    # return if @model

    @model_path ||= "model/#{original}.model"

    log "Loading model #{model_path}"
    @model = Ebooks::Model.load(model_path)
  end
end

keys_file = File.read('keys.json')
keys = JSON.parse(keys_file)

CloneBot.new('iglvzx_ebooks') do |bot|
  bot.consumer_key = keys['consumer_key']
  bot.consumer_secret = keys['consumer_secret']
  bot.access_token = keys['access_token']
  bot.access_token_secret = keys['access_token_secret']
  bot.original = 'iglvzx'
end
