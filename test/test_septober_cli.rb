#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"

ENV["SEPTOBER_CLI_NO_AUTORUN"] = "1"
load File.expand_path("../bin/septober-cli", __dir__)

class TestSeptoberCli < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("septober-cli-test")
    @yaml_file = File.join(@tmpdir, ".septober.yml")
    File.write(@yaml_file, <<~YAML)
      local: &DEVEL_LOCAL
        site: "http://localhost:8080/api/"
        user: "guest"
        password: "guest_password"
      remote: &cloudrun
        site: "https://example.com/api/"
        user: "palladiusbonton@gmail.com"
        password: "prod_password"
      septober:
        <<: *cloudrun
      agents:
        ermete:
          user: "palladius.ermete"
          password: "pwd-ermete"
          icon: "🚛"
          host: "mini-lobby"
    YAML
  end

  def teardown
    FileUtils.remove_entry(@tmpdir) if @tmpdir && File.exist?(@tmpdir)
  end

  def test_load_config_default_with_yaml_anchors
    cfg = load_config(conf_path: @yaml_file)
    assert_equal "septober", cfg["env"]
    assert_equal "https://example.com/api/", cfg["site"]
    assert_equal "palladiusbonton@gmail.com", cfg["user"]
    assert_equal "prod_password", cfg["password"]
  end

  def test_load_config_local_flag
    cfg = load_config(conf_path: @yaml_file, target_env: "local")
    assert_equal "local", cfg["env"]
    assert_equal "http://localhost:8080/api/", cfg["site"]
    assert_equal "guest", cfg["user"]
  end

  def test_load_config_agent_profile
    cfg = load_config(conf_path: @yaml_file, target_agent: "ermete")
    assert_equal "palladius.ermete", cfg["user"]
    assert_equal "pwd-ermete", cfg["password"]
    assert_equal "ermete", cfg["agent"]
    assert_equal "🚛", cfg["agent_icon"]
  end

  def test_extract_todo_id_from_number_and_url
    assert_equal 235, extract_todo_id("235")
    assert_equal 235, extract_todo_id("#235")
    assert_equal 235, extract_todo_id("https://septober-mysql-2-3-12-prova-134140879415.europe-central2.run.app/todos/235")
  end

  def test_format_priority
    assert_includes format_priority(5), "Urgent"
    assert_includes format_priority(4), "High"
    assert_includes format_priority(3), "Med"
    assert_includes format_priority(2), "Low"
    assert_includes format_priority(1), "Backlog"
  end
end
