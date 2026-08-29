// app/javascript/controllers/navbar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  connect() {
    // Add scroll effect
    document.addEventListener("scroll", this.handleScroll.bind(this))
    
    // Close menu on click outside
    document.addEventListener("click", this.handleClickOutside.bind(this))
  }
  
  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }
  
  close() {
    this.menuTarget.classList.add("hidden")
  }
  
  handleScroll() {
    const nav = this.element
    if (window.scrollY > 50) {
      nav.classList.add("shadow-sm")
    } else {
      nav.classList.remove("shadow-sm")
    }
  }
  
  handleClickOutside(event) {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")) {
      this.menuTarget.classList.add("hidden")
    }
  }
}