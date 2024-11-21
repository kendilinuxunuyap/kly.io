# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

html_theme = 'alabaster'


project = 'distroWiki'
copyright = 'distro 2023'
author = 'karahan'
language = 'tr'
version= '1.0'
extensions = ['sphinx.ext.autodoc', 'rst2pdf.pdfbuilder']
smartquotes = False

# -- Options for PDF output --

pdf_documents = [('index', u'rst2pdf', u'Kendi Linux`unu Yap', u'KLY'),]
pdf_stylesheets = ['style-main.yaml', 'tango']
#pdf_stylesheets = ['sphinx', 'letter', 'draft']
pdf_font_path = ['/usr/share/fonts', '/usr/share/texmf-dist/fonts/']
pdf_style_path = [ '.', 'wiki/_static']
pdf_use_coverpage = False
pdf_use_toc = False
pdf_default_dpi = 96
pdf_compressed = True
pdf_language = "tr_TR"
pdf_fit_mode = "shrink"

# -- Options for HTML output --

html_baseurl = 'https://kendilinuxunuyap.github.io/'
#html_theme = 'alabaster'


html_static_path = ['_static']
html_theme_options = {
    'font_family' : 'monospace',
    'footnote_bg': 'none',
    'page_width': '100%',
    'body_max_width': 'auto',
    'logo': 'logo.svg',

}
html_sidebars = {
    '**': [
        'about.html',
        'navigation.html',
    ]
}

