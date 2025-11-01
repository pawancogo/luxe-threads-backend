// Admin Panel JavaScript
// =====================

class AdminPanel {
  constructor() {
    this.init();
  }

  init() {
    this.setupEventListeners();
    this.initializeComponents();
    this.setupResponsive();
  }

  setupEventListeners() {
    // Sidebar toggle for mobile
    document.addEventListener('DOMContentLoaded', () => {
      this.setupSidebarToggle();
      this.setupConfirmations();
      this.setupFormValidation();
      this.setupTableSorting();
      this.setupSearchFilters();
    });
  }

  initializeComponents() {
    this.initializeTooltips();
    this.initializeModals();
    this.initializeDataTables();
  }

  setupResponsive() {
    // Handle window resize
    window.addEventListener('resize', () => {
      this.handleResize();
    });
  }

  // Sidebar Toggle for Mobile
  setupSidebarToggle() {
    const sidebarToggle = document.querySelector('.sidebar-toggle');
    const sidebar = document.querySelector('.sidebar');
    
    if (sidebarToggle && sidebar) {
      sidebarToggle.addEventListener('click', () => {
        sidebar.classList.toggle('open');
      });
    }
  }

  // Confirmation Dialogs
  setupConfirmations() {
    const deleteButtons = document.querySelectorAll('[data-confirm]');
    
    deleteButtons.forEach(button => {
      button.addEventListener('click', (e) => {
        const message = button.getAttribute('data-confirm') || 'Are you sure?';
        
        if (!confirm(message)) {
          e.preventDefault();
        }
      });
    });
  }

  // Form Validation
  setupFormValidation() {
    const forms = document.querySelectorAll('.admin-form, .supplier-form');
    
    forms.forEach(form => {
      form.addEventListener('submit', (e) => {
        if (!this.validateForm(form)) {
          e.preventDefault();
        }
      });
    });
  }

  validateForm(form) {
    let isValid = true;
    const requiredFields = form.querySelectorAll('[required]');
    
    requiredFields.forEach(field => {
      if (!field.value.trim()) {
        this.showFieldError(field, 'This field is required');
        isValid = false;
      } else {
        this.clearFieldError(field);
      }
    });

    // Email validation
    const emailFields = form.querySelectorAll('input[type="email"]');
    emailFields.forEach(field => {
      if (field.value && !this.isValidEmail(field.value)) {
        this.showFieldError(field, 'Please enter a valid email address');
        isValid = false;
      }
    });

    // Password confirmation
    const password = form.querySelector('input[name*="password"]:not([name*="confirmation"])');
    const passwordConfirmation = form.querySelector('input[name*="password_confirmation"]');
    
    if (password && passwordConfirmation && password.value !== passwordConfirmation.value) {
      this.showFieldError(passwordConfirmation, 'Passwords do not match');
      isValid = false;
    }

    return isValid;
  }

  showFieldError(field, message) {
    this.clearFieldError(field);
    
    const errorDiv = document.createElement('div');
    errorDiv.className = 'field-error';
    errorDiv.textContent = message;
    
    field.parentNode.appendChild(errorDiv);
    field.classList.add('error');
  }

  clearFieldError(field) {
    const existingError = field.parentNode.querySelector('.field-error');
    if (existingError) {
      existingError.remove();
    }
    field.classList.remove('error');
  }

  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  // Table Sorting
  setupTableSorting() {
    const tables = document.querySelectorAll('.table');
    
    tables.forEach(table => {
      const headers = table.querySelectorAll('th[data-sortable]');
      
      headers.forEach(header => {
        header.style.cursor = 'pointer';
        header.addEventListener('click', () => {
          this.sortTable(table, header);
        });
      });
    });
  }

  sortTable(table, header) {
    const column = Array.from(header.parentNode.children).indexOf(header);
    const rows = Array.from(table.querySelectorAll('tbody tr'));
    const isAscending = header.classList.contains('sort-asc');
    
    // Clear existing sort classes
    table.querySelectorAll('th').forEach(th => {
      th.classList.remove('sort-asc', 'sort-desc');
    });
    
    // Add sort class
    header.classList.add(isAscending ? 'sort-desc' : 'sort-asc');
    
    // Sort rows
    rows.sort((a, b) => {
      const aValue = a.children[column].textContent.trim();
      const bValue = b.children[column].textContent.trim();
      
      if (isAscending) {
        return bValue.localeCompare(aValue);
      } else {
        return aValue.localeCompare(bValue);
      }
    });
    
    // Reorder rows
    const tbody = table.querySelector('tbody');
    rows.forEach(row => tbody.appendChild(row));
  }

