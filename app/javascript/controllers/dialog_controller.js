import { Controller } from "@hotwired/stimulus"

// Opens the "new event" form in a modal dialog and closes it after a successful save.
export default class extends Controller {
  static targets = [ "dialog" ]

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  closeOnSuccess({ target, detail: { success } }) {
    if (!success) return

    target.reset()
    this.dialogTarget.querySelector("[role=alert]")?.remove()
    this.close()
  }
}
