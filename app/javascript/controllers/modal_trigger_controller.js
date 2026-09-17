// app/javascript/controllers/modal_trigger_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, title: String }
  
  connect() {
    console.log("✅ Modal trigger connected")
  }
  
  async open(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const url = this.urlValue || event.currentTarget.dataset.modalTriggerUrl
    const title = event.currentTarget.dataset.modalTriggerTitle || "Add Expense"
    
    if (!url) {
      console.error("❌ No URL provided for modal")
      return
    }
    
    console.log("📡 Loading modal content from:", url)
    
    try {
      const response = await fetch(url, {
        headers: {
          "Accept": "text/html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })
      
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      
      const html = await response.text()
      
      // Update modal title
      const titleEl = document.querySelector('[data-modal-target="titleText"]')
      if (titleEl) titleEl.textContent = title
      
      // Insert content
      const contentContainer = document.getElementById("modal_content")
      if (contentContainer) {
        contentContainer.innerHTML = html
      }
      
      this.openModal()
      
    } catch (error) {
      console.error("❌ Error:", error)
      const contentContainer = document.getElementById("modal_content")
      if (contentContainer) {
        contentContainer.innerHTML = `
          <div class="text-center py-8 text-red-600">
            <i class="fas fa-exclamation-triangle text-3xl mb-3"></i>
            <p>Failed to load form. Please try again.</p>
          </div>
        `
        this.openModal()
      }
    }
  }
  
  openModal() {
    const modalElement = document.querySelector('[data-controller="modal"]')
    if (modalElement) {
      const modalController = this.application.getControllerForElementAndIdentifier(
        modalElement, 
        "modal"
      )
      if (modalController) {
        setTimeout(() => modalController.open(), 200)
      }
    }
  }
}