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

  def test_google_priority_p0_to_p4_mapping
    assert_equal 0, @view.google_priority_level(5)
    assert_equal 1, @view.google_priority_level(4)
    assert_equal 2, @view.google_priority_level(3)
    assert_equal 3, @view.google_priority_level(2)
    assert_equal 4, @view.google_priority_level(1)

    m0 = @view.google_priority_meta(5)
    assert_equal 'P0', m0[:code]
    assert_equal '#ef4444', m0[:color]
    assert_equal 5, m0[:db]

    m4 = @view.google_priority_meta(1)
    assert_equal 'P4', m4[:code]
    assert_equal 1, m4[:db]
  end

  def test_aerial_google_maps_embed_url_without_xframe_redirect
    aerial = @view.todo_google_maps_embed_url('HSLU / Uni!', true, 16)
    assert_includes aerial, 'https://www.google.com/maps/embed?origin=mfe&pb=!1m4!2m1!1s'
    assert_includes aerial, 'HSLU+%2F+Uni%21'
    assert_includes aerial, '!5e1!6i16'

    road = @view.todo_google_maps_embed_url('Tödistrasse 27, Zürich', false, 15)
    assert_includes road, '!5e0!6i15'
    assert_nil @view.todo_google_maps_embed_url('   ')
  end

  def test_show_template_has_compact_url_and_interactive_widgets
    erb_src = File.read(File.expand_path('../app/views/todos/_show.html.erb', __dir__))
    refute_includes erb_src, 'Link / Riferimento', 'URL banner should use compact emoji only without long text title'
    assert_includes erb_src, 'data-todo-prio-widget'
    assert_includes erb_src, 'data-todo-progress-slider'
    assert_includes erb_src, 'data-todo-where-widget'
    assert_includes erb_src, 'data-todo-fav-toggle'
    assert_includes erb_src, 'data-todo-project-widget'
    assert_includes erb_src, 'data-todo-title-widget'
    assert_includes erb_src, 'data-todo-tags-widget'
    assert_includes erb_src, 'data-todo-url-widget'
    assert_includes erb_src, 'data-todo-desc-widget'
    assert_includes erb_src, 'data-todo-due-widget'
  end

  def test_modern_bento_form_replaces_year_2000_controls
    form_src = File.read(File.expand_path('../app/views/todos/_form.html.erb', __dir__))
    assert_includes form_src, 'data-todo-modern-form'
    assert_includes form_src, 'name="todo[tag_list]"'
    refute_includes form_src, 'text_field :tags', 'Must use tag_list instead of broken legacy :tags association field'
    refute_includes form_src, 'date_select :due', 'Must use native HTML5 date input instead of 3-select date_select'
    refute_includes form_src, 'datetime_select :hide_until', 'Must use datetime-local instead of 5-select datetime_select'
    assert_includes form_src, 'data-form-prio-widget'
    assert_includes form_src, 'data-form-progress-widget'
    assert_includes form_src, 'data-form-where-widget'
  end

  def test_project_option_label_distinguishes_subagent_projects
    viewer = Struct.new(:id).new(1)
    agent  = Struct.new(:id, :username).new(42, 'palladius.ermete')
    own_proj = Struct.new(:name, :active, :user_id, :user).new('personal', true, 1, viewer)
    agt_proj = Struct.new(:name, :active, :user_id, :user).new('personal', true, 42, agent)
    inactive = Struct.new(:name, :active, :user_id, :user).new('oldproj', false, 1, viewer)

    assert_equal 'personal', @view.project_option_label(own_proj, viewer)
    assert_equal 'personal · palladius.ermete', @view.project_option_label(agt_proj, viewer)
    assert_equal 'oldproj (inattivo)', @view.project_option_label(inactive, viewer)
  end

  def test_ruby19_compatibility_of_rails3_files
    rails3_files = [
      'app/models/todo.rb',
      'app/controllers/todos_controller.rb',
      'app/helpers/todos_helper.rb',
      'app/views/todos/_show.html.erb',
      'app/views/todos/_form.html.erb',
      'app/views/todos/edit.html.erb',
      'app/views/todos/new.html.erb'
    ]
    rails3_files.each do |rel|
      full = File.expand_path("../#{rel}", __dir__)
      src = File.read(full)
      refute_includes src, '&.', "#{rel} must not use &. for Ruby 1.9.3 compatibility"
    end
  end
end
