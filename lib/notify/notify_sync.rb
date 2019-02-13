class NotifySync
  attr_accessor :remote_templates, :local_templates
  attr_writer :client

  TEMPLATE_PATH = [Rails.root, "app", "notify", "notify_email"].freeze

  def initialize
    self.local_templates = {}
    self.remote_templates = {}

    load_local_templates
    load_remote_templates
  end

  def compare(show_diff)
    local_templates.each do |path, local_template|
      # check the remote template is present based on the local template's guid
      unless (rt = remote_templates.delete(local_template[:template_id]))
        puts "#{local_template[:template_id]} Missing remote template"
        next
      end

      # Check the two templates are the same, diff if they're not
      if local_template[:body] == reencode(rt.body)
        puts "#{local_template[:template_id]} Matches"
      elsif show_diff
        puts "#{local_template[:template_id]} Doesn't match"
        puts path
        puts "-------------"
        puts diff(path, reencode(rt.body))
        puts "-------------"
      else
        puts "#{local_template[:template_id]} Doesn't match"
      end
    end

    # Any templates remaining aren't present locally
    if remote_templates.size.positive?
      remote_templates.each do |_, template|
        puts "#{template.id} Missing local template"
      end
    end
  end

  def pull
    remote_templates.each do |template_id, rt|
      File.write(
        File.join(
          TEMPLATE_PATH,
          [rt.name.gsub(/[\ \-]/, "").underscore, template_id, 'md'].join('.'),
        ),
        reencode(rt.body)
      )
    end
  end

private

  # extract the body text, standardise newlines and chomp trailing lines
  def reencode(body)
    body.encode(body.encoding, universal_newline: true).chomp
  end

  def diff(local_path, remote_body)
    `echo "#{remote_body}" | diff - #{local_path}`
  end

  def client
    @client ||= Notifications::Client.new(Rails.application.credentials[:notify_api_key])
  end

  def load_local_templates
    Dir.glob(File.join(TEMPLATE_PATH, "*.md")).each do |path|
      self.local_templates[path] = {
        template_id: path.match(/\.(?<template_id>[A-z0-9\-]+)\.md$/)[:template_id],
        body: File.read(path).chomp
      }
    end
  end

  def load_remote_templates
    self.remote_templates = client.get_all_templates.collection.index_by(&:id)
  end
end
