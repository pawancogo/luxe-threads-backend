// RailsAdmin Custom JavaScript - Remove duplicate logout buttons
(function() {
  const LOGOUT_SELECTOR = 'a[href*="logout"]:not(.rails-admin-logout-only)';
  
  function hideDuplicates() {
    // Hide all logout buttons except our custom one
    document.querySelectorAll(LOGOUT_SELECTOR).forEach(button => {
      button.style.display = 'none';
      button.closest('li.nav-item')?.style.setProperty('display', 'none');
    });
    
    // Hide badge-style logout (RailsAdmin default)
    document.querySelectorAll('.badge.bg-danger').forEach(badge => {
      badge.closest('a, li')?.style.setProperty('display', 'none');
    });
  }
  
  function init() {
    hideDuplicates();
    // Ensure our custom logout is visible
    document.querySelector('.rails-admin-logout-only')?.style.setProperty('display', '');
  }
  
  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
  
  // Watch for navigation changes
  new MutationObserver(init).observe(document.body, { 
    childList: true, 
    subtree: true 
  });
})();
