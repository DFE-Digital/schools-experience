module ShouldaMatcherDuplicateMessages
protected

  def messages_match?
    super && messages_not_duplicated?
  end

  def messages_not_duplicated?
    matched_messages == matched_messages.uniq
  end
end
