module AttendeaseJekyllConfigMixin
  def attendease
    self['attendease']
  end

  def event?
    attendease['mode'] == 'event'
  end

  def organization?
    attendease['mode'] == 'organization'
  end

  def cms_theme?
    attendease['jekyll33'] == true
  end
end
