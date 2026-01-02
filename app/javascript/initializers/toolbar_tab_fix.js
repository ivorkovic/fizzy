// Fix: Make toolbar buttons not tabbable so Tab goes from title to content
// Users can still click toolbar buttons, just not tab through them
document.addEventListener('DOMContentLoaded', () => {
  const fixToolbarButtons = (toolbar) => {
    toolbar.querySelectorAll('button, summary, [tabindex="0"]').forEach(el => {
      el.setAttribute('tabindex', '-1');
    });
  };

  // Fix existing toolbars
  document.querySelectorAll('lexxy-toolbar').forEach(fixToolbarButtons);

  // Watch for new toolbars (Turbo navigation, dynamic content)
  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      mutation.addedNodes.forEach((node) => {
        if (node.nodeType === Node.ELEMENT_NODE) {
          if (node.tagName === 'LEXXY-TOOLBAR') {
            fixToolbarButtons(node);
          }
          node.querySelectorAll?.('lexxy-toolbar').forEach(fixToolbarButtons);
        }
      });
    });
  });

  observer.observe(document.body, { childList: true, subtree: true });
});

// Also fix on Turbo page loads
document.addEventListener('turbo:load', () => {
  document.querySelectorAll('lexxy-toolbar').forEach(toolbar => {
    toolbar.querySelectorAll('button, summary, [tabindex="0"]').forEach(el => {
      el.setAttribute('tabindex', '-1');
    });
  });
});
