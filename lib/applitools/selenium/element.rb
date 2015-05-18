module Applitools::Selenium
  class Element < SimpleDelegator
    TRACE_PREFIX = 'EyesWebElement'.freeze

    def initialize(driver, element)
      super(element)

      @driver = driver
    end

    def web_element
      @web_element ||= __getobj__
    end

    def click
      current_control = region
      offset = current_control.middle_offset
      @driver.user_inputs << Applitools::Base::MouseTrigger.new(:click, current_control, offset)

      web_element.click
    end

    def inspect
      TRACE_PREFIX + web_element.inspect
    end

    def ==(other)
      other.kind_of?(web_element.class) && web_element == other
    end
    alias_method :eql?, :==

    def send_keys(*args)
      current_control = region
      Selenium::WebDriver::Keys.encode(args).each do |key|
        @driver.user_inputs << Applitools::Base::TextTrigger.new(key.to_s, current_control)
      end

      web_element.send_keys(*args)
    end
    alias_method :send_key, :send_keys

    def region
      point = location
      left, top, width, height  = point.x, point.y, 0, 0

      begin
        dimension = size
        width, height = dimension.width, dimension.height
      rescue
        # Not supported on all platforms.
      end

      if left < 0
        width = [0, width + left].max
        left = 0
      end

      if top < 0
        height = [0, height + top].max
        top = 0
      end

      return Applitools::Base::Region.new(left, top, width, height)
    end
  end
end
