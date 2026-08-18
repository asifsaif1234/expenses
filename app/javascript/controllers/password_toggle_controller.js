// app/javascript/controllers/password_toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["password", "icon", "button"]
  
  toggle() {
    const type = this.passwordTarget.getAttribute("type") === "password" ? "text" : "password"
    this.passwordTarget.setAttribute("type", type)
    
    // Toggle icon
    if (type === "password") {
      this.iconTarget.className = "fas fa-eye"
      this.buttonTarget.setAttribute("title", "Show password")
    } else {
      this.iconTarget.className = "fas fa-eye-slash"
      this.buttonTarget.setAttribute("title", "Hide password")
    }
  }
}