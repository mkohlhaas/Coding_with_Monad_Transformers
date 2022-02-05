{ name = "my-project"
, dependencies = [ "console", "effect", "prelude", "psci-support", "transformers", "identity", "either", "maybe", "newtype", "tuples" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}

