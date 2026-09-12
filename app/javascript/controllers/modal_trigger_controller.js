// app/javascript/controllers/modal_trigger_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }
  
  connect() {
    console.log("✅ Modal trigger connected")
  }
  
  async open(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const url = this.urlValue || event.currentTarget.dataset.modalTriggerUrl
    
    if (!url) {
      console.error("❌ No URL provided for modal")
      return
    }
    
    console.log("📡 Loading modal content from:", url)
    
    try {
      // Fetch the content directly
      const response = await fetch(url, {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const html = await response.text()
      console.log("✅ Content loaded, length:", html.length)
      
      // Insert the content into the modal
      const contentContainer = document.getElementById('modal_content')
      if (contentContainer) {
        contentContainer.innerHTML = html
        console.log("✅ Content inserted into modal")
        
        // Check if form was loaded
        const form = contentContainer.querySelector('form')
        if (form) {
          console.log("✅ Form found in loaded content")
        } else {
          console.log("⚠️ No form found in loaded content")
          console.log("Content preview:", html.substring(0, 200))
        }
      } else {
        console.error("❌ modal_content container not found")
      }
      
      // Open the modal
      this.openModal()
      
    } catch (error) {
      console.error("❌ Error loading modal content:", error)
      // Show error in modal
      const contentContainer = document.getElementById('modal_content')
      if (contentContainer) {
        contentContainer.innerHTML = `
          <div class="text-center py-8 text-red-600">
            <svg class="w-12 h-12 mx-auto mb-3 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <p>Failed to load form. Please try again.</p>
            <p class="text-sm text-gray-500 mt-2">${error.message}</p>
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
        'modal'
      )
      
      if (modalController) {
        setTimeout(() => {
          console.log("🚀 Opening modal")
          modalController.open()
        }, 200)
      } else {
        console.error("❌ Modal controller not found")
      }
    } else {
      console.error("❌ Modal element not found")
    }
  }
}