function toggleClass(node, className) {
  if(node.classList.contains(className)) {
    node.classList.remove(className);
  } else {
    node.classList.add(className);
  }
}

document.querySelector('#posts').addEventListener('click', function(e) {
  var post = e.target.closest('.post');

  if(post) {
    var postTools = post.querySelector('rss-post-tools');

    if (postTools) {
      postTools.remove()
    } else {
      var postTools = document.createElement('rss-post-tools');
      postTools.setAttribute('post-id', post.dataset.id)
      postTools.setAttribute('post-link', post.dataset.link);
      post.prepend(postTools);
    }
  }
})

window.addEventListener('scroll', (_event) => {
  if(window.scrollY + window.innerHeight >= (document.body.scrollHeight - 50)) {
    var posts = document.querySelector('#posts');
    var nextLink = Array.from(posts.querySelectorAll("a[data-next-page]")).pop();
    if(nextLink.tagName === 'A' && !nextLink.dataset['loaded']) {
      nextLink.dataset['loaded'] = true
      fetch(nextLink.href).then(async function(resp) {
        var body = await resp.text();
        var div = document.createElement('div')
        div.innerHTML = body
        posts.innerHTML += div.querySelector('#posts').innerHTML
        div.remove();
      });
    }
  }
})

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

class RssPostTools extends HTMLElement {
  constructor() {
    super();

    const template = document.querySelector('template#rss-post-tools').content.cloneNode(true);
    this.attachShadow({mode: "open"}).appendChild(template);;
    this.starr = this.starr.bind(this)
    this.copyLink = this.copyLink.bind(this)
    this.redirect = this.redirect.bind(this)
    this.element = this.shadowRoot;
  }

  connectedCallback() {
    this.parentPostRef = this.closest('.post');
    this.postId = this.getAttribute('post-id');
    this.postLink = this.getAttribute('post-link');

    this.parentPostRef.querySelector('.post__content').classList.add('post__content_blured');
    this.element.getElementById('starr').addEventListener('click', this.starr);
    this.element.getElementById('copy-link').addEventListener('click', this.copyLink);
    this.element.getElementById('redirect').addEventListener('click', this.redirect);
  }

  disconnectedCallback() {
    this.parentPostRef.querySelector('.post__content').classList.remove('post__content_blured');
  }

  starr(e) {
    e.preventDefault();
    fetch(`/posts/${this.postId}/star`, { method: 'PATCH' }).then(resp => {
      if(resp.status == 200) {
        toggleClass(this.parentPostRef, 'post_starred');
        this.remove();
      }
    });
  }

  copyLink(e) {
    e.preventDefault();
    navigator.clipboard.writeText(this.postLink);
    let flash = document.createElement('flash-message');
    flash.setAttribute('message', 'Copied! 👍');
    document.body.prepend(flash);
    this.remove();
  }

  redirect(e) {
    e.preventDefault();
    window.open(`/posts/${this.postId}/redirect`, '_blank');
    toggleClass(this.parentPostRef.querySelector('.post__content'), 'post__content_viewed');
    this.remove();
  }
}

window.customElements.define("flash-message", FlashMessage);
window.customElements.define("rss-post-tools", RssPostTools);
