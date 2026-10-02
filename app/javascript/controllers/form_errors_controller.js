import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!document.documentElement.hasAttribute("data-turbo-preview")) this.focusSummary()
  }

  focusSummary(event) {
    if (event && event.detail.renderMethod !== "morph") return
    if (this.element === document.querySelector('[data-controller~="form-errors"][autofocus]')) this.element.focus()
  }

  focus(event) {
    const input = document.getElementById(event.currentTarget.hash.slice(1))
    const enhanced = input?.closest('[data-island-enhanced="true"]')
    const target = enhanced ? document.getElementById(input.dataset.enhancedId) : input
    const label = target?.labels?.[0]
    if (!label || target.disabled) return
    event.preventDefault()
    label.scrollIntoView()
    target.focus({ preventScroll: true })
  }
}
