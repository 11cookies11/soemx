"""Network adapter discovery helpers."""


class Adapter:
    """Description of a network adapter returned by :func:`find_adapters`."""

    __slots__ = ("name", "desc")

    def __init__(self, name, desc):
        self.name = str(name)
        self.desc = str(desc)

    def __repr__(self):
        return f"Adapter(name={self.name!r}, desc={self.desc!r})"


def _decode(value: bytes) -> str:
    return value.split(b"\0", 1)[0].decode("utf-8", errors="replace")
