#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'erb'
require 'date'
require 'cgi'

class String
  def html_safe
    self
  end unless method_defined?(:html_safe)

  def blank?
    strip.empty?
  end unless method_defined?(:blank?)

  def presence
    blank? ? nil : self
  end unless method_defined?(:presence)
end

class NilClass
  def blank?
    true
  end unless method_defined?(:blank?)

  def presence
    nil
  end unless method_defined?(:presence)

  def try(*_args)
    nil
  end unless method_defined?(:try)
end

class Object
  def try(method_name, *args)
    respond_to?(method_name) ? send(method_name, *args) : nil
  end unless method_defined?(:try)
end

require_relative '../app/helpers/todos_helper'

class TestTodosShowHelper < Minitest::Test
  class DummyView
    include TodosHelper

    def content_tag(tag, content, opts = {})
      cls = opts[:class] ? " class=\"#{opts[:class]}\"" : ''
      "<#{tag}#{cls}>#{content}</#{tag}>"
    end

    def link_to(body, url, opts = {})
      cls = opts[:class] ? " class=\"#{opts[:class]}\"" : ''
      tgt = opts[:target] ? " target=\"#{opts[:target]}\"" : ''
      rel = opts[:rel] ? " rel=\"#{opts[:rel]}\"" : ''
      "<a href=\"#{url}\"#{cls}#{tgt}#{rel}>#{body}</a>"
    end

    def todo_path(todo)
      "/todos/#{todo.id}"
    end
  end

  TodoStub = Struct.new(:id, :name, :url, :due, :description, :done_flag, :project) do
    def done?
      !!done_flag
    end

    def overdue?
      due && due < Date.today
    end

    def close_due?
      due && due < Date.today + 2
    end
  end

  ProjectStub = Struct.new(:name)

  def setup
    @view = DummyView.new
  end

  def test_clickable_url_with_github_badge_and_xss_guard
    todo = TodoStub.new(242, 'Reader Mode', 'https://github.com/palladius/kids-own-stories/issues/4', Date.today, '', false, nil)
    html = @view.render_todo_clickable_url(todo)
    assert_includes html, 'href="https://github.com/palladius/kids-own-stories/issues/4"'
    assert_includes html, 'target="_blank"'
    assert_includes html, 'GitHub Issue #4 · palladius/kids-own-stories'

    bad_todo = TodoStub.new(243, 'XSS', 'javascript:alert(1)', Date.today, '', false, nil)
    assert_nil @view.render_todo_clickable_url(bad_todo)
  end

  def test_overdue_due_badge_is_red
    overdue_todo = TodoStub.new(242, 'Late task', nil, Date.today - 3, '', false, nil)
    html = @view.render_todo_show_due(overdue_todo)
    assert_includes html, 'is-overdue'
    assert_includes html, 'Scaduto (3 giorni fa)'

    future_todo = TodoStub.new(244, 'Future task', nil, Date.today + 10, '', false, nil)
    f_html = @view.render_todo_show_due(future_todo)
    assert_includes f_html, 'is-future'
    refute_includes f_html, 'is-overdue'
  end

  def test_description_formatting_and_provenance_split
    todo = TodoStub.new(
      242,
      'Kids Stories',
      'https://github.com/palladius/kids-own-stories/issues/4',
      Date.today,
      "Implementare modalita didattica. Riferimento GHI #4 e https://ricc.rocks/demo.\n\nCollected via CLI on mini-lobby (Co-authored-by: Ermete)",
      false,
      nil
    )
    prose, provenance = @view.format_todo_description_parts(todo)
    assert_includes prose, 'href="https://github.com/palladius/kids-own-stories/issues/4"'
    assert_includes prose, 'href="https://ricc.rocks/demo"'
    assert_equal 'Collected via CLI on mini-lobby (Co-authored-by: Ermete)', provenance
  end

  def test_dependency_item_renders_clean_link
    sub = TodoStub.new(300, 'Subtask long title without overflow', nil, Date.today - 1, '', false, ProjectStub.new('personal'))
    html = @view.render_dependency_item(sub, 'Child')
    assert_includes html, 'href="/todos/300"'
    assert_includes html, 'todo-dep-item is-active is-overdue'
    assert_includes html, 'Subtask long title without overflow'
  end

  def test_ruby19_compatibility_of_rails3_files
    ['app/helpers/todos_helper.rb', 'app/views/todos/_show.html.erb'].each do |rel|
      full = File.expand_path("../#{rel}", __dir__)
      refute_includes File.read(full), '&.', "#{rel} must not use &. for Ruby 1.9.3 compatibility"
    end
  end
end
