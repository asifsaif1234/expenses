import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "container"]
  static values = { open: Boolean }
  
  connect() {
    document.addEventListener("keydown", this.handleEscape.bind(this))
    document.addEventListener("modal:close", this.handleCloseEvent.bind(this))
  }
  
  disconnect() {
    document.removeEventListener("keydown", this.handleEscape.bind(this))
    document.removeEventListener("modal:close", this.handleCloseEvent.bind(this))
  }
  
  open() {
    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    
    requestAnimationFrame(() => {
      this.containerTarget.setAttribute("data-show", "true")
    })
    
    this.openValue = true
  }
  
  close() {
    this.containerTarget.setAttribute("data-show", "false")
    
    setTimeout(() => {
      this.modalTarget.classList.add("hidden")
      document.body.style.overflow = ""
      this.openValue = false
    }, 300)
  }
  
  handleCloseEvent(event) {
    console.log("📩 Received modal:close event")
    this.close()
  }
  
  handleEscape(event) {
    if (event.key === "Escape" && !this.modalTarget.classList.contains("hidden")) {
      this.close()
    }
  }
}
