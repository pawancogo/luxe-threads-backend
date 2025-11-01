// RailsAdmin Custom JavaScript for Logout Button
(function() {
  function addLogoutButton() {
    // Find the navigation bar - try multiple selectors
    const navBar = document.querySelector('.navbar') || 
                   document.querySelector('.navbar-default') || 
                   document.querySelector('.navbar-inverse') ||
                   document.querySelector('.navbar-static-top');
    
    if (navBar) {
      // Check if logout button already exists
      if (navBar.querySelector('.logout-button')) {
        return;
      }
      
      // Create logout button with power icon
      const logoutButton = document.createElement('a');
      logoutButton.href = '/admin_auth/logout';
      logoutButton.className = 'btn btn-danger btn-sm logout-button';
      logoutButton.innerHTML = '<i class="fa fa-power-off"></i> Logout';
      logoutButton.style.marginLeft = '10px';
      logoutButton.style.float = 'right';
      logoutButton.onclick = function(e) {
        if (!confirm('Are you sure you want to logout?')) {
          e.preventDefault();
        }
      };
      
      // Find the user info area or create one
      let userInfoArea = navBar.querySelector('.navbar-right');
      if (!userInfoArea) {
        userInfoArea = document.createElement('div');
        userInfoArea.className = 'navbar-right';
        userInfoArea.style.float = 'right';
        userInfoArea.style.display = 'flex';
        userInfoArea.style.alignItems = 'center';
        userInfoArea.style.marginRight = '15px';
        navBar.appendChild(userInfoArea);
      }
      
      // Add user email display
      const userEmail = document.createElement('span');
      userEmail.className = 'navbar-text';
      userEmail.style.marginRight = '10px';
      userEmail.style.color = '#333';
      userEmail.textContent = 'Dashboard';
      
      // Add the elements to the navbar
      userInfoArea.appendChild(userEmail);
      userInfoArea.appendChild(logoutButton);
    }
  }
  
  // Try multiple times to ensure it works
  document.addEventListener('DOMContentLoaded', function() {
    addLogoutButton();
    setTimeout(addLogoutButton, 500);
    setTimeout(addLogoutButton, 1000);
    setTimeout(addLogoutButton, 2000);
  });
  
  // Also try when the page loads
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', addLogoutButton);
  } else {
    addLogoutButton();
  }
})();
