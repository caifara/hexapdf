# -*- encoding: utf-8 -*-

require 'test_helper'
require_relative '../content/common'
require 'hexapdf/document'
require 'hexapdf/layout/text_box'

describe HexaPDF::Layout::TextBox do
  before do
    @frame = HexaPDF::Layout::Frame.new(0, 0, 100, 100)
  end

  def create_box(items, **kwargs)
    HexaPDF::Layout::TextBox.new(items, kwargs)
  end

  describe "initialize" do
    it "takes the inline items to be layed out in the box" do
      box = create_box([], width: 100)
      assert_equal(100, box.width)
    end
  end

  describe "fit" do
    before do
      @inline_box = HexaPDF::Layout::InlineBox.create(width: 10, height: 10) {}
    end

    it "fits into a rectangular area" do
      box = create_box([@inline_box] * 5)
      assert(box.fit(100, 100, @frame))
      assert_equal(50, box.width)
      assert_equal(10, box.height)
    end

    it "fits into the frame's outline" do
      inline_box = HexaPDF::Layout::InlineBox.create(width: 10, height: 10) {}
      box = create_box([inline_box] * 20, style: {position: :flow})
      assert(box.fit(100, 100, @frame))
      assert_equal(100, box.width)
      assert_equal(20, box.height)
    end
  end

  describe "draw" do
    it "draws the layed out inline items onto the canvas" do
      inline_box = HexaPDF::Layout::InlineBox.create(width: 10, height: 10,
                                                     border: {width: 1})
      box = create_box([inline_box], width: 100, height: 10)
      box.fit(100, 100, nil)

      @canvas = HexaPDF::Document.new.pages.add.canvas
      box.draw(@canvas, 0, 0)
      assert_operators(@canvas.contents, [[:save_graphics_state],
                                          [:concatenate_matrix, [1, 0, 0, 1, 0, 0]],
                                          [:save_graphics_state],
                                          [:restore_graphics_state],
                                          [:save_graphics_state],
                                          [:append_rectangle, [0, 0, 10, 10]],
                                          [:clip_path_non_zero],
                                          [:end_path],
                                          [:append_rectangle, [0.5, 0.5, 9, 9]],
                                          [:stroke_path],
                                          [:restore_graphics_state],
                                          [:save_graphics_state],
                                          [:restore_graphics_state],
                                          [:restore_graphics_state]])
    end

    it "draws nothing onto the canvas if the box is empty" do
      @canvas = HexaPDF::Document.new.pages.add.canvas
      box = create_box([])
      box.draw(@canvas, 5, 5)
      assert_operators(@canvas.contents, [])
    end
  end
end
