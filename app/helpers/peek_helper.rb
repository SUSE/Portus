module PeekHelper
  def peek_available?
    defined? Peek
  end

  def peek_enabled?
    peek_available? && Rails.env.development?
  end

  def render_peek
    render "peek/bar" if peek_enabled?
  end
end
