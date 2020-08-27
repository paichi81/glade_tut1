class ObjectController
  include Observable
  attr_reader :content

  def content=(object)
    @content = object
    @content.add_observer(self)
    @content
  end

  def update
    changed
    notify_observers
    self
  end
end

class View
  attr_reader :widget

  def controller=(c)
    @controller = c
    @controller.add_observer(self)
    c
  end
end

class State
  include Observable
end