  // Search Filters
  setupSearchFilters() {
    const searchInputs = document.querySelectorAll('.search-input');
    
    searchInputs.forEach(input => {
      input.addEventListener('input', (e) => {
        this.filterTable(e.target);
      });
    });
  }

  filterTable(searchInput) {
    const table = searchInput.closest('.table-container').querySelector('.table');
    const filterValue = searchInput.value.toLowerCase();
    const rows = table.querySelectorAll('tbody tr');
    
    rows.forEach(row => {
      const text = row.textContent.toLowerCase();
      row.style.display = text.includes(filterValue) ? '' : 'none';
    });
  }

  // Tooltips
  initializeTooltips() {
    const tooltipElements = document.querySelectorAll('[data-tooltip]');
    
    tooltipElements.forEach(element => {
      element.addEventListener('mouseenter', (e) => {
        this.showTooltip(e.target, e.target.getAttribute('data-tooltip'));
      });
      
      element.addEventListener('mouseleave', () => {
        this.hideTooltip();
      });
    });
  }

  showTooltip(element, text) {
    const tooltip = document.createElement('div');
    tooltip.className = 'tooltip';
    tooltip.textContent = text;
    tooltip.style.position = 'absolute';
    tooltip.style.background = '#333';
    tooltip.style.color = 'white';
    tooltip.style.padding = '5px 10px';
    tooltip.style.borderRadius = '4px';
    tooltip.style.fontSize = '12px';
    tooltip.style.zIndex = '1000';
    
    document.body.appendChild(tooltip);
    
    const rect = element.getBoundingClientRect();
    tooltip.style.left = rect.left + 'px';
    tooltip.style.top = (rect.top - 30) + 'px';
  }

  hideTooltip() {
    const tooltip = document.querySelector('.tooltip');
    if (tooltip) {
      tooltip.remove();
    }
  }

  // Modals
  initializeModals() {
    const modalTriggers = document.querySelectorAll('[data-modal]');
    
    modalTriggers.forEach(trigger => {
      trigger.addEventListener('click', (e) => {
        e.preventDefault();
        this.openModal(trigger.getAttribute('data-modal'));
      });
    });
  }

  openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
      modal.style.display = 'block';
      modal.classList.add('show');
    }
  }

  closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
      modal.style.display = 'none';
      modal.classList.remove('show');
    }
  }

  // Data Tables
  initializeDataTables() {
    const tables = document.querySelectorAll('.data-table');
    
    tables.forEach(table => {
      this.enhanceTable(table);
    });
  }

  enhanceTable(table) {
    // Add row selection
    const checkboxes = table.querySelectorAll('input[type="checkbox"]');
    const selectAllCheckbox = table.querySelector('.select-all');
    
    if (selectAllCheckbox) {
      selectAllCheckbox.addEventListener('change', (e) => {
        checkboxes.forEach(checkbox => {
          checkbox.checked = e.target.checked;
        });
      });
    }
  }

  // Responsive Handling
  handleResize() {
    const sidebar = document.querySelector('.sidebar');
    const mainContent = document.querySelector('.main-content');
    
    if (window.innerWidth <= 768) {
      sidebar.classList.remove('open');
    }
  }

  // Utility Methods
  showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    notification.style.position = 'fixed';
    notification.style.top = '20px';
    notification.style.right = '20px';
    notification.style.padding = '15px 20px';
    notification.style.borderRadius = '4px';
    notification.style.color = 'white';
    notification.style.zIndex = '1000';
    
    switch (type) {
      case 'success':
        notification.style.background = '#28a745';
        break;
      case 'error':
        notification.style.background = '#dc3545';
        break;
      case 'warning':
        notification.style.background = '#ffc107';
        break;
      default:
        notification.style.background = '#17a2b8';
    }
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
      notification.remove();
    }, 5000);
  }

  // AJAX Helper
  ajaxRequest(url, options = {}) {
    const defaultOptions = {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    };
    
    return fetch(url, { ...defaultOptions, ...options })
      .then(response => response.json())
      .catch(error => {
        console.error('AJAX Error:', error);
        this.showNotification('An error occurred', 'error');
      });
  }
}

// Initialize Admin Panel
document.addEventListener('DOMContentLoaded', () => {
  new AdminPanel();
});

// Export for use in other scripts
window.AdminPanel = AdminPanel;


