class PagesController < ApplicationController
  def healthz
    render plain: "ok"
  end

  def statusz
    render plain: "ok"
  end

  def varz
    render plain: "ok"
  end
end
