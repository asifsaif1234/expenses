// app/javascript/controllers/expense_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["amount", "date", "category", "description", "submit"]
  
  connect() {
    console.log("✅ Expense form controller connected")
  }
  
  handleSubmit(event) {
    if (event.detail.success) {
      console.log("✅ Expense created successfully")
      this.resetForm()
      this.closeModal()
    }
  }
  
  resetForm() {
    if (this.hasAmountTarget) this.amountTarget.value = ""
    if (this.hasDateTarget) this.dateTarget.value = ""
    if (this.hasCategoryTarget) this.categoryTarget.value = ""
    if (this.hasDescriptionTarget) this.descriptionTarget.value = ""
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = false
    }
  }
  
  closeModal() {
    // CHANGED: Use custom event instead of direct controller access
    document.dispatchEvent(new CustomEvent("modal:close"))
  }
}