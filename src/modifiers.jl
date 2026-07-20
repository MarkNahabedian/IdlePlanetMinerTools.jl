export Modifier, DEFAULT_MODIFIERS

export spelt_diration_scalar, craft_diration_scalar,
    smelt_ingredient_scalar, craft_ingredient_scalar

abstract type Modifier end

DEFAULT_MODIFIERS = Modifier[]


spelt_diration_scalar(::Modifier) = 1
craft_diration_scalar(::Modifier) = 1
smelt_ingredient_scalar(::Modifier) = 1
craft_ingredient_scalar(::Modifier) = 1

