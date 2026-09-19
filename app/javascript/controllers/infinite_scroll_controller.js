import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    nextUrl: String
  }

  connect() {
    this.loading = false

    this.observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          this.loadNextPage()
        }
      },
      {
        rootMargin: "300px"
      }
    )

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
      this.observer = null
    }
  }

  async loadNextPage() {
    if (this.loading) return

    if (!this.hasNextUrlValue || !this.nextUrlValue) {
      return
    }

    this.loading = true

    this.showLoading()

    try {
      const response = await fetch(this.nextUrlValue, {
        headers: {
          Accept: "text/vnd.turbo-stream.html"
        },
        credentials: "same-origin"
      })

      if (!response.ok) {
        throw new Error(
          `Infinite scroll request failed: ${response.status}`
        )
      }

      const html = await response.text()

      Turbo.renderStreamMessage(html)

    } catch (error) {
      console.error(
        "Infinite scroll error:",
        error
      )
    } finally {
      this.loading = false
      this.hideLoading()
    }
  }

  showLoading() {
    const loadingElement =
      document.getElementById(
        "infinite_scroll_loading"
      )

    if (loadingElement) {
      loadingElement.style.display = "block"
    }
  }

  hideLoading() {
    const loadingElement =
      document.getElementById(
        "infinite_scroll_loading"
      )

    if (loadingElement) {
      loadingElement.style.display = "none"
    }
  }
}