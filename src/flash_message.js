class FlashMessage extends HTMLElement {
  constructor() {
    super();

    const template = document.querySelector('template#flash-message').content.cloneNode(true);
    this.attachShadow({mode: "open"}).appendChild(template);;
  }

  connectedCallback() {
    const message = this.getAttribute('message');
    this.shadowRoot.getElementById('message').innerText = message;

    setTimeout(() => {
      this.remove();
    }, 3000)
  }
}

window.customElements.define("flash-message", FlashMessage);
