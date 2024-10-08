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


class TxtCopy extends HTMLElement {
  constructor() {
    super();

    const template = document.querySelector('template#clipboard').content.cloneNode(true);
    this.attachShadow({mode: "open"}).appendChild(template);;
  }

  connectedCallback() {
    const text = this.getAttribute('text');
    const slot = this.shadowRoot.querySelector('slot');

    slot.addEventListener('click', event => {
      event.preventDefault();
      navigator.clipboard.writeText(text);
      let flash = document.createElement('flash-message');
      flash.setAttribute('message', 'Copied! 👍');
      document.body.prepend(flash);
    })
  }
}

window.customElements.define("txt-copy", TxtCopy)
window.customElements.define("flash-message", FlashMessage);
