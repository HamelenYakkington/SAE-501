def link(uri, label=None):
    if label is None: 
        label = uri
    parameters = ''
    escape_mask = '\033]8;{};{}\033\\{}\033]8;;\033\\'

    print(escape_mask.format(parameters, uri, label))