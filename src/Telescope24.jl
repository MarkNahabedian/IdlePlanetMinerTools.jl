# Telescope 24 is not on the wiki page:

struct Telescope24 <: Project end
@doc "Extends vision to planets 74 - 76" Telescope24

prerequisites(::Telescope24) = [Telescope23]

Recipie(Telescope24,
        Teleporter(5) + AqualiteAlloy(21),
        0)

export Telescope24

