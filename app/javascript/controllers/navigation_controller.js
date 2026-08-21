// app/javascript/controllers/navigation_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "userMenu", "mobileMenu"]
  
  connect() {
    // Add scroll effect
    document.addEventListener("scroll", this.handleScroll.bind(this))
    
    // Close menus on click outside
    document.addEventListener("click", this.handleClickOutside.bind(this))
  }
  
  toggleMobileMenu() {
    this.mobileMenuTarget.classList.toggle("hidden")
  }
  
  toggleUserMenu() {
    this.userMenuTarget.classList.toggle("hidden")
  }
  
  closeAllMenus() {
    this.mobileMenuTarget.classList.add("hidden")
    this.userMenuTarget.classList.add("hidden")
  }
  
  handleScroll() {
    const nav = this.element
    if (window.scrollY > 50) {
      nav.classList.add("shadow-md", "bg-white/95")
      nav.classList.remove("bg-white/80")
    } else {
      nav.classList.remove("shadow-md", "bg-white/95")
      nav.classList.add("bg-white/80")
    }
  }
  
  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.closeAllMenus()
    }
  }
}