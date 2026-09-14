import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    nextUrl: String,
    loading: { type: Boolean, default: false }
  }
  
  connect() {
    
    this.observer = new IntersectionObserver(
      this.handleIntersection.bind(this),
      { 
        root: null, 
        rootMargin: "300px", 
        threshold: 0 
      }
    )
    
    this.observer.observe(this.element)
  }
  
  disconnect() {
    console.log("Infinite scroll disconnected")
    this.observer?.disconnect()
  }
  
  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting && this.hasNextUrlValue() && !this.loadingValue) {
        this.loadMore()
      }
    })
  }
  
  async loadMore() {
    if (!this.hasNextUrlValue() || this.loadingValue) return
    
    this.loadingValue = true
    this.showLoader()
    
    try {
      const response = await fetch(this.nextUrlValue, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })
      
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      
      const html = await response.text()
      
      if (typeof Turbo !== "undefined" && Turbo.renderStreamMessage) {
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Error loading more:", error)
    } finally {
      this.loadingValue = false
      this.hideLoader()
    }
  }
  
  showLoader() {
    const loader = document.getElementById("infinite_scroll_loading")
    if (loader) loader.style.display = "block"
  }
  
  hideLoader() {
    const loader = document.getElementById("infinite_scroll_loading")
    if (loader) loader.style.display = "none"
  }
  
  hasNextUrlValue() {
    return this.nextUrlValue && this.nextUrlValue.length > 0
  }
}