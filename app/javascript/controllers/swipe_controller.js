import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="swipe"
export default class extends Controller {
  static values = {
    doneUrl: String,
    procrastinateUrl: String
  }

  connect() {
    this.startX = 0
    this.startY = 0
    this.currentX = 0
    this.isDragging = false
    this.threshold = 85 // Pixels needed to trigger action

    this.boundTouchStart = this.onTouchStart.bind(this)
    this.boundTouchMove = this.onTouchMove.bind(this)
    this.boundTouchEnd = this.onTouchEnd.bind(this)

    this.element.addEventListener("touchstart", this.boundTouchStart, { passive: true })
    this.element.addEventListener("touchmove", this.boundTouchMove, { passive: false })
    this.element.addEventListener("touchend", this.boundTouchEnd)

    // Also support desktop mouse/trackpad dragging if desired
    this.boundMouseDown = this.onMouseDown.bind(this)
    this.boundMouseMove = this.onMouseMove.bind(this)
    this.boundMouseUp = this.onMouseUp.bind(this)
    this.element.addEventListener("mousedown", this.boundMouseDown)
  }

  disconnect() {
    this.element.removeEventListener("touchstart", this.boundTouchStart)
    this.element.removeEventListener("touchmove", this.boundTouchMove)
    this.element.removeEventListener("touchend", this.boundTouchEnd)
    this.element.removeEventListener("mousedown", this.boundMouseDown)
    window.removeEventListener("mousemove", this.boundMouseMove)
    window.removeEventListener("mouseup", this.boundMouseUp)
  }

  onTouchStart(e) {
    if (e.target.closest("a, button, input, textarea")) return
    const touch = e.touches[0]
    this.startX = touch.clientX
    this.startY = touch.clientY
    this.isDragging = true
    this.element.style.transition = "none"
  }

  onTouchMove(e) {
    if (!this.isDragging) return
    const touch = e.touches[0]
    const dx = touch.clientX - this.startX
    const dy = touch.clientY - this.startY

    // If mainly horizontal swipe, prevent vertical scrolling
    if (Math.abs(dx) > Math.abs(dy)) {
      e.preventDefault()
      this.currentX = dx
      this.applySwipeVisuals(dx)
    }
  }

  onTouchEnd() {
    if (!this.isDragging) return
    this.isDragging = false
    this.handleSwipeFinish()
  }

  onMouseDown(e) {
    if (e.target.closest("a, button, input, textarea")) return
    this.startX = e.clientX
    this.isDragging = true
    this.element.style.transition = "none"

    window.addEventListener("mousemove", this.boundMouseMove)
    window.addEventListener("mouseup", this.boundMouseUp)
  }

  onMouseMove(e) {
    if (!this.isDragging) return
    const dx = e.clientX - this.startX
    if (Math.abs(dx) > 10) {
      this.currentX = dx
      this.applySwipeVisuals(dx)
    }
  }

  onMouseUp() {
    if (!this.isDragging) return
    this.isDragging = false
    window.removeEventListener("mousemove", this.boundMouseMove)
    window.removeEventListener("mouseup", this.boundMouseUp)
    this.handleSwipeFinish()
  }

  applySwipeVisuals(dx) {
    this.element.style.transform = `translateX(${dx}px)`
    if (dx > 30) {
      // Swiping Right -> Complete / Done (Green)
      const opacity = Math.min(Math.abs(dx) / 100, 0.4)
      this.element.style.backgroundColor = `rgba(16, 185, 129, ${opacity})`
    } else if (dx < -30) {
      // Swiping Left -> Snooze / Procrastinate (Amber)
      const opacity = Math.min(Math.abs(dx) / 100, 0.4)
      this.element.style.backgroundColor = `rgba(245, 158, 11, ${opacity})`
    } else {
      this.element.style.backgroundColor = ""
    }
  }

  handleSwipeFinish() {
    const dx = this.currentX
    this.currentX = 0

    if (dx > this.threshold && this.doneUrlValue) {
      // Trigger Done action
      this.element.style.transition = "transform 0.25s ease-out, opacity 0.25s ease-out"
      this.element.style.transform = "translateX(100%)"
      this.element.style.opacity = "0"
      setTimeout(() => {
        Turbo.visit(this.doneUrlValue, { frame: this.element.closest("turbo-frame")?.id })
      }, 200)
    } else if (dx < -this.threshold && this.procrastinateUrlValue) {
      // Trigger Procrastinate action
      this.element.style.transition = "transform 0.25s ease-out, opacity 0.25s ease-out"
      this.element.style.transform = "translateX(-100%)"
      this.element.style.opacity = "0"
      setTimeout(() => {
        Turbo.visit(this.procrastinateUrlValue, { frame: this.element.closest("turbo-frame")?.id })
      }, 200)
    } else {
      // Snap back to normal
      this.element.style.transition = "transform 0.2s ease-out, background-color 0.2s ease-out"
      this.element.style.transform = "translateX(0)"
      this.element.style.backgroundColor = ""
    }
  }
}
