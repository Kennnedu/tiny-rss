var templatePostTools = document.querySelector("template#post-tools").content;
var noticeRef = document.querySelector('.notice');
document.querySelector('#posts').addEventListener('click', function(e) {
  var post = e.target.closest('.post');

  if (post) {
    var postTools = post.querySelector('.post__tools');
    var postContent = post.querySelector('.post__content');
    var starTarget = e.target.closest('[data-star-path]');
    var viewTarget = e.target.closest('[data-view-link]');
    var copyLinkTarget = e.target.closest('[data-copy-link]');

    if(starTarget) {
      starPost(starTarget.dataset['starPath'], post)
    }

    if(viewTarget) {
      postContent.classList.add('post__content_viewed');
    }

    if(copyLinkTarget) {
      navigator.clipboard.writeText(post.dataset['link']);
      showNotice('Copied! 👍')
    }

    if(postTools) {
      postTools.remove();
    } else {
      renderPostToolbar(post);
    }

    toggleClass(postContent, 'post__content_blured');
  }
})
window.addEventListener('scroll', loadPosts)
function toggleClass(node, className) {
  if(node.classList.contains(className)) {
    node.classList.remove(className);
  } else {
    node.classList.add(className);
  }
}
function renderPostToolbar(post) {
  var postId = post.dataset['id']
  var tools = templatePostTools.cloneNode(true);
  var starIcon = tools.querySelector("[data-star-path]");
  var redirectLink = tools.querySelector("[data-view-link]");
  starIcon.dataset['starPath'] = starIcon.dataset['starPath'].replace(':id', postId)
  redirectLink.href = redirectLink.href.replace(':id', postId)
  post.prepend(tools);
}
function starPost(path, post){
  fetch(path, {method: 'PATCH'}).then(function(resp) {
    if(resp.status == 200) {
      toggleClass(post, 'post_starred');
    }
  });
}
function loadPosts(_event) {
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
}
function showNotice(message) {
  noticeRef.textContent = message;
  toggleClass(noticeRef, 'notice_hidden');
  const timeoutId = setTimeout(function(){
    toggleClass(noticeRef, 'notice_hidden');
    clearTimeout(timeoutId);
  }, 2000)
}
