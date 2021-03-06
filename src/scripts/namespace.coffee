window.ContentTools =

    # Secondary namespace to store a common set of tools
    Tools: {}

    # Global settings

    # The default tool configuration for the editor
    DEFAULT_TOOLS: [
        [
            'bold',
            'italic',
            'link',
            'align-left',
            'align-center',
            'align-right'
        ], [
            'heading',
            'subheading',
            'paragraph',
            'unordered-list',
            'ordered-list',
            'table',
            'indent',
            'unindent',
            'line-break'
        ], [
            'image',
            'video',
            'preformatted'
        ], [
            'undo',
            'redo',
            'remove'
        ]
    ]

    # Default sizes for new videos when inserted into a region
    DEFAULT_VIDEO_HEIGHT: 300
    DEFAULT_VIDEO_WIDTH: 400

    # If the user holds down the shift key for an extended period of time the
    # editor app will highlight the editable regions on the page (if there are
    # any). This setting determines how long the user must hold down the shift
    # key to activate highlighting.
    HIGHLIGHT_HOLD_DURATION: 2000

    # A list of element class names ignored by the inspector, typically because
    # attributes cannot be safely set against them.
    INSPECTOR_IGNORED_ELEMENTS: [
        'ListItemText',
        'Region',
        'TableCellText'
        ]

    # If specified this should be a function that accepts an
    # `ContentTools.ImageDialog` instance, typically the function then binds a
    # set of handlers to specific dialog events to implement support for
    # uploading images asynchronously.
    IMAGE_UPLOADER: null

    # The minimum region that can be selected when cropping an image (in pixels)
    MIN_CROP: 10

    # A map of restricted attributes (attributes which can't be viewed or
    # modified in the properties dialog) in the form:
    #
    # `{tagName: [attributeNames], ...}`
    #
    # Attribute and tag names must be specified in lower case.
    #
    RESTRICTED_ATTRIBUTES: {
        'img': [
            'height',
            'src',
            'width',
            'data-ce-max-width',
            'data-ce-min-width'
            ],
        'iframe': ['height', 'width']
        }

    # Utility functions

    getEmbedVideoURL: (url) ->
        # Utility method to validate/parse video URLs and return a valid embed
        # URL. Supports YouTube and Vimeo URLs.
        domains = {
            'www.youtube.com': 'youtube',
            'youtu.be': 'youtube',
            'vimeo.com': 'vimeo',
            'player.vimeo.com': 'vimeo'
            }

        # Parse the URL into components
        parser = document.createElement('a')
        parser.href = url

        netloc = parser.hostname.toLowerCase()
        path = parser.pathname

        # Fix for paths in IE
        if path != null && path.substr(0, 1) != "/"
            path = "/" + path

        params = {}
        paramsStr = parser.search[1...]

        for kv in paramsStr.split('&')
            kv = kv.split("=")
            params[kv[0]] = kv[1]

        # Convert the URL to a valid embed URL
        switch domains[netloc]
            when 'youtube'
                if path.toLowerCase() == '/watch'
                    if not params['v']
                        return null
                    id = params['v']

                else
                    m = path.match(/\/([A-Za-z0-9_-]+)$/i)
                    if not m
                        return null
                    id = m[1]

                return "https://www.youtube.com/embed/#{ id }"

            when 'vimeo'
                m = path.match(/\/(\w+\/\w+\/){0,1}(\d+)/i)
                if not m
                    return null

                return "https://player.vimeo.com/video/#{ m[2] }"

        return null