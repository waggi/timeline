import { Controller } from "@hotwired/stimulus"
import { Timeline } from "vis-timeline/standalone"

const DAY = 24 * 60 * 60 * 1000

// Draws the events as a horizontal timeline and loads the details of the
// clicked event into the event_details frame.
export default class extends Controller {
  static targets = [ "canvas", "details", "icon" ]
  static values = { items: Array, selected: Number }

  connect() {
    if (!this.hasCanvasTarget) return

    this.urls = new Map(this.itemsValue.map(item => [ item.id, item.url ]))
    this.timeline = new Timeline(this.canvasTarget, this.itemsValue.map(item => this.#item(item)), {
      zoomKey: "ctrlKey",
      zoomMin: 7 * DAY,
      zoomMax: 500 * 365 * DAY,
      minHeight: "220px",
      maxHeight: "420px",
      showCurrentTime: false,
      margin: { item: 12, axis: 8 }
    })
    this.timeline.on("select", ({ items }) => this.#showDetails(items[0]))

    if (this.hasSelectedValue && this.urls.has(this.selectedValue)) {
      this.timeline.setSelection(this.selectedValue, { focus: true })
    }
  }

  disconnect() {
    this.timeline?.destroy()
    this.timeline = null
  }

  zoomIn() {
    this.timeline.zoomIn(0.5)
  }

  zoomOut() {
    this.timeline.zoomOut(0.5)
  }

  fit() {
    this.timeline.fit()
  }

  // A click in the list: the link itself loads the details frame.
  select({ params: { id } }) {
    this.timeline?.setSelection(id, { focus: true })
    this.detailsTarget.scrollIntoView({ block: "nearest", behavior: "smooth" })
  }

  #showDetails(id) {
    if (id === undefined) return

    this.detailsTarget.src = this.urls.get(id)
  }

  #item({ id, title, date, source }) {
    return { id, start: date, title, content: this.#content({ id, title, source }), className: `timeline-item--${source}` }
  }

  // Built with DOM nodes, not an HTML string, so titles can't inject markup.
  #content({ id, title, source }) {
    const element = document.createElement("span")
    element.className = "timeline-item"
    element.dataset.testid = "timeline-item"
    element.dataset.eventId = id
    element.dataset.source = source

    const icon = this.iconTargets.find(template => template.dataset.source === source)
    if (icon) element.append(icon.content.cloneNode(true))

    const label = document.createElement("span")
    label.textContent = title
    element.append(label)

    return element
  }
}
