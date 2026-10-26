import { Controller } from "@hotwired/stimulus"
import { Timeline } from "vis-timeline/standalone"

const DAY = 24 * 60 * 60 * 1000

// Draws the events as a horizontal timeline, filters them by category and
// loads the details of the clicked event into the event_details frame.
export default class extends Controller {
  static targets = [ "canvas", "details", "chip", "row", "group" ]
  static values = { items: Array, selected: Number }

  connect() {
    if (!this.hasCanvasTarget) return

    this.urls = new Map(this.itemsValue.map(item => [ item.id, item.url ]))
    this.items = this.itemsValue.map(item => this.#item(item))
    this.timeline = new Timeline(this.canvasTarget, this.items, {
      zoomKey: "ctrlKey",
      zoomMin: 7 * DAY,
      zoomMax: 500 * 365 * DAY,
      minHeight: "260px",
      maxHeight: "460px",
      verticalScroll: true,
      showCurrentTime: false,
      margin: { item: { horizontal: 8, vertical: 12 }, axis: 12 }
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

  showAll() {
    this.#applyFilter(null)
  }

  // Stimulus may turn a param like "2024" into a number, so compare as strings.
  filter({ params: { category } }) {
    this.#applyFilter(String(category ?? ""))
  }

  #applyFilter(category) {
    const matches = value => category === null || (value ?? "") === category

    this.timeline.setItems(this.items.filter(item => matches(item.category)))
    this.timeline.fit()

    this.chipTargets.forEach(chip => {
      const pressed = category === null ? !("category" in chip.dataset) : chip.dataset.category === category
      chip.setAttribute("aria-pressed", pressed)
    })
    this.rowTargets.forEach(row => row.hidden = !matches(row.dataset.category))
    this.groupTargets.forEach(group => group.hidden = !group.querySelector("[data-timeline-target=row]:not([hidden])"))
  }

  #showDetails(id) {
    if (id === undefined) return

    this.detailsTarget.src = this.urls.get(id)
  }

  #item({ id, title, date, category, color }) {
    return { id, start: date, title, category, content: this.#content({ id, title, category }), className: color }
  }

  // Built with DOM nodes, not an HTML string, so titles can't inject markup.
  #content({ id, title, category }) {
    const element = document.createElement("span")
    element.className = "timeline-item"
    element.dataset.testid = "timeline-item"
    element.dataset.eventId = id

    if (category) {
      const label = document.createElement("span")
      label.className = "timeline-item__category"
      label.textContent = category
      element.append(label)
    }

    const heading = document.createElement("span")
    heading.className = "timeline-item__title"
    heading.textContent = title
    element.append(heading)

    return element
  }
}
