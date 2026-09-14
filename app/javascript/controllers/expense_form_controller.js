import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["amount", "date", "category", "description", "submit"]
  
  handleSubmit(event) {
    if (event.detail.success) {
      console.log("Expense created successfully")
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
    document.dispatchEvent(new CustomEvent("modal:close"))
  }
}