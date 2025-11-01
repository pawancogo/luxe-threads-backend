// Bootstrap Admin Panel JavaScript
// =================================

// Initialize when DOM is ready
$(document).ready(function() {
  initializeBootstrapComponents();
  initializeAdminFeatures();
  setupEventHandlers();
});

// Initialize Bootstrap Components
function initializeBootstrapComponents() {
  // Initialize tooltips
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });

  // Initialize popovers
  var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
  var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    return new bootstrap.Popover(popoverTriggerEl);
  });

  // Initialize modals
  var modalList = [].slice.call(document.querySelectorAll('.modal'));
  var modals = modalList.map(function (modalEl) {
    return new bootstrap.Modal(modalEl);
  });
}

// Initialize Admin Features
function initializeAdminFeatures() {
  setupSidebarToggle();
  setupDataTables();
  setupFormValidation();
  setupConfirmations();
  setupSearchFilters();
  setupNotifications();
}

// Setup Event Handlers
function setupEventHandlers() {
  // Sidebar toggle for mobile
  $(document).on('click', '.sidebar-toggle', function(e) {
    e.preventDefault();
    $('.sidebar-admin').toggleClass('show');
  });

  // Close sidebar when clicking outside on mobile
  $(document).on('click', function(e) {
    if ($(window).width() <= 768) {
      if (!$(e.target).closest('.sidebar-admin, .sidebar-toggle').length) {
        $('.sidebar-admin').removeClass('show');
      }
    }
  });

  // Handle window resize
  $(window).on('resize', function() {
    if ($(window).width() > 768) {
      $('.sidebar-admin').removeClass('show');
    }
  });
}

// Sidebar Toggle
function setupSidebarToggle() {
  // Mobile sidebar toggle
  $('.sidebar-toggle').on('click', function() {
    $('.sidebar-admin').toggleClass('show');
  });
}

// Data Tables with Bootstrap styling
function setupDataTables() {
  // Add Bootstrap classes to tables
  $('.table').addClass('table-striped table-hover');
  
  // Add sort functionality
  $('.table th[data-sortable]').on('click', function() {
    var table = $(this).closest('table');
    var column = $(this).index();
    var rows = table.find('tbody tr').toArray();
    var isAscending = $(this).hasClass('sort-asc');
    
    // Clear existing sort classes
    table.find('th').removeClass('sort-asc sort-desc');
    
    // Add sort class
    $(this).addClass(isAscending ? 'sort-desc' : 'sort-asc');
    
    // Sort rows
    rows.sort(function(a, b) {
      var aValue = $(a).find('td').eq(column).text().trim();
      var bValue = $(b).find('td').eq(column).text().trim();
      
      if (isAscending) {
        return bValue.localeCompare(aValue);
      } else {
        return aValue.localeCompare(bValue);
      }
    });
    
    // Reorder rows
    var tbody = table.find('tbody');
    tbody.empty().append(rows);
  });
}

// Form Validation with Bootstrap
function setupFormValidation() {
  // Custom validation
  $('.needs-validation').on('submit', function(e) {
    if (!this.checkValidity()) {
      e.preventDefault();
      e.stopPropagation();
    }
    $(this).addClass('was-validated');
  });

  // Real-time validation
  $('.form-control').on('blur', function() {
    validateField($(this));
  });

  // Email validation
  $('input[type="email"]').on('blur', function() {
    var email = $(this).val();
    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    
    if (email && !emailRegex.test(email)) {
      showFieldError($(this), 'Please enter a valid email address');
    } else {
      clearFieldError($(this));
    }
  });

  // Password confirmation
  $('input[name*="password_confirmation"]').on('blur', function() {
    var password = $('input[name*="password"]:not([name*="confirmation"])').val();
    var confirmation = $(this).val();
    
    if (password && confirmation && password !== confirmation) {
      showFieldError($(this), 'Passwords do not match');
    } else {
      clearFieldError($(this));
    }
  });
}

