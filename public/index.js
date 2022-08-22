document.querySelectorAll('.post').forEach(post => {
  const postContent = post.querySelector('.post__content');
  const postTools = post.querySelector('.post__tools');
  post.addEventListener('click', e => {
    const starTarget = e.target.closest('[data-star-path]');
    const viewTarget = e.target.closest('[data-view-link]');
    if(starTarget) {
      fetch(starTarget.dataset['starPath'], {method: 'PATCH'}).then(resp => {
        if(resp.status == 200) {
          toggleClass(post, 'post_starred');
        }
      });
    }
    if(viewTarget) {
      postContent.classList.add('post__content_viewed');
    }
    toggleClass(postTools, 'post__tools_visible');
    toggleClass(postContent, 'post__content_blured');
  });
});
function toggleClass(node, className) {
  if(node.classList.contains(className)) {
    node.classList.remove(className);
  } else {
    node.classList.add(className);
  }
}

