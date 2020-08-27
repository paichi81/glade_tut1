# frozen_string_literal: true

%w[pp gtk3 date observer].each { |lib| require lib }
require_relative 'mvc'

class State
  def initialize
    super
    @select_date = Date.today
  end

  attr_reader :selected_date

  def selected_date=(date)
    @selected_date = date
    changed
    notify_observers
    date
  end
end

class SelectedDateView < View
  def initialize(parent_builder)
    @widget = parent_builder.get_object('entrydate')
    @widget.signal_connect('changed') do
      @controller.content.selected_date = value
      true
    end
  end

  def value
    @widget.text
  end

  def value=(f)
    @widget.text = f.to_s
  end

  def update
    self.value = @controller.content.selected_date
    self
  end
end

class GyoumuApp
  def initialize
    @select_date = Date.today

    @builder = Gtk::Builder.new(file: 'glade1.glade')

    @seldate_controller = ObjectController.new
    @seldate_controller.content = State.new
    @seldate_view = SelectedDateView.new(@builder)
    @seldate_view.controller = @seldate_controller

    @win = @builder.get_object('main')
    @date_picker = @builder.get_object('date_picker') # PopOver
    @calendar = @builder.get_object('calendar') # PopOverのなかのCalendar

    @buf_code = @builder.get_object('entrybuffer1')
    pp @buf_code.methods.sort
    @buf_code.text = 'K6205'

    @btn_yday = @builder.get_object('select_yesterday')
    @btn_tday = @builder.get_object('select_today')
    @btn_tmrw = @builder.get_object('select_tomorrow')
    @btn_yday.signal_connect('clicked') do
      select_day(-1)
    end
    @btn_tday.signal_connect('clicked') do
      select_day(-1)
    end
    @btn_tmrw.signal_connect('clicked') do
      select_day(1)
    end

    @builder.connect_signals { |handler| method(handler) } # handler は String
  end

  def select_day(day)
    @seldate_controller.content.selected_date = Date.today + day
    click_dateclose
  end

  # [✕] が押された時にアプリを終了する
  def on_main_destroy
    warn '終了するぜよ'
    Gtk.main_quit
  end

  # codeでEnterキーを押下
  def code_activate
    warn 'code activate (Enterおした)'
  end

  # entrydateにフォーカスが移ったとき
  def focus_in_entrydate
    @date_picker.visible = true
  end

  # calendarの日付をダブルクリックしたとき
  def dblclick_date
    @seldate_controller.content.selected_date = sprintf('%04d-%02d-%02d', @calendar.year, @calendar.month, @calendar.day)
    click_dateclose
  end

  # date_pickerでキャンセルボタンを押下
  def click_dateclose
    @date_picker.visible = false
  end
end

class App < GyoumuApp
  def initialize
    super
    @win.show_all
    Gtk.main
  end
end
App.new