// Field Validation Helpers
function validateField(field) {
  var value = field.val().trim();
  var isRequired = field.prop('required');
  
  if (isRequired && !value) {
    showFieldError(field, 'This field is required');
    return false;
  } else {
    clearFieldError(field);
    return true;
  }
}

function showFieldError(field, message) {
  clearFieldError(field);
  
  var errorDiv = $('<div class="invalid-feedback d-block">' + message + '</div>');
  field.addClass('is-invalid');
  field.after(errorDiv);
}

function clearFieldError(field) {
  field.removeClass('is-invalid');
  field.siblings('.invalid-feedback').remove();
}

// Confirmation Dialogs
function setupConfirmations() {
  $('[data-confirm]').on('click', function(e) {
    var message = $(this).data('confirm') || 'Are you sure?';
    
    if (!confirm(message)) {
      e.preventDefault();
    }
  });
}

// Search Filters
function setupSearchFilters() {
  $('.search-input').on('input', function() {
    var filterValue = $(this).val().toLowerCase();
    var table = $(this).closest('.table-container').find('.table');
    var rows = table.find('tbody tr');
    
    rows.each(function() {
      var text = $(this).text().toLowerCase();
      $(this).toggle(text.includes(filterValue));
    });
  });
}

// Notifications
function setupNotifications() {
  // Auto-hide alerts after 5 seconds
  $('.alert').each(function() {
    var alert = $(this);
    setTimeout(function() {
      alert.fadeOut();
    }, 5000);
  });
}

// Show notification
function showNotification(message, type = 'info') {
  var alertClass = 'alert-' + type;
  var notification = $('<div class="alert ' + alertClass + ' alert-dismissible fade show" role="alert">' +
    message +
    '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
    '</div>');
  
  $('.content').prepend(notification);
  
  setTimeout(function() {
    notification.alert('close');
  }, 5000);
}

// AJAX Helpers
function ajaxRequest(url, options = {}) {
  var defaultOptions = {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    }
  };
  
  return $.ajax(url, $.extend(defaultOptions, options))
    .fail(function(xhr, status, error) {
      console.error('AJAX Error:', error);
      showNotification('An error occurred: ' + error, 'danger');
    });
}

// Loading States
function setLoadingState(element, loading = true) {
  if (loading) {
    $(element).addClass('loading').prop('disabled', true);
    var originalText = $(element).text();
    $(element).data('original-text', originalText).html('<span class="spinner-border spinner-border-sm me-2"></span>Loading...');
  } else {
    $(element).removeClass('loading').prop('disabled', false);
    var originalText = $(element).data('original-text');
    if (originalText) {
      $(element).text(originalText);
    }
  }
}

// Form Submission with Loading
$('form').on('submit', function() {
  var submitBtn = $(this).find('button[type="submit"], input[type="submit"]');
  setLoadingState(submitBtn, true);
  
  // Re-enable after 3 seconds (fallback)
  setTimeout(function() {
    setLoadingState(submitBtn, false);
  }, 3000);
});

// Modal Helpers
function openModal(modalId) {
  var modal = new bootstrap.Modal(document.getElementById(modalId));
  modal.show();
}

function closeModal(modalId) {
  var modal = bootstrap.Modal.getInstance(document.getElementById(modalId));
  if (modal) {
    modal.hide();
  }
}

// Table Row Actions
$('.table').on('click', '.btn-delete', function(e) {
  e.preventDefault();
  var row = $(this).closest('tr');
  var itemName = row.find('td:first').text();
  
  if (confirm('Are you sure you want to delete ' + itemName + '?')) {
    // Add loading state
    $(this).html('<span class="spinner-border spinner-border-sm"></span>');
    
    // Simulate delete request
    setTimeout(function() {
      row.fadeOut(function() {
        $(this).remove();
        showNotification(itemName + ' deleted successfully', 'success');
      });
    }, 1000);
  }
});

// Export functions for global use
window.AdminPanel = {
  showNotification: showNotification,
  ajaxRequest: ajaxRequest,
  setLoadingState: setLoadingState,
  openModal: openModal,
  closeModal: closeModal
};


