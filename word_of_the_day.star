load("http.star", "http")
load("re.star", "re")
load("render.star", "render")


WORD_OF_THE_DAY_URL = "https://www.merriam-webster.com/word-of-the-day"


def main():
    content = http.get(WORD_OF_THE_DAY_URL).body()
    word = search(
        content=content,
        after='<div class="word-and-pronunciation">',
        regex="<h1>(.+?)</h1>",
    )
    part = search(
        content=content,
        after='<div class="word-attributes">',
        regex='<span class="main-attr">(.+?)</span>'
    )
    definition = search(
        content=content,
        after='<h2>Definition</h2>',
        regex=':</strong> (.+?)</p>',
    )
    pretty_part = {
        "noun": "noun",
        "verb": "verb",
        "adverb": "adv.",
        "adjective": "adj.",
    }.get(part, "???")
    tokens = definition.split() + [".", "..", "..."]
    return render.Root(
        delay=133,
        child=render.Column(
            children=[
                render.Marquee(
                    width=64,
                    child=render.Text(word),
                ),
                render.Text(pretty_part, color="#58a"),
                render.Box(
                    render.Animation(
                        children=[
                            render.Text(content=t, color="#89a")
                            for t in tokens
                        ]
                    ),
                )
            ]
        )
    )


def search(content, after, regex):
    """Return the first regex match after a given string"""
    index = content.index(content)
    start, end = re.search(regex, content[index:])
    substring = content[start:end]
    # Hackily extract the first capture group
    trim_from_front = regex.index("(")
    trim_from_back = regex.index(")") - len(regex) + 1
    value = substring[trim_from_front:trim_from_back]
    # Hackily remove up to 10 links
    for i in range(10):
        if "</" in value:
            value = (
                value[:value.index("<")] +
                value[value.index(">") + 1:]
            )
    return value
