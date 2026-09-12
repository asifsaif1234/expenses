// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "container"]
  static values = { open: Boolean }
  
  connect() {
    console.log("✅ Modal controller connected")
    document.addEventListener("keydown", this.handleEscape.bind(this))
    
    // NEW: Listen for custom modal:close events
    document.addEventListener("modal:close", this.handleCloseEvent.bind(this))
  }
  
  disconnect() {
    document.removeEventListener("keydown", this.handleEscape.bind(this))
    document.removeEventListener("modal:close", this.handleCloseEvent.bind(this))
  }
  
  open() {
    console.log("🔄 Opening modal")
    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    
    requestAnimationFrame(() => {
      this.containerTarget.setAttribute("data-show", "true")
    })
    
    this.openValue = true
  }
  
  close() {
    console.log("🔄 Closing modal")
    this.containerTarget.setAttribute("data-show", "false")
    
    setTimeout(() => {
      this.modalTarget.classList.add("hidden")
      document.body.style.overflow = ""
      this.openValue = false
    }, 300)
  }
  
  // NEW: Handle custom close event
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