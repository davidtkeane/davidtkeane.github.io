// Post Actions: Print, Save, Copy - Auto-inject on posts
(function() {
  'use strict';

  // Only run on actual post pages (URL contains /posts/)
  if (!window.location.pathname.includes('/posts/')) return;

  // Only run on post pages (Chirpy uses 'content' class and article tag)
  const postContent = document.querySelector('article .content') || document.querySelector('.post-content');
  if (!postContent) return;

  // Create action buttons HTML
  const actionsHTML = `
    <div class="post-actions" id="post-actions">
      <button onclick="printPost()" class="btn-action" title="Print or Save as PDF">
        <i class="fas fa-print"></i> Print / PDF
      </button>
      <button onclick="copyPostLink()" class="btn-action" title="Copy link to clipboard">
        <i class="fas fa-link"></i> Copy Link
      </button>
      <button onclick="downloadPost()" class="btn-action" title="Download as Markdown">
        <i class="fas fa-download"></i> Download .md
      </button>
    </div>
  `;

  // Find where to insert (after post meta/before content)
  if (postContent) {
    postContent.insertAdjacentHTML('beforebegin', actionsHTML);
  }

  // Add styles
  const styles = `
    <style>
    .post-actions {
      display: flex;
      gap: 10px;
      margin: 20px 0;
      padding: 15px;
      background: var(--card-bg);
      border-radius: 8px;
      border: 1px solid var(--btn-border-color, #dee2e6);
      flex-wrap: wrap;
    }

    .btn-action {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 8px 16px;
      background: var(--btn-bg, #f8f9fa);
      color: var(--text-color, #333);
      border: 1px solid var(--btn-border-color, #dee2e6);
      border-radius: 6px;
      cursor: pointer;
      font-size: 0.9rem;
      font-family: inherit;
      transition: all 0.2s ease;
    }

    .btn-action:hover {
      background: var(--btn-active-bg, #e9ecef);
      transform: translateY(-2px);
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    .btn-action:active {
      transform: translateY(0);
    }

    .btn-action i {
      font-size: 1rem;
    }

    /* Dark mode support */
    [data-mode="dark"] .btn-action {
      background: var(--card-bg, #2a2a2a);
      color: var(--text-color, #d3d3d3);
      border-color: var(--btn-border-color, #404040);
    }

    [data-mode="dark"] .btn-action:hover {
      background: var(--btn-active-bg, #3a3a3a);
    }

    /* Print styles */
    @media print {
      .post-actions,
      #sidebar,
      #topbar,
      .post-tail-wrapper,
      #toc-wrapper,
      #panel-wrapper,
      footer,
      .post-navigation,
      .share-wrapper,
      #comments {
        display: none !important;
      }

      body {
        font-size: 11pt !important;
        line-height: 1.6 !important;
        color: #000 !important;
        background: #fff !important;
      }

      #main-wrapper {
        margin: 0 !important;
        padding: 0 !important;
      }

      .container {
        max-width: 100% !important;
        padding: 0 20px !important;
      }

      main {
        width: 100% !important;
        max-width: 100% !important;
        margin: 0 !important;
        padding: 0 !important;
      }

      .post-content {
        font-size: 11pt !important;
        color: #000 !important;
      }

      pre {
        white-space: pre-wrap !important;
        word-wrap: break-word !important;
        border: 1px solid #999 !important;
        background: #f0f0f0 !important;
        color: #000 !important;
        padding: 10px !important;
        font-size: 9pt !important;
        page-break-inside: avoid;
      }

      code {
        color: #c7254e !important;
        background: #f9f2f4 !important;
      }

      pre code {
        color: #000 !important;
        background: transparent !important;
      }

      a {
        color: #000 !important;
        text-decoration: underline !important;
      }

      a[href^="http"]:after {
        content: " [" attr(href) "]";
        font-size: 8pt;
        color: #666;
        word-break: break-all;
      }

      a[href^="#"]:after,
      a[href^="/"]:after {
        content: "";
      }

      img {
        max-width: 100% !important;
        page-break-inside: avoid;
      }

      h1, h2, h3, h4, h5, h6 {
        page-break-after: avoid;
        color: #000 !important;
      }

      table {
        border-collapse: collapse !important;
      }

      th, td {
        border: 1px solid #000 !important;
        padding: 8px !important;
      }

      /* Page header */
      .post-title {
        font-size: 24pt !important;
        color: #000 !important;
        margin-bottom: 10px !important;
      }

      /* Add URL at bottom */
      body:after {
        content: "Source: " attr(data-url);
        display: block;
        margin-top: 30px;
        font-size: 9pt;
        color: #666;
      }
    }
    </style>
  `;
  document.head.insertAdjacentHTML('beforeend', styles);

  // Set URL for print footer
  document.body.setAttribute('data-url', window.location.href);

})();

// Global functions for button clicks
function printPost() {
  window.print();
}

function copyPostLink() {
  navigator.clipboard.writeText(window.location.href).then(() => {
    showFeedback(event, 'Copied!', '#28a745');
  }).catch(() => {
    // Fallback for older browsers
    const textArea = document.createElement('textarea');
    textArea.value = window.location.href;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);
    showFeedback(event, 'Copied!', '#28a745');
  });
}

function downloadPost() {
  const title = document.querySelector('.post-title, h1').innerText.trim();
  const date = document.querySelector('.post-meta time')?.getAttribute('datetime') || new Date().toISOString();
  const content = (document.querySelector('article .content') || document.querySelector('.post-content')).innerText;
  const url = window.location.href;

  // Build markdown
  let markdown = `# ${title}\n\n`;
  markdown += `**Source:** ${url}  \n`;
  markdown += `**Date:** ${date.split('T')[0]}  \n`;
  markdown += `**Downloaded:** ${new Date().toISOString().split('T')[0]}\n\n`;
  markdown += `---\n\n`;
  markdown += content;

  // Create and trigger download
  const blob = new Blob([markdown], { type: 'text/markdown;charset=utf-8' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/-+/g, '-').replace(/^-|-$/g, '') + '.md';
  link.click();
  URL.revokeObjectURL(link.href);

  showFeedback(event, 'Downloaded!', '#28a745');
}

function showFeedback(evt, text, color) {
  const btn = evt.target.closest('.btn-action');
  if (!btn) return;

  const originalHTML = btn.innerHTML;
  const originalBg = btn.style.background;
  const originalColor = btn.style.color;

  btn.innerHTML = `<i class="fas fa-check"></i> ${text}`;
  btn.style.background = color;
  btn.style.color = '#fff';

  setTimeout(() => {
    btn.innerHTML = originalHTML;
    btn.style.background = originalBg;
    btn.style.color = originalColor;
  }, 2000);
}
