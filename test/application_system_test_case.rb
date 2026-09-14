require "test_helper"
require "capybara/cuprite"

Capybara.disable_animation = true

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite,
    using: :chrome,
    screen_size: [ 500, 1200 ],
    options: {
      js_errors: true,
      process_timeout: 30,
      headless: "new"
      # no_sandbox: true,
      # disable_gpu: true,
      # disable_dev_shm_usage: true,
      # disable_extensions: true,
      # mute_audio: true,
      # disable_translate: true,
      # disable_notifications: true
    }

  setup do
    @console_messages = []
    page.driver.browser.on("Runtime.consoleAPICalled") do |params|
      @console_messages << format_console_message(params["args"])
    end
    page.driver.browser.on("Log.entryAdded") do |params|
      entry = params["entry"]
      @console_messages << "[#{entry["level"]}] #{entry["text"]} (#{entry["url"]}:#{entry["lineNumber"]})"
    end
  end

  teardown do
    if !passed? && @console_messages.present?
      puts "\n#{'=' * 70}"
      puts "JavaScript console output:"
      puts "-" * 70
      @console_messages.each { |message| puts message }
      puts "=" * 70
    end
  end

  def fill_in(locator, with:, **options)
    sleep 0.5
    super
  end

  def click_on(*args)
    sleep 0.5
    super
  end

  private

  def format_console_message(args)
    args.map { |arg| arg["value"] || arg["description"] || arg.inspect }.join(" ")
  end
end
