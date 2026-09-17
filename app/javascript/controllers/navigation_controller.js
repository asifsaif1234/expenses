import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "userMenu", "mobileMenu"]

  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    this.handleClickOutside = this.handleClickOutside.bind(this)

    document.addEventListener("scroll", this.handleScroll)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("scroll", this.handleScroll)
    document.removeEventListener("click", this.handleClickOutside)
  }

  toggleMobileMenu() {
    if (this.hasMobileMenuTarget) {
      this.mobileMenuTarget.classList.toggle("hidden")
    }
  }

  toggleUserMenu() {
    if (this.hasUserMenuTarget) {
      this.userMenuTarget.classList.toggle("hidden")
    }
  }

  closeAllMenus() {
    if (this.hasMobileMenuTarget) {
      this.mobileMenuTarget.classList.add("hidden")
    }

    if (this.hasUserMenuTarget) {
      this.userMenuTarget.classList.add("hidden")
    }
  }

  handleScroll() {
    if (window.scrollY > 50) {
      this.element.classList.add("shadow-md", "bg-white/95")
      this.element.classList.remove("bg-white/80")
    } else {
      this.element.classList.remove("shadow-md", "bg-white/95")
      this.element.classList.add("bg-white/80")
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.closeAllMenus()
    }
  }
}